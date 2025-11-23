# Toolchain Package Verification Checklist

## ✅ What MUST Be Included

### From sh-elf/ (GCC Toolchain)
```
sh-elf/
├── bin/
│   ├── sh-elf-gccgo      ✅ REQUIRED - Go compiler
│   ├── sh-elf-gcc        ✅ REQUIRED - C compiler
│   ├── sh-elf-g++        ✅ REQUIRED - C++ compiler (if building C++ KOS code)
│   ├── sh-elf-as         ✅ REQUIRED - Assembler
│   ├── sh-elf-ld         ✅ REQUIRED - Linker
│   ├── sh-elf-ar         ✅ REQUIRED - Archiver
│   ├── sh-elf-objcopy    ✅ REQUIRED - Object copier
│   ├── sh-elf-objdump    ✅ REQUIRED - Object dumper
│   └── sh-elf-ranlib     ✅ REQUIRED - Library indexer
│
├── lib/                  ✅ REQUIRED - GCC runtime libraries
├── libexec/              ✅ REQUIRED - GCC internal tools
└── sh-elf/               ✅ REQUIRED - Target-specific files
    ├── lib/              (libgcc.a, etc.)
    └── include/          (system headers)
```

**Size**: ~40-50MB

### From kos/ (KallistiOS)
```
kos/
├── lib/                            ✅ REQUIRED - Compiled libraries (4.8M)
│   ├── libkallisti.a              (KOS kernel)
│   ├── libgl.a                    (OpenGL for PVR)
│   ├── libpng.a, libjpeg.a, ...   (Optional but useful)
│   └── ...
│
├── include/                        ✅ REQUIRED - Headers (568K)
│   ├── kos.h                      (Main KOS header)
│   ├── dc/                        (Dreamcast-specific)
│   │   ├── pvr.h                  (Graphics)
│   │   ├── video.h                (Video)
│   │   ├── sound.h                (Audio)
│   │   └── ...
│   ├── arch/                      (Architecture)
│   └── kos/                       (KOS internals)
│
├── utils/build_wrappers/           ✅ REQUIRED - Build wrappers (68K)
│   ├── kos-cc                     (Main wrapper - CRITICAL!)
│   ├── kos-ar
│   ├── kos-ld
│   └── ...
│
├── environ_base.sh                 ✅ REQUIRED - Base environment (8K)
├── environ_dreamcast.sh            ✅ REQUIRED - Dreamcast config (8K)
├── Makefile.rules                  ✅ REQUIRED - Build rules (4K)
├── LICENSE                         ✅ REQUIRED - License info
├── NOTICE                          ✅ REQUIRED - Attribution
└── README.md                       ✅ REQUIRED - Documentation
```

**Size**: ~5.4MB

---

## ❌ What Should NOT Be Included

### From kos/ (Unnecessary)
```
kos/
├── utils/dc-chain/         ❌ EXCLUDE - Toolchain builder (2.2G!)
├── utils/genromfs/         ❌ EXCLUDE - ROM filesystem tool
├── utils/makeip/           ❌ EXCLUDE - IP.BIN creator
├── examples/               ❌ EXCLUDE - Sample programs (24M)
├── kernel/                 ❌ EXCLUDE - Kernel source (14M - already compiled to lib/)
├── addons/                 ❌ EXCLUDE - Addon source (3.8M - compile if needed)
├── doc/                    ❌ EXCLUDE - Documentation (428K)
└── loadable/               ❌ EXCLUDE - Loadable modules
```

**Why exclude**:
- Users don't rebuild KOS (use pre-built lib/)
- Examples are separate (godc has its own)
- Source code unnecessary (already compiled)

---

## 📊 Size Comparison

| Component | Include? | Size | Reason |
|-----------|----------|------|--------|
| sh-elf/ | ✅ YES | ~45M | Compilers needed |
| kos/lib/ | ✅ YES | 4.8M | Libraries needed |
| kos/include/ | ✅ YES | 568K | Headers needed |
| kos/utils/build_wrappers/ | ✅ YES | 68K | kos-cc needed |
| kos/environ*.sh | ✅ YES | 16K | Environment needed |
| kos/Makefile.rules | ✅ YES | 4K | Build rules needed |
| kos/utils/dc-chain/ | ❌ NO | 2.2G | Toolchain builder not needed |
| kos/examples/ | ❌ NO | 24M | Not needed |
| kos/kernel/ | ❌ NO | 14M | Source not needed |
| kos/addons/ | ❌ NO | 3.8M | Source not needed |

**Total included**: ~50MB
**Total excluded**: ~2.3GB

---

## 🧪 Verification Command

After extracting a release:

```bash
# Run verification
~/gocode/src/github.com/drpaneas/godc/verify-toolchain.sh extracted-dir/

# Should show:
✅ sh-elf-gccgo (Go compiler)
✅ sh-elf-gcc (C compiler)
✅ sh-elf-as (Assembler)
✅ sh-elf-ld (Linker)
✅ sh-elf-ar (Archiver)
✅ kos-cc (KOS wrapper)
✅ KOS lib directory
✅ libkallisti.a (KOS kernel)
✅ KOS include directory
✅ kos.h (Main header)
✅ dc/ (Dreamcast headers)
✅ kos-cc wrapper
✅ environ_base.sh
✅ environ_dreamcast.sh
✅ Makefile.rules
✅ gccgo works
✅ gcc works

✅ Toolchain verification PASSED
```

---

## 🎯 Expected Package Structure

After extraction of optimized release:

```
dreamcast-toolchain/
├── sh-elf/                         (~45MB)
│   ├── bin/
│   ├── lib/
│   ├── libexec/
│   └── sh-elf/
│
└── kos/                            (~5.4MB)
    ├── lib/                        (4.8M - libraries)
    ├── include/                    (568K - headers)
    ├── utils/build_wrappers/       (68K - kos-cc, etc.)
    ├── environ_base.sh             (8K)
    ├── environ_dreamcast.sh        (8K)
    ├── Makefile.rules              (4K)
    ├── LICENSE
    ├── NOTICE
    └── README.md

Total: ~50MB (vs 515MB before!)
```

---

## ✅ How godc Uses This

### Compilation Phase
```bash
# godc generates .godc_build/Makefile which uses:
sh-elf-gccgo -c ...           # From sh-elf/bin/
kos-cc -c -o print_wrapper.o  # From kos/utils/build_wrappers/
```

### Linking Phase
```bash
# Uses kos-cc which needs:
kos-cc -o main.elf ... -lkallisti  # From kos/lib/libkallisti.a
```

### Header Phase
```bash
# C compilation needs:
#include <kos.h>              # From kos/include/kos.h
#include <dc/pvr.h>           # From kos/include/dc/pvr.h
```

**All present in optimized package!** ✅

---

## 🎯 Summary

**Package Contents**: ✅ Verified complete for godc

**Size**: 50MB (10x smaller than before)

**Functionality**: 100% - Everything godc needs, nothing it doesn't

**Next release**: Will be fast to download and fully functional! 🚀

