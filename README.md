# Dreamcast Toolchain Builds

Pre-built development toolchain for **Sega Dreamcast** homebrew development. No compilation required — just download, extract, and start coding.

## Quick Start

### 1. Download

Go to [**Releases**](https://github.com/drpaneas/dreamcast-toolchain-builds/releases) and download the tarball for your platform:

| Platform | File |
|----------|------|
| Linux x86_64 | `dreamcast-toolchain-gcc*-kos*-linux-x86_64.tar.gz` |
| Linux ARM64 (aarch64) | `dreamcast-toolchain-gcc*-kos*-linux-arm64.tar.gz` |
| macOS ARM64 (Apple Silicon) | `dreamcast-toolchain-gcc*-kos*-darwin-arm64.tar.gz` |

> ⚠️ **Important**: Download the correct version for your OS! Linux binaries won't work on macOS and vice versa.

### 2. Extract

```bash
# Create a directory for the toolchain (you can use any location)
mkdir -p ~/dreamcast
cd ~/dreamcast

# Extract (adjust filename for your platform and version)
# For Linux x86_64:
tar xzf ~/Downloads/dreamcast-toolchain-gcc15.1.0-kos2.2.1-linux-x86_64.tar.gz

# For Linux ARM64:
tar xzf ~/Downloads/dreamcast-toolchain-gcc15.1.0-kos2.2.1-linux-arm64.tar.gz

# For macOS ARM64:
tar xzf ~/Downloads/dreamcast-toolchain-gcc15.1.0-kos2.2.1-darwin-arm64.tar.gz
```

After extraction, you'll have:
```
~/dreamcast/
├── sh-elf/          # GCC cross-compiler for Dreamcast's SH4 CPU
├── kos/             # KallistiOS SDK (headers, libraries, tools)
└── kos-ports/       # Additional libraries (libpng, libjpeg, etc.)
```

> 💡 **Verify extraction**: Run `ls ~/dreamcast` — you should see all three directories: `sh-elf`, `kos`, and `kos-ports`.

### 3. Set Up Environment

The toolchain includes a pre-configured `environ.sh` that **auto-detects** the installation path. Add this to your shell configuration:

**For Bash** (add to `~/.bashrc`):
```bash
# Dreamcast toolchain - source the KOS environment
source ~/dreamcast/kos/environ.sh
```

**For Zsh** (add to `~/.zshrc`):
```bash
# Dreamcast toolchain - source the KOS environment
source ~/dreamcast/kos/environ.sh
```

Then reload your shell:
```bash
# For Bash:
source ~/.bashrc

# For Zsh:
source ~/.zshrc
```

> ⚠️ **Note**: You must use `source` (or `.`) to load the environment. Running `./environ.sh` directly won't work because environment variables set in a subprocess don't affect your current shell.

### 4. Verify Installation

```bash
# Check GCC version
sh-elf-gcc --version
# Should show: sh-elf-gcc (GCC) 15.1.0 (or similar)

# Check KOS_BASE points to your installation
echo $KOS_BASE
# Should show: /Users/youruser/dreamcast/kos (or wherever you extracted)

# Check kos-cc wrapper is available
which kos-cc
# Should show: /Users/youruser/dreamcast/kos/utils/build_wrappers/kos-cc

# Verify the correct toolchain is in PATH
which sh-elf-gcc
# Should show: /Users/youruser/dreamcast/sh-elf/bin/sh-elf-gcc
```

If `$KOS_BASE` shows your actual path (not `/opt/toolchains/dc/kos`), the environment is correctly configured!

> **Note**: The `environ.sh` script automatically **prepends** the toolchain paths to your `$PATH`. This ensures this toolchain takes precedence even if you have another KOS installation. The paths added are:
> - `$KOS_CC_BASE/bin` (sh-elf-gcc, etc.)
> - `$KOS_BASE/utils/build_wrappers` (kos-cc, etc.)

### Quick Verification (One-liner)

Run this to verify everything is set up correctly:

```bash
source ~/dreamcast/kos/environ.sh && sh-elf-gcc --version
```

Expected output:
```
KallistiOS environment loaded:
  KOS_BASE:    /Users/youruser/dreamcast/kos
  KOS_CC_BASE: /Users/youruser/dreamcast/sh-elf
  KOS_PORTS:   /Users/youruser/dreamcast/kos-ports
  GCC version: 15.1.0
  PATH updated: /Users/youruser/dreamcast/sh-elf/bin and /Users/youruser/dreamcast/kos/utils/build_wrappers prepended
sh-elf-gcc (GCC) 15.1.0
Copyright (C) 2025 Free Software Foundation, Inc.
...
```

The paths shown should match where you extracted the toolchain (e.g., `/Users/youruser/dreamcast/`), NOT hardcoded paths like `/opt/toolchains/dc/`.

---

## Your First Dreamcast Program

Let's create a simple program that displays "Hello Dreamcast!" on screen.

### 1. Create Project Directory

```bash
mkdir -p ~/projects/hello-dc
cd ~/projects/hello-dc
```

### 2. Create the Source File

Create `main.c`:

```c
#include <kos.h>
#include <dc/biosfont.h>

int main(int argc, char *argv[]) {
    // Initialize video (640x480, RGB565)
    vid_set_mode(DM_640x480, PM_RGB565);
    
    // Clear screen to dark blue
    vid_clear(0x10, 0x10, 0x40);
    
    // Draw text using BIOS font
    bfont_draw_str(vram_s + 100 * 640 + 200, 640, 1, "Hello Dreamcast!");
    bfont_draw_str(vram_s + 130 * 640 + 180, 640, 1, "Press START to exit");
    
    // Wait for START button
    while(1) {
        MAPLE_FOREACH_BEGIN(MAPLE_FUNC_CONTROLLER, cont_state_t, st)
            if(st->buttons & CONT_START)
                arch_exit();
        MAPLE_FOREACH_END()
        
        thd_sleep(20);
    }
    
    return 0;
}
```

### 3. Create the Makefile

Create `Makefile`:

```makefile
# KallistiOS Makefile for Dreamcast

# Target binary name
TARGET = hello.elf

# Source files (list .o files corresponding to your .c files)
OBJS = main.o

# Include KallistiOS build rules
# Note: KOS_BASE is set automatically when you source environ.sh
include $(KOS_BASE)/Makefile.rules

# Main target
all: rm-elf $(TARGET)

# Link the final executable
$(TARGET): $(OBJS)
	kos-cc -o $(TARGET) $(OBJS)

# Clean build artifacts
clean: rm-elf
	-rm -f $(OBJS)

rm-elf:
	-rm -f $(TARGET)

# Convert to raw binary (for CD burning)
%.bin: %.elf
	$(KOS_OBJCOPY) -O binary $< $@

# Run on hardware (requires dc-tool)
run: $(TARGET)
	$(KOS_LOADER) $(TARGET)
```

### 4. Build

```bash
# Make sure environment is loaded (if not in .bashrc)
source ~/dreamcast/kos/environ.sh

# Build
make
```

You should see:
```
kos-cc  -c main.c -o main.o
kos-cc -o hello.elf main.o
```

### 5. Run on Emulator or Real Hardware

**Option A: Using an Emulator (lxdream, flycast, redream)**

```bash
# Install an emulator (example: flycast on Linux)
flatpak install flathub org.flycast.Flycast

# Run your program
flycast hello.elf
```

**Option B: Using a Dreamcast with SD Card Adapter (GDEMU, MODE, etc.)**

1. Convert to a bootable CDI image using `mkdcdisc` (included in toolchain):
   ```bash
   mkdcdisc -e hello.elf -o hello.cdi -n "HELLO"
   ```

2. Copy `hello.cdi` to your SD card and boot on your Dreamcast.

**Option C: Using Serial/BBA and dcload**

If you have a Broadband Adapter or serial cable with dcload:
```bash
dc-tool -x hello.elf
```

---

## Environment Variables Reference

When you source `environ.sh`, these variables are set automatically:

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `KOS_BASE` | KallistiOS root directory | `/home/user/dreamcast/kos` |
| `KOS_CC_BASE` | SH4 compiler directory | `/home/user/dreamcast/sh-elf` |
| `KOS_PORTS` | kos-ports directory | `/home/user/dreamcast/kos-ports` |
| `KOS_ARCH` | Target architecture | `dreamcast` |
| `KOS_SUBARCH` | Sub-architecture | `pristine` |
| `KOS_CC` | C compiler | `/home/user/dreamcast/sh-elf/bin/sh-elf-gcc` |
| `KOS_CFLAGS` | Default C flags | `-O2 -m4-single -ml ...` |
| `KOS_LDFLAGS` | Default linker flags | Link paths and options |
| `KOS_GCCVER` | GCC version | `15.1.0` |

---

## Makefile Templates

### Basic C Project

```makefile
TARGET = myproject.elf
OBJS = main.o utils.o graphics.o

include $(KOS_BASE)/Makefile.rules

all: rm-elf $(TARGET)

$(TARGET): $(OBJS)
	kos-cc -o $(TARGET) $(OBJS)

clean: rm-elf
	-rm -f $(OBJS)

rm-elf:
	-rm -f $(TARGET)
```

### Project with Romdisk (Embedded Files)

```makefile
TARGET = myproject.elf
OBJS = main.o romdisk.o

# Directory containing files to embed
KOS_ROMDISK_DIR = romdisk

include $(KOS_BASE)/Makefile.rules

all: rm-elf $(TARGET)

$(TARGET): $(OBJS)
	kos-cc -o $(TARGET) $(OBJS)

clean: rm-elf
	-rm -f $(OBJS) romdisk.img

rm-elf:
	-rm -f $(TARGET)
```

### Using kos-ports Libraries (libpng, libjpeg, etc.)

```makefile
TARGET = myproject.elf
OBJS = main.o

# Additional libraries from kos-ports
KOS_LIBS = -lpng -lz

include $(KOS_BASE)/Makefile.rules

all: rm-elf $(TARGET)

$(TARGET): $(OBJS)
	kos-cc -o $(TARGET) $(OBJS) $(KOS_LIBS)

clean: rm-elf
	-rm -f $(OBJS)

rm-elf:
	-rm -f $(TARGET)
```

### C++ Project with OpenGL

```makefile
TARGET = myproject.elf
OBJS = main.o graphics.o

# Link order matters! Put dependencies after dependents
KOS_LIBS = -lGL -lpng -lz -lm

include $(KOS_BASE)/Makefile.rules

# Use C++ compiler
KOS_CFLAGS += -std=c++17

all: rm-elf $(TARGET)

$(TARGET): $(OBJS)
	kos-c++ -o $(TARGET) $(OBJS) $(KOS_LIBS)

clean: rm-elf
	-rm -f $(OBJS)

rm-elf:
	-rm -f $(TARGET)
```

### Available kos-ports Libraries

To see all available libraries:
```bash
ls ~/dreamcast/kos-ports/lib/
```

Common libraries and their link flags:

| Library | Link Flag | Description |
|---------|-----------|-------------|
| libpng | `-lpng -lz` | PNG image loading |
| libjpeg | `-ljpeg` | JPEG image loading |
| zlib | `-lz` | Compression |
| freetype | `-lfreetype -lz` | TrueType fonts |
| SDL | `-lSDL` | Simple DirectMedia Layer |
| libGL | `-lGL` | OpenGL-like 3D graphics |
| libogg + libvorbis | `-lvorbisfile -lvorbis -logg` | OGG audio |
| opus | `-lopusfile -lopus -logg` | Opus audio |
| lua | `-llua` | Lua scripting |
| curl | `-lcurl -lbearssl` | HTTP client |

---

## More Examples

The toolchain includes many example programs:

```bash
# List available examples
ls ~/dreamcast/kos/examples/dreamcast/

# Build all examples
cd ~/dreamcast/kos/examples
make
```

Notable examples:
- `hello/` - Simple hello world
- `pvr/` - 3D graphics with PowerVR
- `sound/` - Audio playback
- `basic/` - Controller input, VMU, etc.
- `gldc/` - OpenGL-like graphics
- `network/` - Networking with BBA

---

## Using Graphics (PowerVR)

The Dreamcast has a PowerVR GPU. Here's a minimal 3D example:

```c
#include <kos.h>
#include <dc/pvr.h>

int main(int argc, char *argv[]) {
    pvr_init_defaults();
    
    while(1) {
        pvr_wait_ready();
        pvr_scene_begin();
        
        pvr_list_begin(PVR_LIST_OP_POLY);
        // Draw opaque polygons here
        pvr_list_finish();
        
        pvr_list_begin(PVR_LIST_TR_POLY);
        // Draw transparent polygons here
        pvr_list_finish();
        
        pvr_scene_finish();
    }
    
    return 0;
}
```

---

## Project Structure Reference

When you extract the toolchain:

```
sh-elf/
├── bin/
│   ├── sh-elf-gcc        # C compiler
│   ├── sh-elf-g++        # C++ compiler
│   ├── sh-elf-gccgo      # Go compiler
│   ├── sh-elf-as         # Assembler
│   ├── sh-elf-ld         # Linker
│   └── sh-elf-ar         # Archive tool
└── lib/gcc/sh-elf/*/
    └── libgcc.a          # GCC runtime

kos/
├── include/              # KallistiOS headers
│   └── kos.h             # Main header (include this)
├── lib/dreamcast/
│   ├── libkallisti.a     # KOS kernel library
│   └── *.a               # Other libraries
├── kernel/arch/dreamcast/include/dc/
│   ├── pvr.h             # PowerVR graphics
│   ├── maple.h           # Controller/peripherals
│   ├── sound/            # Audio headers
│   └── ...
├── utils/build_wrappers/
│   ├── kos-cc            # C compiler wrapper
│   └── kos-c++           # C++ compiler wrapper
├── environ.sh            # Environment setup script (source this!)
├── Makefile.rules        # Include in your Makefile
└── examples/             # Example programs

kos-ports/
├── include/              # Port headers
├── lib/                  # Compiled port libraries
└── */                    # Individual ports (libpng, zlib, etc.)
```

---

## Troubleshooting

### Missing `kos-ports` directory after extraction
If you only see `sh-elf` and `kos` but not `kos-ports`, you may have downloaded an older release. Download the latest release which includes all three directories.

### `$KOS_BASE` shows `/opt/toolchains/dc/kos` instead of your path
Your `environ.sh` has hardcoded paths from an older release. The new releases include an auto-detecting `environ.sh`. Either:
1. Download the latest release, or
2. The `environ.sh` should auto-detect paths. Check that it contains `BASH_SOURCE` logic.

### "Permission denied" when running `./environ.sh`
**Don't run it with `./`** — you must use `source`:
```bash
# WRONG - runs in subshell, variables don't persist:
./environ.sh

# CORRECT - loads variables into current shell:
source ~/dreamcast/kos/environ.sh
# or equivalently:
. ~/dreamcast/kos/environ.sh
```

### "sh-elf-gcc: command not found"
Make sure you've sourced the environment:
```bash
source ~/dreamcast/kos/environ.sh
echo $PATH  # Should include sh-elf/bin
```

### "kos.h: No such file or directory"
The KOS environment wasn't loaded. Source `environ.sh` before building:
```bash
source ~/dreamcast/kos/environ.sh
make clean && make
```

### "undefined reference to `pvr_*`" or similar
You need to link with the correct libraries. Make sure your Makefile uses `kos-cc` for linking, which automatically adds the right library paths.

### Build errors about missing `arm-eabi-*`
The ARM toolchain (for AICA sound processor) is not included. Most projects don't need it. If you need to compile custom sound drivers, you'll need to build the ARM toolchain separately.

### Wrong platform (e.g., Linux binary on macOS)
Make sure you downloaded the correct tarball for your platform:
- **Linux x86_64**: `*-linux-x86_64.tar.gz`
- **Linux ARM64**: `*-linux-arm64.tar.gz`
- **macOS (Apple Silicon)**: `*-darwin-arm64.tar.gz`

Binaries for one platform will not work on another.

---

## Included Components

This toolchain distribution includes:

- **GCC** cross-compiler for SH4 with:
  - C support
  - C++ support
  - Go support (gccgo)
- **Binutils** (assembler, linker, etc.)
- **KallistiOS** SDK with all libraries pre-built
- **kos-ports** pre-built libraries:
  - SDL, SDL_ttf
  - libpng, libjpeg, libtga
  - zlib, libbz2, libzip
  - freetype
  - lua, micropython
  - libGL, libKGL (OpenGL-like APIs)
  - libogg, libvorbis, opus, opusfile
  - libmp3, libADX
  - curl, libbearssl, libsmb2
  - And many more...

### What's NOT Included

- **ARM toolchain** (arm-eabi-*) for AICA sound processor custom drivers
- **Objective-C support** - Not built to reduce toolchain size
- **mruby** - Disabled due to build system incompatibility with modern bison

If you need the ARM toolchain or Objective-C support, you'll need to build them yourself using [dc-chain](https://github.com/KallistiOS/KallistiOS/tree/master/utils/dc-chain).

### Disabled Components

The following components are intentionally disabled in this distribution because they don't build reliably across platforms:

| Component | Reason |
|-----------|--------|
| `kos-ports/mruby` | Bison parser incompatibility with mruby 3.3.0 |
| `examples/dreamcast/mruby/*` | Depends on mruby port |
| `examples/dreamcast/objc/runtime` | Requires Objective-C compiler |

These are disabled by renaming their Makefiles to `Makefile.disabled`. If you need them, you can try re-enabling by renaming back to `Makefile`, but builds may fail.

---

## Links

- [KallistiOS Documentation](http://gamedev.allusion.net/docs/kos-2.0.0/)
- [KallistiOS GitHub](https://github.com/KallistiOS/KallistiOS)
- [Dreamcast Programming Wiki](https://dreamcast.wiki/)
- [Simulant Engine](https://gitlab.com/simulant/simulant) - Game engine for Dreamcast

---

## License

This toolchain distribution includes:
- **GCC & Binutils**: GPL v3 (with Runtime Library Exception for your code)
- **KallistiOS**: BSD License
- **Build scripts**: MIT License

You can develop and distribute both open-source and proprietary Dreamcast software using this toolchain.

See [LICENSE](LICENSE) and [NOTICE](NOTICE) for details.
