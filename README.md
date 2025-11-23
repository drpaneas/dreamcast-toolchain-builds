# Dreamcast Toolchain Builds

Pre-built Dreamcast cross-compilation toolchain with GCC Go support and KallistiOS.

## What This Provides

Complete development environment for Dreamcast:
- **sh-elf-gccgo** - GCC 15.2.0 with Go frontend
- **sh-elf-gcc** - C/C++ compiler
- **Toolchain utilities** - as, ld, ar, objcopy, etc.
- **KallistiOS libraries** - libkallisti.a, libgl.a, etc.
- **KOS headers** - Complete include files

All version-locked and tested together!

## Supported Platforms

| Platform | Architecture | Status |
|----------|--------------|--------|
| macOS | Apple Silicon (ARM64) | ✅ Supported |
| macOS | Intel (x86_64) | ✅ Supported |
| Linux | x86_64 | ✅ Supported |
| Linux | ARM64 | 📅 Planned |
| Windows | x86_64 | 📅 Planned |

## Downloads

See [Releases](https://github.com/drpaneas/dreamcast-toolchain-builds/releases) for downloads.

### Latest: v2.0.0

- GCC: 15.2.0 (with gccgo frontend)
- KallistiOS: 2.0.0
- Built: 2024-11-23

**Downloads**:
- [macOS Apple Silicon](https://github.com/drpaneas/dreamcast-toolchain-builds/releases/download/v2.0.0/dreamcast-toolchain-v2.0.0-darwin-arm64.tar.gz) (187 MB)
- [macOS Intel](https://github.com/drpaneas/dreamcast-toolchain-builds/releases/download/v2.0.0/dreamcast-toolchain-v2.0.0-darwin-x86_64.tar.gz) (191 MB)
- [Linux x86_64](https://github.com/drpaneas/dreamcast-toolchain-builds/releases/download/v2.0.0/dreamcast-toolchain-v2.0.0-linux-x86_64.tar.gz) (183 MB)

## Installation

### Automated (Recommended)

```bash
curl -sSf https://godc.dev/install-toolchain.sh | sh
```

Or with godc tool:
```bash
godc setup --auto-download
```

### Manual

```bash
# Download for your platform
curl -L https://github.com/drpaneas/dreamcast-toolchain-builds/releases/download/v2.0.0/dreamcast-toolchain-v2.0.0-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m).tar.gz -o toolchain.tar.gz

# Extract
mkdir -p ~/.dreamcast
tar xzf toolchain.tar.gz -C ~/.dreamcast

# Add to PATH
echo 'export PATH="$HOME/.dreamcast/dreamcast-toolchain/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify
sh-elf-gccgo --version
```

## What's Included

```
dreamcast-toolchain/
├── bin/
│   ├── sh-elf-gccgo      Cross-compiler with Go support
│   ├── sh-elf-gcc        C/C++ compiler
│   ├── sh-elf-as         Assembler
│   ├── sh-elf-ld         Linker
│   ├── sh-elf-ar         Archiver
│   ├── sh-elf-objcopy    Object file converter
│   ├── sh-elf-objdump    Object file dumper
│   └── kos-cc            KallistiOS wrapper
│
├── sh-elf/
│   ├── lib/              GCC runtime libraries for SH-4
│   └── include/          GCC headers
│
└── kos/
    ├── lib/
    │   ├── libkallisti.a KOS kernel
    │   ├── libgl.a       PowerVR OpenGL
    │   ├── libpng.a      PNG library
    │   ├── libjpeg.a     JPEG library
    │   └── libz.a        Compression
    └── include/
        ├── kos.h         Main KOS header
        ├── dc/           Dreamcast-specific
        └── arch/         Architecture files
```

## Verifying Installation

```bash
# Check compiler
sh-elf-gccgo --version
# Should show: sh-elf-gccgo (GCC) 15.2.0

# Check KOS
ls $HOME/.dreamcast/dreamcast-toolchain/kos/lib/
# Should show: libkallisti.a libgl.a ...

# Build test program
cd /path/to/godc/examples/hello
godc build main.go
# Should succeed!
```

## Building from Source

See [docs/BUILD.md](docs/BUILD.md) for building the toolchain yourself.

## Compatibility

| godc Version | Recommended Toolchain | Status |
|--------------|----------------------|--------|
| v0.2.x | v2.0.0 | ✅ Tested |
| v0.3.x | v2.1.0 | 📅 Future |

## License

- GCC: GPL v3
- KallistiOS: BSD-style
- Build scripts: MIT

See LICENSE file for details.

## Issues

Report issues at: https://github.com/drpaneas/dreamcast-toolchain-builds/issues

