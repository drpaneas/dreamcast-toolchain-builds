#!/bin/bash
# Build Dreamcast cross-compilation toolchain with gccgo support
set -e

VERSION=${VERSION:-"2.0.0"}
GCC_VERSION="15.2.0"
BINUTILS_VERSION="2.43"
TARGET="sh-elf"
BUILD_DIR="$PWD/build"
PREFIX="$BUILD_DIR/dreamcast-toolchain"

echo "🔧 Building Dreamcast Toolchain v$VERSION"
echo "   GCC: $GCC_VERSION (with gccgo)"
echo "   Binutils: $BINUTILS_VERSION"
echo "   Target: $TARGET"
echo "   Install to: $PREFIX"
echo ""

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Number of parallel jobs
JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
echo "📊 Using $JOBS parallel jobs"
echo ""

#================================================================
# Step 1: Build Binutils
#================================================================
echo "📦 Step 1/3: Building Binutils $BINUTILS_VERSION..."

if [ ! -f "binutils-$BINUTILS_VERSION.tar.gz" ]; then
    wget "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz"
fi

tar xzf "binutils-$BINUTILS_VERSION.tar.gz"
cd "binutils-$BINUTILS_VERSION"
mkdir -p build && cd build

../configure \
    --target=$TARGET \
    --prefix="$PREFIX" \
    --disable-werror \
    --disable-nls \
    --with-system-zlib

make -j$JOBS
make install

cd "$BUILD_DIR"
echo "✅ Binutils installed"
echo ""

#================================================================
# Step 2: Build GCC with gccgo
#================================================================
echo "📦 Step 2/3: Building GCC $GCC_VERSION with Go support..."

if [ ! -f "gcc-$GCC_VERSION.tar.gz" ]; then
    wget "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz"
fi

tar xzf "gcc-$GCC_VERSION.tar.gz"
cd "gcc-$GCC_VERSION"

# Download prerequisites
./contrib/download_prerequisites

mkdir -p build && cd build

# Add PREFIX/bin to PATH so GCC finds our binutils
export PATH="$PREFIX/bin:$PATH"

../configure \
    --target=$TARGET \
    --prefix="$PREFIX" \
    --enable-languages=c,c++,go \
    --with-newlib \
    --disable-multilib \
    --disable-libgo \
    --disable-nls \
    --disable-libssp \
    --disable-tls \
    --with-system-zlib

echo "⏳ Compiling GCC (this takes 20-40 minutes)..."
make -j$JOBS

echo "📥 Installing GCC..."
make install

cd "$BUILD_DIR"
echo "✅ GCC with gccgo installed"
echo ""

#================================================================
# Step 3: Build KallistiOS
#================================================================
echo "📦 Step 3/3: Building KallistiOS..."

# Clone KOS
if [ ! -d "KallistiOS" ]; then
    git clone https://github.com/KallistiOS/KallistiOS.git
    cd KallistiOS
    git checkout v2.0.0  # Use stable release
else
    cd KallistiOS
fi

# Configure KOS to use our toolchain
cp doc/environ.sh.sample environ.sh

# Update paths in environ.sh
sed -i.bak "s|/opt/toolchains/dc/sh-elf|$PREFIX|g" environ.sh
sed -i.bak "s|/opt/toolchains/dc/kos|$PREFIX/kos|g" environ.sh

# Source environment
source environ.sh

# Build KOS
echo "⏳ Building KallistiOS (this takes 5-10 minutes)..."
make

# Copy KOS to toolchain directory
mkdir -p "$PREFIX/kos"
cp -r lib "$PREFIX/kos/"
cp -r include "$PREFIX/kos/"

cd "$BUILD_DIR"
echo "✅ KallistiOS installed"
echo ""

#================================================================
# Step 4: Package Release
#================================================================
echo "📦 Step 4/4: Packaging release..."

# Detect platform
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
PLATFORM="${OS}-${ARCH}"

TARBALL="dreamcast-toolchain-v${VERSION}-${PLATFORM}.tar.gz"

cd "$BUILD_DIR"
tar czf "$TARBALL" \
    --transform "s|^dreamcast-toolchain|dreamcast-toolchain|" \
    dreamcast-toolchain/

# Generate checksum
shasum -a 256 "$TARBALL" > "${TARBALL}.sha256"

echo "✅ Package created: $TARBALL"
echo "   Size: $(du -h "$TARBALL" | cut -f1)"
echo ""

# Create version info
cat > "$PREFIX/VERSION" << EOF
Dreamcast Toolchain v$VERSION
Platform: $PLATFORM
GCC: $GCC_VERSION
Binutils: $BINUTILS_VERSION
KallistiOS: 2.0.0
Built: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

echo "🎉 Build complete!"
echo ""
echo "Package: $BUILD_DIR/$TARBALL"
echo "Checksum: $BUILD_DIR/${TARBALL}.sha256"
echo ""
echo "Test installation:"
echo "  tar xzf $TARBALL -C /tmp/test-toolchain"
echo "  export PATH=/tmp/test-toolchain/dreamcast-toolchain/bin:\$PATH"
echo "  sh-elf-gccgo --version"

