# GitHub Actions Bug Fix - Incomplete Tarball

## 🐛 The Bug

**Location**: Both `.github/workflows/build-macos.yml` and `build-ubuntu.yml`

**Line**: Package toolchain step

```bash
# BROKEN (before):
tar czf "$TARBALL" kos/
```

**Problem**: Only packages KallistiOS (`kos/` directory), missing the compilers!

---

## ❌ What Was Missing from Releases

**Built but not packaged**:
- `sh-elf/bin/` - All compiler binaries (sh-elf-gccgo, sh-elf-gcc, sh-elf-as, sh-elf-ld, etc.)
- `sh-elf/lib/` - GCC runtime libraries  
- `sh-elf/include/` - GCC headers
- `sh-elf/libexec/` - GCC internal tools

**Result**: Users downloaded 515MB of just KallistiOS source/libs, but no compilers!

---

## ✅ The Fix

```bash
# FIXED (now):
tar czf "$TARBALL" sh-elf/ kos/
```

**Now packages BOTH**:
1. `sh-elf/` - Complete GCC toolchain with gccgo
2. `kos/` - KallistiOS libraries and headers

---

## 📊 Impact

### Before Fix:
```
Tarball contains:
└── kos/          (KallistiOS only)
    ├── lib/      ✅ Has libkallisti.a
    ├── include/  ✅ Has headers
    └── ...

User tries to build:
sh-elf-gccgo --version
❌ Command not found (no compilers in tarball!)
```

### After Fix:
```
Tarball contains:
├── sh-elf/                ✅ GCC toolchain
│   ├── bin/
│   │   ├── sh-elf-gccgo   ✅ Go compiler
│   │   ├── sh-elf-gcc     ✅ C compiler
│   │   └── ...
│   ├── lib/               ✅ GCC libraries
│   └── libexec/           ✅ GCC tools
│
└── kos/                   ✅ KallistiOS
    ├── lib/               ✅ libkallisti.a
    └── include/           ✅ Headers

User extracts and uses:
export PATH="/extracted/path/sh-elf/bin:$PATH"
sh-elf-gccgo --version
✅ Works!
```

---

## 🔧 Changes Made

### File: `.github/workflows/build-macos.yml`
**Line 145**: Changed from `tar czf "$TARBALL" kos/` to `tar czf "$TARBALL" sh-elf/ kos/`

### File: `.github/workflows/build-ubuntu.yml`  
**Line 148**: Changed from `tar czf "$TARBALL" kos/` to `tar czf "$TARBALL" sh-elf/ kos/`

---

## 🧪 How to Verify Next Release

After building a new release with this fix:

```bash
# Download and extract
tar -tzf dreamcast-toolchain-*.tar.gz | head -20

# Should see BOTH:
sh-elf/bin/sh-elf-gccgo     ✅
sh-elf/bin/sh-elf-gcc       ✅
kos/lib/libkallisti.a       ✅
```

Run verification script:
```bash
tar xzf dreamcast-toolchain-*.tar.gz
cd sh-elf  # Should exist now!
./verify-toolchain.sh .
```

---

## 📝 Next Release Checklist

To create a complete release:

1. ✅ Fix committed to both workflows
2. Commit and push changes
3. Create new tag: `git tag gcc15.1.0-kos2.2.2`
4. Push tag: `git push --tags`
5. Wait for GitHub Actions (~30 min per platform)
6. Download and verify with `verify-toolchain.sh`
7. Test with `godc setup`

---

## 🎯 Expected Tarball Structure

After extraction:

```
extract-directory/
├── sh-elf/              ← COMPILERS (was missing!)
│   ├── bin/
│   │   ├── sh-elf-gccgo
│   │   ├── sh-elf-gcc
│   │   ├── sh-elf-as
│   │   ├── sh-elf-ld
│   │   ├── sh-elf-ar
│   │   ├── sh-elf-objcopy
│   │   └── kos-cc
│   ├── lib/
│   ├── libexec/
│   └── sh-elf/
│
└── kos/                 ← KallistiOS (was included)
    ├── lib/
    │   ├── libkallisti.a
    │   ├── libgl.a
    │   └── ...
    └── include/
        ├── kos.h
        └── dc/
```

---

**Fix applied to both workflows!** Next release will be complete. ✅

