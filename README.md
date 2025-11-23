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

### Download and Extract

```bash
# Download the latest release for your platform
GCC_VERSION="15.1.0"
KOS_VERSION="2.2.1"
PLATFORM="linux-x86_64"  # or darwin-arm64

curl -L "https://github.com/drpaneas/dreamcast-toolchain-builds/releases/download/gcc${GCC_VERSION}-kos${KOS_VERSION}/dreamcast-toolchain-gcc${GCC_VERSION}-kos${KOS_VERSION}-${PLATFORM}.tar.gz" -o toolchain.tar.gz

# Extract to your preferred location
mkdir -p ~/dreamcast-dev
tar xzf toolchain.tar.gz -C ~/dreamcast-dev
cd ~/dreamcast-dev
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

### Option 1: For godc (Go Development)

**godc** handles the toolchain setup automatically. No manual environment configuration needed!

```bash
# Install godc
go install github.com/drpaneas/godc/cmd/godc@latest

# Point godc to the toolchain (one-time setup)
export DREAMCAST_TOOLCHAIN_PATH=~/dreamcast-dev
godc setup

# Build your Go program
cd your-project/
godc build main.go
```

**That's it!** godc automatically uses the toolchain without needing KOS environment variables.

---

### Option 2: For KallistiOS C/C++ Development

For traditional KallistiOS C development, you need to set up the environment:

```bash
# 1. Set up environment (add to your ~/.bashrc or ~/.zshrc)
export KOS_BASE=~/dreamcast-dev/kos
export PATH=~/dreamcast-dev/sh-elf/bin:$PATH
export PATH=$KOS_BASE/utils/build_wrappers:$PATH

# Source the KOS environment
source $KOS_BASE/environ.sh

# 2. Verify the setup
sh-elf-gcc --version
kos-cc --version

# 3. Build a KallistiOS example
cd $KOS_BASE/examples/dreamcast/2ndmix
make

# 4. Or build your own project
cd your-project/
make  # Using a KOS-compatible Makefile
```

**KOS Makefile Template** for your projects:

```makefile
TARGET = myprogram.elf
OBJS = main.o

all: $(TARGET)

include $(KOS_BASE)/Makefile.rules

clean:
	-rm -f $(TARGET) $(OBJS)

$(TARGET): $(OBJS)
	kos-cc -o $(TARGET) $(OBJS)
```

**Included Utilities:**
- `kos-cc` - Wrapper for compilation with correct flags
- `genromfs` - Create ROM filesystems  
- `makeip` - Create IP.BIN for bootable CDs
- `scramble` - Scramble binaries for Dreamcast boot

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
