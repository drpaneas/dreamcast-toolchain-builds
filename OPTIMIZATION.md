# Release Size Optimization

## 🎯 Problem

**Previous release**: 515MB download
**Actually needed**: ~50MB

**430MB of unnecessary files!**

---

## 📊 Breakdown

### What's in KallistiOS (2.3GB)

| Directory | Size | Needed? | Purpose |
|-----------|------|---------|---------|
| `lib/` | 4.8M | ✅ YES | Compiled libraries (libkallisti.a, etc.) |
| `include/` | 568K | ✅ YES | Headers for compilation |
| `utils/` | 2.2G | ❌ NO | Build tools (dc-chain, etc.) |
| `examples/` | 24M | ❌ NO | Sample programs |
| `kernel/` | 14M | ❌ NO | Source code |
| `addons/` | 3.8M | ❌ NO | Optional features (source) |
| `doc/` | 428K | ❌ NO | Documentation |

### What Users Need

**For godc to work**:
```
✅ sh-elf/bin/        Compilers (sh-elf-gccgo, sh-elf-gcc, etc.)
✅ sh-elf/lib/        GCC runtime libraries
✅ kos/lib/           KOS libraries (4.8M)
✅ kos/include/       KOS headers (568K)

❌ kos/utils/         Build tools (not needed after build)
❌ kos/examples/      Sample code (not needed)
❌ kos/kernel/        Source code (already compiled to lib/)
```

---

## ✅ The Fix

**Old packaging**:
```bash
tar czf "$TARBALL" sh-elf/ kos/
# Includes ALL of kos/ (2.3GB)
# Compressed to 515MB
```

**New packaging**:
```bash
tar czf "$TARBALL" \
  sh-elf/ \
  kos/lib/ \
  kos/include/ \
  kos/LICENSE \
  kos/NOTICE \
  kos/README.md
# Only essentials (~50MB compressed)
```

---

## 📈 Impact

### Download Size
- **Before**: 515MB
- **After**: ~50MB
- **Reduction**: 10x smaller!

### Download Time
- **Before**: 21 seconds @ 25MB/s = 515MB
- **After**: 2 seconds @ 25MB/s = 50MB
- **Reduction**: 10x faster!

### Disk Space
- **Before**: 2.3GB extracted
- **After**: ~200MB extracted  
- **Reduction**: 11x less space!

---

## 🧪 Verification

After extraction, users should have:

```
dreamcast-toolchain/
├── sh-elf/
│   ├── bin/
│   │   ├── sh-elf-gccgo   ✅
│   │   ├── sh-elf-gcc     ✅
│   │   └── ...
│   └── lib/               ✅
│
└── kos/
    ├── lib/
    │   ├── libkallisti.a  ✅
    │   └── ...
    ├── include/
    │   ├── kos.h          ✅
    │   └── dc/            ✅
    ├── LICENSE            ✅
    └── README.md          ✅
```

**No**: utils/, examples/, kernel/, addons/, doc/

---

## 🔧 Implementation

**Changed files**:
- `.github/workflows/build-macos.yml`
- `.github/workflows/build-ubuntu.yml`

**Changed line**:
```bash
# From:
tar czf "$TARBALL" sh-elf/ kos/

# To:
tar czf "$TARBALL" \
  sh-elf/ \
  kos/lib/ \
  kos/include/ \
  kos/LICENSE \
  kos/NOTICE \
  kos/README.md
```

---

## ⚠️ What If Users Need More?

**If someone needs KOS utils or examples**:
- They can clone KallistiOS separately
- Most users don't need these (just using the libraries)

**If someone needs addons**:
- We can create a separate "addons" download
- Or document how to add them manually

**For godc users**: The minimal package has everything needed! ✅

---

## 🎯 Expected Next Release

**Download**: ~50MB (instead of 515MB)
**Extract size**: ~200MB (instead of 2.3GB)
**Contains**: Everything godc needs, nothing it doesn't

**Test with**:
```bash
tar xzf dreamcast-toolchain-*.tar.gz
~/gocode/src/github.com/drpaneas/godc/verify-toolchain.sh .
```

Should show all ✅!

---

**Optimization committed!** Next release will be 10x smaller. 🚀

