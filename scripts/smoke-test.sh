#!/bin/bash
# Smoke test: Verify toolchain can actually compile code

set -e

TOOLCHAIN_DIR="${1:-.}"

echo "🧪 Running smoke test on toolchain..."
echo ""

# Setup PATH
export PATH="$TOOLCHAIN_DIR/sh-elf/bin:$TOOLCHAIN_DIR/kos/utils/build_wrappers:$PATH"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Test 1: Compile simple C program"
cat > test.c << 'EOF'
int add(int a, int b) {
    return a + b;
}
EOF

sh-elf-gcc -c test.c -o test.o
if [ $? -eq 0 ]; then
    echo "  ✅ C compilation works"
else
    echo "  ❌ C compilation failed"
    exit 1
fi

echo ""
echo "Test 2: Compile simple Go program"
cat > test.go << 'EOF'
package main

func add(a, b int) int {
    return a + b
}

func main() {}
EOF

sh-elf-gccgo -c test.go -o test_go.o
if [ $? -eq 0 ]; then
    echo "  ✅ Go compilation works"
else
    echo "  ❌ Go compilation failed"
    exit 1
fi

echo ""
echo "Test 3: Check kos-cc wrapper"
if command -v kos-cc &> /dev/null; then
    echo "  ✅ kos-cc is in PATH and executable"
else
    echo "  ❌ kos-cc not found in PATH"
    exit 1
fi

echo ""
echo "Test 4: Verify KOS libraries linkable"
if [ -f "$TOOLCHAIN_DIR/kos/lib/libkallisti.a" ]; then
    SIZE=$(wc -c < "$TOOLCHAIN_DIR/kos/lib/libkallisti.a")
    if [ $SIZE -gt 100000 ]; then
        echo "  ✅ libkallisti.a exists and is non-empty ($SIZE bytes)"
    else
        echo "  ❌ libkallisti.a is too small (corrupt?)"
        exit 1
    fi
else
    echo "  ❌ libkallisti.a not found"
    exit 1
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "✅ All smoke tests PASSED!"
echo ""
echo "Toolchain is functional and ready for release! 🎉"

