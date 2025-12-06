#!/bin/bash
# Patch environ.sh to use relative paths based on script location
# This makes the toolchain fully portable - works from any directory
#
# Usage: ./scripts/patch-environ.sh /path/to/kos

set -e

KOS_DIR="${1:-.}"

if [ ! -f "$KOS_DIR/environ.sh" ]; then
    echo "Error: environ.sh not found in $KOS_DIR"
    exit 1
fi

if [ ! -f "$KOS_DIR/environ_base.sh" ]; then
    echo "Error: environ_base.sh not found in $KOS_DIR"
    exit 1
fi

echo "Patching environ.sh for portable/relocatable installation..."

# Completely replace environ.sh with a portable version
cat > "$KOS_DIR/environ.sh" << 'EOF'
# KallistiOS Environment Settings - Portable Version
# This script auto-detects paths based on its location.
# 
# Usage: source /path/to/kos/environ.sh
#
# DO NOT run with ./environ.sh - you MUST use 'source' or '.'
# to load environment variables into your current shell.

# === Detect script location (works in bash and zsh) ===
_kos_get_script_dir() {
    local script_path=""
    
    # Try BASH_SOURCE first (bash)
    if [ -n "${BASH_SOURCE[0]:-}" ]; then
        script_path="${BASH_SOURCE[0]}"
    # Try ZSH_VERSION (zsh)
    elif [ -n "${ZSH_VERSION:-}" ]; then
        script_path="${(%):-%x}"
    # Fallback (may not work if sourced)
    elif [ -n "$0" ] && [ "$0" != "-bash" ] && [ "$0" != "-zsh" ] && [ "$0" != "bash" ] && [ "$0" != "zsh" ]; then
        script_path="$0"
    fi
    
    if [ -z "$script_path" ]; then
        echo "ERROR: Cannot detect script location. Set KOS_BASE manually." >&2
        return 1
    fi
    
    # Resolve to absolute path
    cd "$(dirname "$script_path")" && pwd -P
}

# === Set KOS_BASE from script location ===
_KOS_SCRIPT_DIR="$(_kos_get_script_dir)"
if [ $? -ne 0 ] || [ -z "$_KOS_SCRIPT_DIR" ]; then
    echo "ERROR: Failed to detect KOS installation path." >&2
    echo "Please set KOS_BASE manually before sourcing this script." >&2
    return 1
fi

export KOS_BASE="$_KOS_SCRIPT_DIR"

# === Derive all other paths relative to KOS_BASE ===
# Parent directory contains sh-elf and kos-ports
_TOOLCHAIN_BASE="$(dirname "$KOS_BASE")"

export KOS_PORTS="${_TOOLCHAIN_BASE}/kos-ports"
export KOS_CC_BASE="${_TOOLCHAIN_BASE}/sh-elf"
export KOS_CC_PREFIX="sh-elf"

# ARM toolchain (optional - may not be present)
export DC_ARM_BASE="${_TOOLCHAIN_BASE}/arm-eabi"
export DC_ARM_PREFIX="arm-eabi"

# External tools
export DC_TOOLS_BASE="${_TOOLCHAIN_BASE}/bin"

# === Build configuration ===
export KOS_ARCH="dreamcast"
export KOS_SUBARCH="${KOS_SUBARCH:-pristine}"

# CMake toolchain
export KOS_CMAKE_TOOLCHAIN="${KOS_BASE}/utils/cmake/kallistios.toolchain.cmake"

# Genromfs utility
export KOS_GENROMFS="${KOS_BASE}/utils/genromfs/genromfs"

# Make utility
export KOS_MAKE="make"

# Loader for real hardware
export KOS_LOADER="dc-tool -x"

# === Compiler flags ===
export KOS_INC_PATHS=""
export KOS_CFLAGS=""
export KOS_CPPFLAGS=""
export KOS_LDFLAGS=""
export KOS_AFLAGS=""
export DC_ARM_LDFLAGS=""

# Optimization
export KOS_CFLAGS="${KOS_CFLAGS} -O2"

# Frame pointers (disabled for performance)
export KOS_CFLAGS="${KOS_CFLAGS} -fomit-frame-pointer"

# GCC builtins
export KOS_CFLAGS="${KOS_CFLAGS} -fno-builtin"

# SH4 floating-point precision
export KOS_SH4_PRECISION="-m4-single"

# === Load shared environment (sets up PATH, etc.) ===
if [ -f "${KOS_BASE}/environ_base.sh" ]; then
    . "${KOS_BASE}/environ_base.sh"
else
    echo "WARNING: environ_base.sh not found at ${KOS_BASE}/environ_base.sh" >&2
fi

# === Verify and display ===
echo "KallistiOS environment loaded:"
echo "  KOS_BASE:    $KOS_BASE"
echo "  KOS_CC_BASE: $KOS_CC_BASE"  
echo "  KOS_PORTS:   $KOS_PORTS"
if [ -n "${KOS_GCCVER:-}" ]; then
    echo "  GCC version: $KOS_GCCVER"
fi

# Cleanup temporary variables
unset _KOS_SCRIPT_DIR _TOOLCHAIN_BASE
EOF

chmod +x "$KOS_DIR/environ.sh"

echo "✅ environ.sh patched successfully"
echo ""
echo "The toolchain is now portable. Users source it with:"
echo "  source /any/path/to/kos/environ.sh"
echo ""
echo "Verifying patch..."
if grep -q "_kos_get_script_dir" "$KOS_DIR/environ.sh"; then
    echo "✅ Patch verified - contains auto-detection logic"
else
    echo "❌ Patch verification failed!"
    exit 1
fi
