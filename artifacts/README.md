# Pre-Built Artifacts

This folder contains pre-built binaries for Module 1 (Runtime Performance) to save setup time.

## Why Pre-Built Artifacts?

Building all four variants (.NET 8 FX, .NET 8 AOT, .NET 10 FX, .NET 10 AOT) can take 5-10 minutes. Pre-built artifacts reduce Module 1 setup time to under 2 minutes, ensuring the workshop fits within the 2-hour timeframe.

## Folder Structure

```
artifacts/
├── pub8-fx/       # .NET 8 Framework-Dependent
├── pub8-aot/      # .NET 8 Native AOT
├── pub10-fx/      # .NET 10 Framework-Dependent
└── pub10-aot/     # .NET 10 Native AOT
```

## Contents

Each folder will contain the published PricingService microservice:
- `PricingService.dll` or `PricingService.exe` (depending on build type)
- `appsettings.json`
- Required dependencies

## How to Rebuild

If you want to rebuild the artifacts (e.g., after code changes):

```powershell
cd modules\module1-runtime
.\build-all.ps1
```

This will:
1. Compile all four variants
2. Copy outputs to `artifacts/` folders
3. Overwrite existing pre-built binaries

## File Sizes (Expected)

| Variant | Approximate Size | Startup Time (Expected) |
|---------|------------------|-------------------------|
| pub8-fx | ~2 MB | ~800 ms |
| pub8-aot | ~15 MB | ~150 ms |
| pub10-fx | ~2 MB | ~700 ms |
| pub10-aot | ~14 MB | ~120 ms |

*Note: Actual sizes and times vary by platform and build configuration.*

## Educational Clarity Principle

These pre-built artifacts support the workshop's "Educational Clarity" principle:
- ✅ Participants can measure performance within 5 minutes
- ✅ No waiting for slow builds during hands-on time
- ✅ Focus on learning, not troubleshooting build issues

## Fair Comparison Principle

These artifacts support the workshop's "Fair Comparison" principle:
- ✅ All participants measure the same binaries
- ✅ Consistent results across different machines
- ✅ Eliminates build configuration as a variable

## When to Rebuild

Rebuild if:
- You modify the PricingService source code
- You want to experiment with different compiler flags
- You suspect the pre-built binaries are corrupted

Do NOT rebuild if:
- You're a workshop participant following the standard path
- You want consistent results with other participants
- You're short on time (use pre-built for quick start)

## Troubleshooting

### Issue: Artifacts folder is empty

**Solution**: Run the build script:
```powershell
cd modules\module1-runtime
.\build-all.ps1
```

### Issue: "File not found" errors during measurement

**Solution**: Verify folder structure:
```powershell
ls artifacts\
# Should show: pub8-fx, pub8-aot, pub10-fx, pub10-aot
```

### Issue: Measurement script shows unexpected results

**Solution**: Rebuild to ensure artifacts match current code:
```powershell
cd modules\module1-runtime
.\build-all.ps1 -Force
```

---

**Note**: These folders are committed to the repository intentionally to support the "5-minute runability" workshop goal. The `.gitignore` is configured to keep folder structure but ignore binary files unless explicitly forced.
