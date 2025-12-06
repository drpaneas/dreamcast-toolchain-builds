#!/bin/bash
# Smoke test: Verify toolchain can compile code for Dreamcast
#
# This script tests:
# 1. Basic C compilation with sh-elf-gcc
# 2. Basic C++ compilation with sh-elf-g++
# 3. Basic Go compilation with sh-elf-gccgo
# 4. KOS program compilation using kos-cc
# 5. Full KOS example linking
#
# Usage: ./scripts/smoke-test.sh /path/to/toolchain

set -e

TOOLCHAIN_DIR="${1:-.}"

echo "🧪 Running comprehensive smoke test on Dreamcast toolchain..."
echo "   Toolchain: $TOOLCHAIN_DIR"
echo ""

# Verify toolchain directory structure
if [ ! -d "$TOOLCHAIN_DIR/sh-elf/bin" ]; then
    echo "❌ ERROR: sh-elf/bin not found in $TOOLCHAIN_DIR"
    exit 1
fi

if [ ! -d "$TOOLCHAIN_DIR/kos" ]; then
    echo "❌ ERROR: kos directory not found in $TOOLCHAIN_DIR"
    exit 1
fi

# Setup environment
export PATH="$TOOLCHAIN_DIR/sh-elf/bin:$TOOLCHAIN_DIR/kos/utils/build_wrappers:$PATH"

# Source KOS environment if environ.sh exists
if [ -f "$TOOLCHAIN_DIR/kos/environ.sh" ]; then
    source "$TOOLCHAIN_DIR/kos/environ.sh"
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT
cd "$TEMP_DIR"

TESTS_PASSED=0
TESTS_TOTAL=0

run_test() {
    local name="$1"
    local cmd="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -n "Test $TESTS_TOTAL: $name... "
    
    if eval "$cmd" > /dev/null 2>&1; then
        echo "✅ PASSED"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "❌ FAILED"
        return 1
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Basic Compiler Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Test 1: Basic C compilation
cat > test.c << 'EOF'
int add(int a, int b) {
    return a + b;
}
EOF
run_test "C compilation (sh-elf-gcc)" "sh-elf-gcc -c test.c -o test.o"

# Test 2: Basic C++ compilation
cat > test.cpp << 'EOF'
class Calculator {
public:
    int add(int a, int b) {
        return a + b;
    }
};
EOF
run_test "C++ compilation (sh-elf-g++)" "sh-elf-g++ -c test.cpp -o test_cpp.o"

# Test 3: Basic Go compilation
cat > test.go << 'EOF'
package main

func add(a, b int) int {
    return a + b
}

func main() {}
EOF
run_test "Go compilation (sh-elf-gccgo)" "sh-elf-gccgo -c test.go -o test_go.o"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 KOS Integration Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Test 4: kos-cc wrapper exists and is executable
run_test "kos-cc wrapper available" "command -v kos-cc"

# Test 5: KOS header compilation
cat > kos_test.c << 'EOF'
#include <kos.h>

int main(int argc, char *argv[]) {
    return 0;
}
EOF
run_test "KOS headers compile" "kos-cc -c kos_test.c -o kos_test.o"

# Test 6: Full KOS program linking
cat > hello_dc.c << 'EOF'
#include <kos.h>
#include <dc/biosfont.h>

int main(int argc, char *argv[]) {
    vid_set_mode(DM_640x480, PM_RGB565);
    vid_clear(0x10, 0x10, 0x40);
    bfont_draw_str(vram_s + 100 * 640 + 200, 640, 1, "Hello Dreamcast!");
    
    while(1) {
        MAPLE_FOREACH_BEGIN(MAPLE_FUNC_CONTROLLER, cont_state_t, st)
            if(st->buttons & CONT_START)
                arch_exit();
        MAPLE_FOREACH_END()
        thd_sleep(20);
    }
    
    return 0;
}
EOF
run_test "Full KOS program links" "kos-cc -o hello_dc.elf hello_dc.c"

# Test 7: Verify resulting ELF is valid SH4 binary
if [ -f hello_dc.elf ]; then
    run_test "ELF binary is valid SH4" "sh-elf-readelf -h hello_dc.elf | grep -q 'Renesas / SuperH SH'"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Library Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Test 8: KOS kernel library exists
run_test "libkallisti.a exists" "test -f '$TOOLCHAIN_DIR/kos/lib/dreamcast/libkallisti.a'"

# Test 9: GCC runtime library exists
run_test "libgcc.a exists" "ls '$TOOLCHAIN_DIR/sh-elf/lib/gcc/sh-elf/'*/libgcc.a"

# Test 10: kos-ports libraries (check a few common ones)
if [ -d "$TOOLCHAIN_DIR/kos-ports/lib" ]; then
    run_test "kos-ports libpng exists" "test -f '$TOOLCHAIN_DIR/kos-ports/lib/libpng.a'"
    run_test "kos-ports zlib exists" "test -f '$TOOLCHAIN_DIR/kos-ports/lib/libz.a'"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo "✅ All $TESTS_TOTAL tests PASSED!"
    echo ""
    echo "🎉 Toolchain is fully functional and ready for Dreamcast development!"
    exit 0
else
    echo "❌ $TESTS_PASSED/$TESTS_TOTAL tests passed"
    echo ""
    echo "⚠️  Some tests failed. The toolchain may have issues."
    exit 1
fi
