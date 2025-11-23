#!/bin/bash
# Automated Release Script for Dreamcast Toolchain Builds
# Usage: ./release.sh <GCC_VERSION> <KOS_VERSION>
# Example: ./release.sh 15.1.0 2.2.1

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored messages
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

# Banner
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║   Dreamcast Toolchain Release Automation Script      ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

#=============================================================================
# Step 0: Validate Input
#=============================================================================
if [ $# -ne 2 ]; then
    error "Usage: $0 <GCC_VERSION> <KOS_VERSION>
    
Example: $0 15.1.0 2.2.1
Example: $0 16.0.0 2.3.0

GCC_VERSION: Version number without 'gcc' prefix (e.g., 15.1.0)
KOS_VERSION: Version number without 'v' prefix (e.g., 2.2.1)"
fi

GCC_VERSION="$1"
KOS_VERSION="$2"

# Validate version format
if ! [[ "$GCC_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "Invalid GCC version format: $GCC_VERSION (expected: X.Y.Z)"
fi

if ! [[ "$KOS_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "Invalid KOS version format: $KOS_VERSION (expected: X.Y.Z)"
fi

KOS_VERSION_WITH_V="v${KOS_VERSION}"
TAG_NAME="gcc${GCC_VERSION}-kos${KOS_VERSION}"

info "Target versions:"
echo "  GCC: ${GCC_VERSION}"
echo "  KallistiOS: ${KOS_VERSION_WITH_V}"
echo "  Tag: ${TAG_NAME}"
echo ""

#=============================================================================
# Step 1: Verify Versions Exist
#=============================================================================
info "Step 1/5: Verifying versions exist..."

# Check GCC version
info "  Checking GCC ${GCC_VERSION}..."
GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/"
if curl --output /dev/null --silent --head --fail "$GCC_URL"; then
    success "  GCC ${GCC_VERSION} exists"
else
    error "  GCC version ${GCC_VERSION} not found at ${GCC_URL}"
fi

# Check KallistiOS version
info "  Checking KallistiOS ${KOS_VERSION_WITH_V}..."
KOS_URL="https://api.github.com/repos/KallistiOS/KallistiOS/releases/tags/${KOS_VERSION_WITH_V}"
if curl --output /dev/null --silent --head --fail "$KOS_URL"; then
    success "  KallistiOS ${KOS_VERSION_WITH_V} exists"
else
    error "  KallistiOS version ${KOS_VERSION_WITH_V} not found. Check: https://github.com/KallistiOS/KallistiOS/releases"
fi

echo ""

#=============================================================================
# Step 2: Update Workflow Files
#=============================================================================
info "Step 2/5: Updating workflow files..."

UBUNTU_WORKFLOW=".github/workflows/build-ubuntu.yml"
MACOS_WORKFLOW=".github/workflows/build-macos.yml"

if [ ! -f "$UBUNTU_WORKFLOW" ] || [ ! -f "$MACOS_WORKFLOW" ]; then
    error "Workflow files not found. Are you in the repository root?"
fi

# Backup original files
cp "$UBUNTU_WORKFLOW" "${UBUNTU_WORKFLOW}.backup"
cp "$MACOS_WORKFLOW" "${MACOS_WORKFLOW}.backup"
success "  Created backups"

# Update Ubuntu workflow
sed -i.tmp "s/DEFAULT_GCC_VERSION: '[0-9.]*'/DEFAULT_GCC_VERSION: '${GCC_VERSION}'/" "$UBUNTU_WORKFLOW"
sed -i.tmp "s/DEFAULT_KOS_VERSION: 'v[0-9.]*'/DEFAULT_KOS_VERSION: '${KOS_VERSION_WITH_V}'/" "$UBUNTU_WORKFLOW"
rm -f "${UBUNTU_WORKFLOW}.tmp"
success "  Updated $UBUNTU_WORKFLOW"

# Update macOS workflow
sed -i.tmp "s/DEFAULT_GCC_VERSION: '[0-9.]*'/DEFAULT_GCC_VERSION: '${GCC_VERSION}'/" "$MACOS_WORKFLOW"
sed -i.tmp "s/DEFAULT_KOS_VERSION: 'v[0-9.]*'/DEFAULT_KOS_VERSION: '${KOS_VERSION_WITH_V}'/" "$MACOS_WORKFLOW"
rm -f "${MACOS_WORKFLOW}.tmp"
success "  Updated $MACOS_WORKFLOW"

echo ""

#=============================================================================
# Step 3: Validate YAML Syntax
#=============================================================================
info "Step 3/5: Validating YAML syntax..."

# Check if yamllint is available
if command -v yamllint &> /dev/null; then
    if yamllint -d relaxed "$UBUNTU_WORKFLOW" "$MACOS_WORKFLOW"; then
        success "  YAML syntax is valid (yamllint)"
    else
        error "  YAML validation failed! Restoring backups..."
    fi
elif command -v python3 &> /dev/null; then
    # Use Python's YAML parser as fallback
    for file in "$UBUNTU_WORKFLOW" "$MACOS_WORKFLOW"; do
        if python3 -c "import yaml, sys; yaml.safe_load(open('$file'))" 2>/dev/null; then
            success "  $(basename $file) syntax is valid (Python)"
        else
            error "  YAML validation failed for $file! Restoring backups..."
        fi
    done
else
    warning "  No YAML validator found (yamllint or python3). Skipping validation."
    warning "  Install yamllint with: pip install yamllint"
fi

# Verify the changes were made correctly
if grep -q "DEFAULT_GCC_VERSION: '${GCC_VERSION}'" "$UBUNTU_WORKFLOW" && \
   grep -q "DEFAULT_KOS_VERSION: '${KOS_VERSION_WITH_V}'" "$UBUNTU_WORKFLOW" && \
   grep -q "DEFAULT_GCC_VERSION: '${GCC_VERSION}'" "$MACOS_WORKFLOW" && \
   grep -q "DEFAULT_KOS_VERSION: '${KOS_VERSION_WITH_V}'" "$MACOS_WORKFLOW"; then
    success "  Version numbers correctly updated in both files"
else
    error "  Version update verification failed! Restoring backups..."
fi

# Remove backups
rm -f "${UBUNTU_WORKFLOW}.backup" "${MACOS_WORKFLOW}.backup"

echo ""

#=============================================================================
# Step 4: Git Operations
#=============================================================================
info "Step 4/5: Committing changes..."

# Check for uncommitted changes
if ! git diff --quiet; then
    info "  Staging workflow files..."
    git add "$UBUNTU_WORKFLOW" "$MACOS_WORKFLOW"
    
    COMMIT_MSG="Release: GCC ${GCC_VERSION} + KallistiOS ${KOS_VERSION_WITH_V}"
    info "  Committing: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
    success "  Changes committed"
else
    warning "  No changes to commit"
fi

# Check if tag already exists
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    error "Tag $TAG_NAME already exists locally! Delete it first with: git tag -d $TAG_NAME"
fi

info "  Creating tag: $TAG_NAME"
git tag "$TAG_NAME"
success "  Tag created"

echo ""

#=============================================================================
# Step 5: Push to GitHub
#=============================================================================
info "Step 5/5: Pushing to GitHub..."

# Show what will be pushed
echo ""
echo "  ${YELLOW}Ready to push:${NC}"
echo "    - Commit: $COMMIT_MSG"
echo "    - Tag: $TAG_NAME"
echo ""
echo "  ${YELLOW}This will trigger GitHub Actions to:${NC}"
echo "    - Build toolchain for Linux x86_64"
echo "    - Build toolchain for macOS ARM64"
echo "    - Create GitHub Release at:"
echo "      https://github.com/drpaneas/dreamcast-toolchain-builds/releases/tag/$TAG_NAME"
echo ""

# Confirmation prompt
read -p "  Continue with push? (yes/no): " -r
echo ""
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    warning "Push cancelled. To push manually:"
    echo "    git push"
    echo "    git push origin $TAG_NAME"
    exit 0
fi

# Push commit
info "  Pushing commit to origin..."
if git push; then
    success "  Commit pushed"
else
    error "  Failed to push commit"
fi

# Push tag
info "  Pushing tag to origin..."
if git push origin "$TAG_NAME"; then
    success "  Tag pushed"
else
    error "  Failed to push tag"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║              🎉 Release Initiated! 🎉                 ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
success "Release ${TAG_NAME} is now building!"
echo ""
info "Next steps:"
echo "  1. Watch builds: https://github.com/drpaneas/dreamcast-toolchain-builds/actions"
echo "  2. View release (when ready): https://github.com/drpaneas/dreamcast-toolchain-builds/releases/tag/${TAG_NAME}"
echo "  3. Build time: ~45-60 minutes per platform"
echo ""
info "Expected artifacts:"
echo "  - dreamcast-toolchain-gcc${GCC_VERSION}-kos${KOS_VERSION}-linux-x86_64.tar.gz"
echo "  - dreamcast-toolchain-gcc${GCC_VERSION}-kos${KOS_VERSION}-darwin-arm64.tar.gz"
echo ""

