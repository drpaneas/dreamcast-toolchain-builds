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

# Set up environment (run this in each new shell session)
cd sh-elf  # or wherever you extracted
export PATH="$PWD/sh-elf/bin:$PATH"
export KOS_BASE="$PWD/kos"
source $KOS_BASE/environ.sh

# Verify installation
sh-elf-gcc --version
sh-elf-gccgo --version
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
sh-elf/                        SH-4 Cross-Compiler
├── bin/
│   ├── sh-elf-gcc             C/C++ compiler
│   ├── sh-elf-gccgo           Go compiler frontend
│   ├── sh-elf-as              Assembler
│   ├── sh-elf-ld              Linker
│   ├── sh-elf-ar              Archiver
│   └── ...                    Other binutils
├── lib/                       GCC runtime libraries
└── sh-elf/
    ├── lib/                   Target libraries (libgcc, etc.)
    └── include/               GCC headers

kos/                           KallistiOS
├── lib/
│   ├── libkallisti.a          KallistiOS kernel
│   ├── libgl.a                PowerVR OpenGL
│   ├── libpng.a               PNG support
│   └── ...                    Other libraries
├── include/
│   ├── kos.h                  Main KOS header
│   └── ...                    General headers
├── kernel/arch/dreamcast/     Dreamcast kernel source
│   ├── include/dc/            Dreamcast-specific headers
│   └── ...                    Kernel implementation
├── utils/
│   ├── build_wrappers/
│   │   └── kos-cc             Build wrapper (essential!)
│   ├── genromfs               ROM filesystem creator
│   ├── makeip                 IP.BIN creator
│   └── scramble               Binary scrambler
├── environ*.sh                Environment setup scripts
├── Makefile.rules             Build rules
├── LICENSE                    License information
└── NOTICE                     Third-party attributions
```

## 🛠️ Supported Platforms

| Platform | Architecture | Status |
|----------|--------------|--------|
| Linux | x86_64 | ✅ Supported |
| macOS | Apple Silicon (ARM64) | ✅ Supported |

## 🎮 Usage

### With godc (Go Development)

This toolchain is designed to work seamlessly with [godc](https://github.com/drpaneas/godc), a Go-to-Dreamcast compiler:

```bash
# Install godc
go install github.com/drpaneas/godc/cmd/godc@latest

# godc can automatically download and use these toolchains
godc setup --auto-download
```

### With KallistiOS (C/C++ Development)

You can also use this for traditional KallistiOS C/C++ development:

```bash
# After extraction and environment setup
cd kos/examples/dreamcast/2ndmix  # Or your own project
make

# The package includes utilities you need:
# - kos-cc wrapper for compilation
# - genromfs for ROM filesystems
# - makeip for bootable CD images
```

**Note**: The toolchain includes the full KallistiOS kernel source and essential utilities, making it suitable for both Go and C development.

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
- [godc](https://github.com/drpaneas/godc) - Go version for Dreamcast
- [GCC](https://gcc.gnu.org/) - The GNU Compiler Collection

---

**Note**: This is an automated build repository. The actual toolchain components are developed and maintained by their respective upstream projects (GCC, KallistiOS, etc.). This repository simply provides convenient pre-built packages.
