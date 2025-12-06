#!/bin/bash
# Disable known broken builds in KOS and kos-ports
#
# These components fail to build due to:
# - mruby: Bison parser incompatibility with mruby 3.3.0's parse.y
# - mruby examples: Depend on mruby port which fails to build
# - objc/runtime: Requires Objective-C compiler not included in toolchain
#
# Usage: ./scripts/disable-broken-builds.sh /path/to/toolchain
#        ./scripts/disable-broken-builds.sh  # defaults to /opt/toolchains/dc

set -e

TOOLCHAIN_PATH="${1:-/opt/toolchains/dc}"

echo "🔧 Disabling known broken builds..."
echo "   Toolchain path: $TOOLCHAIN_PATH"
echo ""

# Track what we disabled
DISABLED=()

# Function to disable a build by renaming its Makefile
disable_build() {
    local path="$1"
    local name="$2"
    
    if [ -f "$path/Makefile" ]; then
        mv "$path/Makefile" "$path/Makefile.disabled"
        echo "   ✅ Disabled: $name"
        DISABLED+=("$name")
    elif [ -f "$path/Makefile.disabled" ]; then
        echo "   ⏭️  Already disabled: $name"
    else
        echo "   ⚠️  Not found: $name ($path)"
    fi
}

# === kos-ports ===
echo "📦 kos-ports:"

# mruby - Bison parser syntax error in parse.y (incompatible with modern bison)
disable_build "$TOOLCHAIN_PATH/kos-ports/mruby" "mruby (bison incompatibility)"

echo ""

# === KOS Examples ===
echo "📂 KOS Examples:"

# mruby examples - depend on mruby port which fails to build
disable_build "$TOOLCHAIN_PATH/kos/examples/dreamcast/mruby/dreampresent" "mruby/dreampresent (depends on mruby)"
disable_build "$TOOLCHAIN_PATH/kos/examples/dreamcast/mruby/mrbtris" "mruby/mrbtris (depends on mruby)"

# Objective-C example - requires Objective-C compiler not in toolchain
disable_build "$TOOLCHAIN_PATH/kos/examples/dreamcast/objc/runtime" "objc/runtime (no Objective-C compiler)"

echo ""

# Summary
if [ ${#DISABLED[@]} -gt 0 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Disabled ${#DISABLED[@]} broken build(s)"
    echo ""
    echo "To re-enable any of these, rename Makefile.disabled back to Makefile"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "ℹ️  No changes needed - all broken builds already disabled"
fi

