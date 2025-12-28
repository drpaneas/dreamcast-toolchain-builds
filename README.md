# Dreamcast Toolchain Builds

Pre-built development toolchain for Sega Dreamcast. No compilation required.

## Download

Go to [Releases](https://github.com/drpaneas/dreamcast-toolchain-builds/releases) and download for your platform:

| Platform | File |
|----------|------|
| Linux x86_64 | `dreamcast-toolchain-*-linux-x86_64.tar.gz` |
| Linux ARM64 | `dreamcast-toolchain-*-linux-arm64.tar.gz` |
| macOS ARM64 | `dreamcast-toolchain-*-darwin-arm64.tar.gz` |

## Install

```bash
mkdir -p ~/dreamcast
tar xzf dreamcast-toolchain-*.tar.gz -C ~/dreamcast
```

You'll have:

```
~/dreamcast/
├── kos/             # KallistiOS SDK
├── kos-ports/       # Additional libraries (libpng, zlib, etc.)
├── libgodc/         # Go runtime for Dreamcast
└── sh-elf/          # GCC cross-compiler (C, C++, Go)
```

## Setup Environment

Add to `~/.bashrc` or `~/.zshrc`:

```bash
source ~/dreamcast/kos/environ.sh
```

Reload your shell, then verify:

```bash
sh-elf-gcc --version
echo $KOS_BASE
```

## What's Included

- **GCC 15.1.0** cross-compiler (C, C++, Go)
- **KallistiOS 2.2.1** SDK
- **kos-ports** libraries (libpng, libjpeg, zlib, SDL, freetype, lua, libGL, etc.)
- **libgodc** Go runtime

## Links

- [KallistiOS GitHub](https://github.com/KallistiOS/KallistiOS)
- [libgodc Documentation](https://drpaneas.github.io/libgodc/)

## License

GCC & Binutils: GPL v3 | KallistiOS: BSD | libgodc: BSD 3-Clause
