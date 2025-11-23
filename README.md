# Dreamcast Toolchain Builds

Automated builds of the Dreamcast cross-compilation toolchain with GCC Go support and KallistiOS.

This repository provides **pre-built**, **version-locked** toolchains for Dreamcast development, eliminating the need to compile GCC and KallistiOS yourself.

## 🎯 What This Provides

Complete development environment for Sega Dreamcast:
- **GCC with Go support** - Cross-compiler with gccgo frontend for SH-4
- **C compiler** - Full C language support  
- **KallistiOS** - Complete operating system and libraries
- **Binutils** - Assembler, linker, and binary utilities
- **All pre-built and tested together!**

## 📥 Downloads

**[View All Releases →](https://github.com/drpaneas/dreamcast-toolchain-builds/releases)**

Pre-built binaries are available for:
- **Linux** x86_64
- **macOS** Apple Silicon (ARM64)

Each release includes:
- Toolchain tarball (`.tar.gz`)
- SHA-256 checksum for verification
- LICENSE and NOTICE files

## 🚀 Quick Start

### Download and Install

```bash
# Download the latest release for your platform
GCC_VERSION="15.1.0"
KOS_VERSION="2.2.1"
PLATFORM="linux-x86_64"  # or darwin-arm64

curl -L "https://github.com/drpaneas/dreamcast-toolchain-builds/releases/download/gcc${GCC_VERSION}-kos${KOS_VERSION}/dreamcast-toolchain-gcc${GCC_VERSION}-kos${KOS_VERSION}-${PLATFORM}.tar.gz" -o toolchain.tar.gz

# Extract
tar xzf toolchain.tar.gz

# Add to PATH
export PATH="$PWD/kos/bin:$PATH"

# Verify installation
sh-elf-gcc --version
```

### Verify Checksums

```bash
# Download checksum
curl -L "https://github.com/drpaneas/dreamcast-toolchain-builds/releases/download/gcc${GCC_VERSION}-kos${KOS_VERSION}/dreamcast-toolchain-gcc${GCC_VERSION}-kos${KOS_VERSION}-${PLATFORM}.tar.gz.sha256" -o toolchain.sha256

# Verify (Linux)
sha256sum -c toolchain.sha256

# Verify (macOS)
shasum -a 256 -c toolchain.sha256
```

## 📦 What's Included

```
kos/
├── bin/
│   ├── sh-elf-gcc         C/C++ compiler
│   ├── sh-elf-gccgo       Go compiler frontend
│   ├── sh-elf-as          Assembler
│   ├── sh-elf-ld          Linker
│   ├── sh-elf-ar          Archiver
│   └── ...                Other utilities
│
├── sh-elf/
│   ├── lib/               GCC runtime libraries
│   └── include/           GCC headers
│
├── kos/
│   ├── lib/
│   │   ├── libkallisti.a  KallistiOS kernel
│   │   ├── libgl.a        PowerVR OpenGL
│   │   ├── libpng.a       PNG support
│   │   └── ...            Other libraries
│   └── include/
│       ├── kos.h          Main KOS header
│       └── dc/            Dreamcast-specific headers
│
├── LICENSE                License information
└── NOTICE                 Third-party attributions
```

## 🛠️ Supported Platforms

| Platform | Architecture | Status |
|----------|--------------|--------|
| Linux | x86_64 | ✅ Supported |
| macOS | Apple Silicon (ARM64) | ✅ Supported |

## 🔧 Creating a New Release

### Automated Release Script (Recommended)

Use the `release.sh` script to automate the entire release process:

```bash
# Make script executable (first time only)
chmod +x release.sh

# Create release with specific versions
./release.sh 16.0.0 2.3.0

# The script will:
# 1. Verify both versions exist upstream
# 2. Update workflow files automatically
# 3. Validate YAML syntax
# 4. Commit, tag, and push to GitHub
# 5. Trigger automated builds
```

### Manual Release Process

If you prefer to do it manually:

1. Edit `.github/workflows/build-ubuntu.yml` and `.github/workflows/build-macos.yml`
2. Change `DEFAULT_GCC_VERSION` and `DEFAULT_KOS_VERSION`
3. Commit: `git commit -am "Release: GCC 16.0.0 + KOS v2.3.0"`
4. Tag: `git tag gcc16.0.0-kos2.3.0`
5. Push: `git push && git push origin gcc16.0.0-kos2.3.0`

## 🔧 Building from Source

Don't want to use pre-built binaries? The GitHub Actions workflows in `.github/workflows/` show exactly how the toolchains are built.

The build process:
1. Downloads the specified [KallistiOS release](https://github.com/KallistiOS/KallistiOS/releases)
2. Uses KallistiOS's `dc-chain` toolchain builder
3. Configures for GCC with C and Go support
4. Builds and packages everything

You can trigger manual builds via GitHub Actions or run the workflows locally.

## 📋 Version Information

Each release is tagged and titled with both GCC and KallistiOS versions:
- **Tag format:** `gccX.Y.Z-kosX.Y.Z` (e.g., `gcc15.1.0-kos2.2.1`)
- **Release title:** `Dreamcast Toolchain - GCC X.Y.Z + KallistiOS vX.Y.Z`
- **Artifact naming:** `dreamcast-toolchain-gccX.Y.Z-kosX.Y.Z-PLATFORM.tar.gz`

The toolchain includes:
- **GCC**: Version from tag (e.g., 15.1.0)
- **KallistiOS**: Version from tag (e.g., [v2.2.1](https://github.com/KallistiOS/KallistiOS/releases/tag/v2.2.1))
- **Binutils**: Latest compatible version from dc-chain

All components are version-locked for reproducible builds.

## 🎮 Usage with godc

This toolchain is designed to work seamlessly with [godc](https://github.com/drpaneas/godc), a Go-to-Dreamcast compiler:

```bash
# Install godc
go install github.com/drpaneas/godc/cmd/godc@latest

# godc can automatically download and use these toolchains
godc setup --auto-download
```

## 📄 License

This project distributes several components with different licenses:

- **GCC & Binutils**: GNU General Public License v3 (GPLv3)
- **KallistiOS**: BSD-style License
- **Build scripts & workflows**: MIT License

**Source code availability** (GPL compliance):
- GCC source: https://ftp.gnu.org/gnu/gcc/
- Binutils source: https://ftp.gnu.org/gnu/binutils/
- KallistiOS source: https://github.com/KallistiOS/KallistiOS
- Build workflows: This repository

See [LICENSE](LICENSE) and [NOTICE](NOTICE) files for complete details.

## 🤝 Contributing

Contributions are welcome! Please feel free to:
- Report issues
- Suggest improvements
- Submit pull requests

## 🔗 Related Projects

- [KallistiOS](https://github.com/KallistiOS/KallistiOS) - The Dreamcast operating system
- [godc](https://github.com/drpaneas/godc) - Go compiler for Dreamcast
- [GCC](https://gcc.gnu.org/) - The GNU Compiler Collection

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/drpaneas/dreamcast-toolchain-builds/issues)
- **KallistiOS Community**: [Discord](https://discord.gg/cnKPrwB)

---

**Note**: This is an automated build repository. The actual toolchain components are developed and maintained by their respective upstream projects (GCC, KallistiOS, etc.). This repository simply provides convenient pre-built packages.
