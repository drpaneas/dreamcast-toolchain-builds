#!/bin/bash
# Patch environ.sh to use a relocatable base path
# This script is run during packaging to make the toolchain portable
#
# Usage: ./scripts/patch-environ.sh /path/to/kos
#
# The patched environ.sh will auto-detect the installation directory

set -e

KOS_DIR="${1:-.}"

if [ ! -f "$KOS_DIR/environ.sh" ]; then
    echo "Error: environ.sh not found in $KOS_DIR"
    exit 1
fi

echo "Patching environ.sh for relocatable installation..."

# Create the new environ.sh with auto-detection
cat > "$KOS_DIR/environ.sh" << 'ENVIRON_EOF'
# KallistiOS Environment Settings
# Auto-configured for pre-built toolchain distribution
#
# This script auto-detects the installation directory.
# Source this file before building KOS projects:
#   source /path/to/kos/environ.sh
#

# Build Architecture
export KOS_ARCH="dreamcast"

# Build Sub-Architecture
if [ -z "${KOS_SUBARCH}" ] ; then
    export KOS_SUBARCH="pristine"
else
    export KOS_SUBARCH
fi

# Auto-detect KOS installation path from this script's location
# Works whether sourced directly or via symlink
if [ -n "${BASH_SOURCE[0]}" ]; then
    KOS_SCRIPT_PATH="${BASH_SOURCE[0]}"
elif [ -n "$ZSH_VERSION" ]; then
    KOS_SCRIPT_PATH="${(%):-%x}"
else
    # Fallback for other shells
    KOS_SCRIPT_PATH="$0"
fi

# Resolve the real path (following symlinks)
KOS_SCRIPT_DIR="$(cd "$(dirname "$KOS_SCRIPT_PATH")" && pwd -P)"
export KOS_BASE="$KOS_SCRIPT_DIR"

# Toolchain base is one level up from KOS
TOOLCHAIN_BASE="$(dirname "$KOS_BASE")"

# KOS-Ports Path
export KOS_PORTS="${TOOLCHAIN_BASE}/kos-ports"

# SH Compiler Prefixes
export KOS_CC_BASE="${TOOLCHAIN_BASE}/sh-elf"
export KOS_CC_PREFIX="sh-elf"

# ARM Compiler Prefixes (for AICA sound processor)
# Note: ARM toolchain may not be included in all distributions
export DC_ARM_BASE="${TOOLCHAIN_BASE}/arm-eabi"
export DC_ARM_PREFIX="arm-eabi"

# External Dreamcast Tools Path
export DC_TOOLS_BASE="${TOOLCHAIN_BASE}/bin"

# CMake Toolchain Path
export KOS_CMAKE_TOOLCHAIN="${KOS_BASE}/utils/cmake/kallistios.toolchain.cmake"

# Genromfs Utility Path
export KOS_GENROMFS="${KOS_BASE}/utils/genromfs/genromfs"

# Make Utility
export KOS_MAKE="make"

# Loader Utility (for running on real hardware)
export KOS_LOADER="dc-tool -x"

# Default Compiler Flags
export KOS_INC_PATHS=""
export KOS_CFLAGS=""
export KOS_CPPFLAGS=""
export KOS_LDFLAGS=""
export KOS_AFLAGS=""
export DC_ARM_LDFLAGS=""

# Optimization Level
export KOS_CFLAGS="${KOS_CFLAGS} -O2"

# Frame Pointers (disabled for performance)
export KOS_CFLAGS="${KOS_CFLAGS} -fomit-frame-pointer"

# GCC Builtin Functions
export KOS_CFLAGS="${KOS_CFLAGS} -fno-builtin"

# SH4 Floating-Point Arithmetic Precision (m4-single for 64-bit double support)
export KOS_SH4_PRECISION="-m4-single"

# Include shared environment settings
. ${KOS_BASE}/environ_base.sh

# Print confirmation
echo "KallistiOS environment loaded:"
echo "  KOS_BASE: $KOS_BASE"
echo "  Toolchain: $KOS_CC_BASE"
echo "  GCC version: $KOS_GCCVER"
ENVIRON_EOF

echo "✅ environ.sh patched successfully"
echo ""
echo "Users can now source it from any location:"
echo "  source /path/to/kos/environ.sh"

