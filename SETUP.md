# How to Set Up toolchain-builds Repository

This directory contains template files for creating the `dreamcast-toolchain-builds` repository.

## 🎯 Purpose

Create a separate repository that:
1. Builds GCC cross-compiler with gccgo support
2. Builds KallistiOS with that GCC (version-locked!)
3. Packages everything for Mac/Linux/Windows
4. Publishes to GitHub Releases
5. Auto-builds via GitHub Actions

---

## 📋 Setup Steps

### Step 1: Create New GitHub Repository

```bash
# On GitHub.com:
# 1. Click "New Repository"
# 2. Name: "dreamcast-toolchain-builds"
# 3. Description: "Pre-built Dreamcast cross-compilation toolchain with gccgo and KallistiOS"
# 4. Public
# 5. Create repository
```

### Step 2: Copy Template Files

```bash
# Clone the new repo
git clone https://github.com/drpaneas/dreamcast-toolchain-builds.git
cd dreamcast-toolchain-builds

# Copy files from this template
cp -r /path/to/godc/toolchain-builds-template/* .
cp -r /path/to/godc/toolchain-builds-template/.github .

# Initial commit
git add .
git commit -m "Initial toolchain build system"
git push
```

### Step 3: Test Build Locally (macOS)

```bash
# Make script executable
chmod +x scripts/build-toolchain.sh

# Build (takes 30-60 minutes)
./scripts/build-toolchain.sh

# Check output
ls -lh build/dreamcast-toolchain-*.tar.gz
```

**Expected**: `dreamcast-toolchain-v2.0.0-darwin-arm64.tar.gz` (~200MB)

### Step 4: Test the Built Toolchain

```bash
# Extract to test location
mkdir -p /tmp/test-toolchain
tar xzf build/dreamcast-toolchain-*.tar.gz -C /tmp/test-toolchain

# Add to PATH
export PATH="/tmp/test-toolchain/dreamcast-toolchain/bin:$PATH"

# Test compiler
sh-elf-gccgo --version
# Should show: sh-elf-gccgo (GCC) 15.2.0

# Test KOS libraries
ls /tmp/test-toolchain/dreamcast-toolchain/kos/lib/
# Should show: libkallisti.a libgl.a ...
```

### Step 5: Create First Release

```bash
# Tag the release
git tag v2.0.0
git push --tags
```

**GitHub Actions will**:
1. Detect the tag
2. Build toolchain for all platforms (2-3 hours)
3. Upload to Releases automatically

**Check progress**:
- Go to: Actions tab on GitHub
- Watch the builds complete
- Download from Releases when done

### Step 6: Test Auto-Download

```bash
# On a different machine:
go install github.com/drpaneas/godc/cmd/godc@latest
godc setup

# Should download from your new release!
```

---

## 📁 Repository Structure

```
dreamcast-toolchain-builds/
├── README.md
├── LICENSE
├── SETUP.md (this file)
│
├── .github/
│   └── workflows/
│       ├── build-macos-arm64.yml
│       ├── build-macos-x86_64.yml
│       └── build-linux-x86_64.yml
│
├── scripts/
│   └── build-toolchain.sh
│
└── docs/
    └── BUILD.md (optional: detailed build instructions)
```

---

## 🔧 Customization

### Changing Versions

Edit `scripts/build-toolchain.sh`:

```bash
GCC_VERSION="15.2.0"      # Change GCC version
BINUTILS_VERSION="2.43"   # Change binutils version
# Then update KOS version in the script
```

### Adding New Platforms

Copy an existing workflow and modify:

```yaml
# .github/workflows/build-linux-arm64.yml
jobs:
  build-linux-arm64:
    runs-on: ubuntu-latest  # Use ARM runner or cross-compile
    # ... modify steps as needed
```

---

## 📊 Build Times (Reference)

| Platform | Time | Size |
|----------|------|------|
| macOS ARM64 | 45 min | 187 MB |
| macOS x86_64 | 50 min | 191 MB |
| Linux x86_64 | 40 min | 183 MB |

GitHub Actions free tier: 2000 minutes/month (enough for ~40 builds)

---

## 🎯 Release Checklist

When creating a new release:

- [ ] Update VERSION in build script
- [ ] Update GCC_VERSION if needed
- [ ] Update KOS to stable tag
- [ ] Test build locally
- [ ] Create git tag: `git tag v2.1.0`
- [ ] Push tag: `git push --tags`
- [ ] Wait for GitHub Actions
- [ ] Test downloads
- [ ] Update godc to recommend new version

---

## 🔐 Security

### Checksums

Each release includes SHA256 checksums:
```bash
# Verify download
shasum -a 256 -c dreamcast-toolchain-v2.0.0-darwin-arm64.tar.gz.sha256
```

### Reproducible Builds

The build script uses specific versions:
- GCC 15.2.0 (released version)
- Binutils 2.43 (released version)
- KOS 2.0.0 (git tag)

Same inputs = same outputs

---

## 📝 Maintaining

### Updating for New GCC Version

1. Edit `build-toolchain.sh`:
   - Change `GCC_VERSION="15.3.0"`
2. Test build locally
3. Create new release: `v2.1.0`
4. Update godc's `ToolchainVersion` constant

### Updating for New KOS Version

1. Edit `build-toolchain.sh`:
   - Change git checkout in KOS section
2. Test build
3. Create new release
4. Test compatibility with godc

---

## ✅ Success Criteria

After setup, these should work:

```bash
# Check toolchain
sh-elf-gccgo --version
# sh-elf-gccgo (GCC) 15.2.0

# Check godc
godc version
# godc version 0.2.0

# Build example
cd godc/examples/hello
godc build main.go
# ✓ Built main.elf successfully!
```

All ✅? You're done! 🎉

---

This template is ready to use. Create the repository and follow the steps above!

