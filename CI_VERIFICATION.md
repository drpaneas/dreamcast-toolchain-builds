# CI Verification System

## ✅ Automated Quality Assurance

Every release is now automatically verified before publishing!

---

## 🔄 CI Pipeline Flow

```
1. Build GCC toolchain (30 min)
   ↓
2. Build KallistiOS (5 min)
   ↓
3. Package tarball (~50MB)
   ↓
4. Extract to temp directory
   ↓
5. Run verification script ← NEW!
   ├─ Check all binaries exist
   ├─ Check libraries exist
   ├─ Check headers exist
   └─ Check wrappers exist
   ↓
6. Run smoke test ← NEW!
   ├─ Compile test.c (C code)
   ├─ Compile test.go (Go code)
   ├─ Verify kos-cc works
   └─ Check libkallisti.a valid
   ↓
7. Upload to GitHub Releases
   ↓
8. Users download working toolchain! 🎉
```

**If ANY step fails**: Build stops, no release published!

---

## 🧪 Verification Tests

### Test 1: File Presence Check

**Script**: `scripts/verify-toolchain.sh`

**Checks**:
```
✅ sh-elf/bin/sh-elf-gccgo exists
✅ sh-elf/bin/sh-elf-gcc exists
✅ sh-elf/bin/sh-elf-as exists
✅ sh-elf/bin/sh-elf-ld exists
✅ sh-elf/bin/sh-elf-ar exists
✅ kos/utils/build_wrappers/kos-cc exists
✅ kos/lib/libkallisti.a exists
✅ kos/lib/libgcc.a exists
✅ kos/include/kos.h exists
✅ kos/include/dc/pvr.h exists
✅ kos/include/dc/video.h exists
✅ environ_base.sh exists
✅ environ_dreamcast.sh exists
✅ Makefile.rules exists
```

**If any missing**: Build fails ❌

### Test 2: Executable Check

**Checks**:
```bash
sh-elf/bin/sh-elf-gccgo --version  # Must run
sh-elf/bin/sh-elf-gcc --version    # Must run
```

**If can't execute**: Build fails ❌

### Test 3: Smoke Test

**Script**: `scripts/smoke-test.sh`

**Tests**:
```
1. Compile C program with sh-elf-gcc
   → test.c → test.o ✅

2. Compile Go program with sh-elf-gccgo
   → test.go → test_go.o ✅

3. Verify kos-cc is in PATH and executable

4. Check libkallisti.a size > 100KB (not corrupt)
```

**If any test fails**: Build fails ❌

---

## 💡 Benefits

### 1. Catch Packaging Errors
**Before**: User downloads, extracts, missing files, frustrated
**Now**: CI catches it, no bad release published

### 2. Catch Build Errors
**Before**: Toolchain builds but gcc binary is broken
**Now**: Smoke test compiles code, catches broken binaries

### 3. Version Confidence
**Before**: "Hope it works!"
**Now**: "Verified working"

### 4. Fast Feedback
**Before**: Users report issues days later
**Now**: Know immediately if build failed

---

## 🎯 What Gets Verified

### Structural Verification
- ✅ All directories present (sh-elf/, kos/)
- ✅ All binaries present (gccgo, gcc, as, ld, ar)
- ✅ All libraries present (libkallisti.a, etc.)
- ✅ All headers present (kos.h, dc/*.h)
- ✅ All wrappers present (kos-cc)
- ✅ All config files present (environ*.sh, Makefile.rules)

### Functional Verification
- ✅ Binaries are executable (not corrupted)
- ✅ Compilers can compile (C and Go)
- ✅ kos-cc wrapper works
- ✅ Libraries are valid (size check)

### Size Verification
- ✅ Package is reasonable size (~50MB, not 515MB)
- ✅ libkallisti.a is substantial (>100KB)

---

## 📊 CI Status Check

**After pushing changes**, check GitHub Actions:

1. Go to: https://github.com/drpaneas/dreamcast-toolchain-builds/actions
2. Click on latest build
3. Expand "Verify toolchain package" step
4. Should see:
   ```
   🔍 Running verification on packaged toolchain...
   ✅ sh-elf-gccgo (Go compiler)
   ✅ sh-elf-gcc (C compiler)
   ...
   🧪 Running smoke test...
   ✅ C compilation works
   ✅ Go compilation works
   ...
   ✅ All verification tests PASSED - Safe to release!
   ```

**If anything fails**: Build stops, no release created! ✅

---

## 🚀 Next Release

When you create the next release:

```bash
git tag gcc15.2.0-kos2.2.3
git push --tags
```

**GitHub Actions will**:
1. Build toolchain
2. Package optimally (~50MB)
3. **Verify package** ← Automatic!
4. **Smoke test** ← Automatic!
5. Upload only if all tests pass

**Result**: Guaranteed working release! 🎉

---

## 🔍 Manual Verification

You can also run verification locally:

```bash
# After building locally
./scripts/verify-toolchain.sh build/toolchain-dir/

# Run smoke test
./scripts/smoke-test.sh build/toolchain-dir/
```

**Use this before** manually uploading releases!

---

**CI verification system is now complete and committed!** ✅

Every release will be automatically tested before publishing. 🚀

