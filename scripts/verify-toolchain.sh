#!/bin/bash
# Verify Dreamcast toolchain is complete and functional

set -e

TOOLCHAIN_DIR="${1:-.}"

echo "🔍 Verifying Dreamcast Toolchain"
echo "Location: $TOOLCHAIN_DIR"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅${NC} $2"
        return 0
    else
        echo -e "${RED}❌${NC} $2 (missing: $1)"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✅${NC} $2"
        return 0
    else
        echo -e "${RED}❌${NC} $2 (missing: $1)"
        return 1
    fi
}

FAILED=0

echo "📦 Checking Binaries:"
check_file "$TOOLCHAIN_DIR/sh-elf/bin/sh-elf-gcc" "sh-elf-gcc (C compiler)" || FAILED=1
check_file "$TOOLCHAIN_DIR/sh-elf/bin/sh-elf-g++" "sh-elf-g++ (C++ compiler)" || FAILED=1
check_file "$TOOLCHAIN_DIR/sh-elf/bin/sh-elf-gccgo" "sh-elf-gccgo (Go compiler)" || FAILED=1
check_file "$TOOLCHAIN_DIR/sh-elf/bin/sh-elf-as" "sh-elf-as (Assembler)" || FAILED=1
check_file "$TOOLCHAIN_DIR/sh-elf/bin/sh-elf-ld" "sh-elf-ld (Linker)" || FAILED=1
check_file "$TOOLCHAIN_DIR/sh-elf/bin/sh-elf-ar" "sh-elf-ar (Archiver)" || FAILED=1
check_file "$TOOLCHAIN_DIR/kos/utils/build_wrappers/kos-cc" "kos-cc (KOS wrapper)" || FAILED=1
check_file "$TOOLCHAIN_DIR/kos/utils/build_wrappers/kos-c++" "kos-c++ (KOS C++ wrapper)" || FAILED=1
echo ""

echo "📚 Checking KallistiOS Libraries:"
check_dir "$TOOLCHAIN_DIR/kos/lib/dreamcast" "KOS lib directory" || FAILED=1
check_file "$TOOLCHAIN_DIR/kos/lib/dreamcast/libkallisti.a" "libkallisti.a (KOS kernel)" || FAILED=1

echo ""
echo "🔧 Checking GCC Libraries:"
# libgcc.a is in the GCC toolchain, not in KOS
if ls "$TOOLCHAIN_DIR/sh-elf/lib/gcc/sh-elf/"*/libgcc.a 1> /dev/null 2>&1; then
    echo -e "${GREEN}✅${NC} libgcc.a (GCC runtime)"
else
    echo -e "${RED}❌${NC} libgcc.a (GCC runtime) not found"
    FAILED=1
fi

echo ""
echo "📚 Checking Newlib Libraries:"
check_file "$TOOLCHAIN_DIR/sh-elf/sh-elf/lib/libc.a" "libc.a (C standard library)" || FAILED=1
check_file "$TOOLCHAIN_DIR/sh-elf/sh-elf/lib/libm.a" "libm.a (Math library)" || FAILED=1
check_file "$TOOLCHAIN_DIR/sh-elf/sh-elf/lib/libg.a" "libg.a (Debug C library)" || FAILED=1
echo ""

echo "📦 Checking kos-ports Libraries:"
check_dir "$TOOLCHAIN_DIR/kos-ports/lib" "kos-ports lib directory" || FAILED=1

# Check common kos-ports libraries
PORTS_LIBS=("libpng.a" "libz.a" "libjpeg.a" "libGL.a" "libfreetype.a" "liblua.a")
for lib in "${PORTS_LIBS[@]}"; do
    if [ -f "$TOOLCHAIN_DIR/kos-ports/lib/$lib" ]; then
        echo -e "${GREEN}✅${NC} $lib"
    fi
done
echo ""

echo "📄 Checking KallistiOS Headers:"
check_dir "$TOOLCHAIN_DIR/kos/include" "KOS include directory" || FAILED=1
check_file "$TOOLCHAIN_DIR/kos/include/kos.h" "kos.h (Main header)" || FAILED=1
check_dir "$TOOLCHAIN_DIR/kos/kernel/arch/dreamcast/include/dc" "dc/ (Dreamcast headers)" || FAILED=1
check_file "$TOOLCHAIN_DIR/kos/kernel/arch/dreamcast/include/dc/pvr.h" "dc/pvr.h (Graphics)" || FAILED=1
check_file "$TOOLCHAIN_DIR/kos/kernel/arch/dreamcast/include/dc/video.h" "dc/video.h (Video)" || FAILED=1
echo ""

echo "🔧 Checking KOS Build Wrappers:"
check_file "$TOOLCHAIN_DIR/kos/utils/build_wrappers/kos-cc" "kos-cc wrapper" || FAILED=1
check_file "$TOOLCHAIN_DIR/kos/environ_base.sh" "environ_base.sh" || FAILED=1
check_file "$TOOLCHAIN_DIR/kos/environ_dreamcast.sh" "environ_dreamcast.sh" || FAILED=1
check_file "$TOOLCHAIN_DIR/kos/Makefile.rules" "Makefile.rules" || FAILED=1
echo ""

echo "🧪 Testing Executables:"
if [ -x "$TOOLCHAIN_DIR/sh-elf/bin/sh-elf-gccgo" ]; then
    VERSION=$("$TOOLCHAIN_DIR/sh-elf/bin/sh-elf-gccgo" --version 2>&1 | head -1)
    echo -e "${GREEN}✅${NC} gccgo works: $VERSION"
else
    echo -e "${RED}❌${NC} sh-elf-gccgo not executable"
    FAILED=1
fi

if [ -x "$TOOLCHAIN_DIR/sh-elf/bin/sh-elf-gcc" ]; then
    VERSION=$("$TOOLCHAIN_DIR/sh-elf/bin/sh-elf-gcc" --version 2>&1 | head -1)
    echo -e "${GREEN}✅${NC} gcc works: $VERSION"
else
    echo -e "${RED}❌${NC} sh-elf-gcc not executable"
    FAILED=1
fi
echo ""

echo "📊 Statistics:"
KOS_LIB_COUNT=$(find "$TOOLCHAIN_DIR/kos/lib/dreamcast" -maxdepth 1 -name "*.a" 2>/dev/null | wc -l | tr -d ' ')
echo "  KOS libraries: $KOS_LIB_COUNT files"

PORTS_LIB_COUNT=$(find "$TOOLCHAIN_DIR/kos-ports/lib" -maxdepth 1 -name "*.a" 2>/dev/null | wc -l | tr -d ' ')
echo "  kos-ports libraries: $PORTS_LIB_COUNT files"

HEADER_COUNT=$(find "$TOOLCHAIN_DIR/kos/include" -name "*.h" 2>/dev/null | wc -l | tr -d ' ')
echo "  KOS headers: $HEADER_COUNT files"

TOOLCHAIN_SIZE=$(du -sh "$TOOLCHAIN_DIR" 2>/dev/null | cut -f1)
echo "  Total size: $TOOLCHAIN_SIZE"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Toolchain verification PASSED${NC}"
    echo ""
    echo "Add to PATH:"
    echo "  export PATH=\"$TOOLCHAIN_DIR/sh-elf/bin:\$PATH\""
    echo "  export PATH=\"$TOOLCHAIN_DIR/kos/utils/build_wrappers:\$PATH\""
    echo ""
    echo "Or use absolute path:"
    TOOLCHAIN_ABS=$(cd "$TOOLCHAIN_DIR" && pwd)
    echo "  export PATH=\"${TOOLCHAIN_ABS}/sh-elf/bin:${TOOLCHAIN_ABS}/kos/utils/build_wrappers:\$PATH\""
    echo ""
    echo "Then test:"
    echo "  sh-elf-gccgo --version"
    echo "  kos-cc --version"
    echo "  cd godc/examples/hello"
    echo "  godc build main.go"
    exit 0
else
    echo -e "${RED}❌ Toolchain verification FAILED${NC}"
    echo ""
    echo "Some components are missing. Re-download or rebuild the toolchain."
    exit 1
fi

