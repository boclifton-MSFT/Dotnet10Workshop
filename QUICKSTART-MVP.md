# Quick Start Guide - MVP Workshop

This guide gets you running the **MVP** version of the LTS to LTS Performance Lab in under 5 minutes.

## ⚡ Prerequisites

- .NET 8 SDK installed
- PowerShell 7+ (Windows)
- Git (to clone this repository)
- Optional: bombardier or wrk for load testing

Verify prerequisites:
```powershell
.\shared\Scripts\check-prerequisites.ps1
```

## 🚀 MVP Workshop (25 minutes)

The MVP includes:
- **Module 0**: Workshop context (5 min read)
- **Module 1**: Runtime performance measurements (20 min hands-on)

### Step 1: Read Module 0 (5 minutes)

```powershell
cd modules\module0-warmup
Get-Content README.md | more
```

**What you'll learn:**
- Business case for .NET 8 → .NET 10 upgrades
- Expected performance improvements
- Workshop module roadmap

### Step 2: Build PricingService (3 minutes)

```powershell
cd ..\module1-runtime
dotnet build
```

**Expected output:**
```
Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:02.00
```

### Step 3: Measure Cold-Start Time (5 minutes)

**Option A**: Use pre-built artifacts (fastest)
```powershell
.\measure-coldstart.ps1
```

**Option B**: Build all variants first (slower)
```powershell
.\build-all.ps1  # Takes 10-15 minutes with AOT
.\measure-coldstart.ps1
```

**Expected results:**
```
=== Cold-Start Time Summary ===
.NET 8 FX:    780 ms (avg of 5 runs)
.NET 8 AOT:   150 ms (avg of 5 runs)

Winner: .NET 8 AOT (81% faster than .NET 8 FX)
```

### Step 4: Measure Binary Size (2 minutes)

```powershell
.\measure-size.ps1
```

**Expected results:**
```
=== Binary Size Summary ===
.NET 8 FX:    2.3 MB
.NET 8 AOT:   14.8 MB

AOT Overhead: 6.4x larger than FX builds
```

### Step 5: Measure Memory Usage (8 minutes)

**Requires**: bombardier or wrk installed

```powershell
.\measure-memory.ps1
```

**Expected results:**
```
=== Memory Usage Summary ===
.NET 8 FX:    82 MB (peak working set)
.NET 8 AOT:   51 MB (peak working set)

Winner: .NET 8 AOT (38% lower than .NET 8 FX)
```

## 📊 Record Your Findings

Create `modules\module1-runtime\results\my-measurements.md`:

```markdown
# My Module 1 Results

**Machine**: [Your machine specs]  
**Date**: 2025-01-15

## Cold-Start Time
- .NET 8 FX: ___ ms
- .NET 8 AOT: ___ ms
- Improvement: ___%

## Binary Size
- .NET 8 FX: ___ MB
- .NET 8 AOT: ___ MB
- Overhead: ___x

## Memory Usage
- .NET 8 FX: ___ MB
- .NET 8 AOT: ___ MB
- Improvement: ___%

## Key Takeaway
Native AOT provides significantly faster cold-starts and lower memory usage,
at the cost of larger binary sizes. Best for serverless and containerized workloads.
```

## 🎓 What You Learned

After completing the MVP, you will have:
- ✅ Measured cold-start time differences (FX vs AOT)
- ✅ Compared binary sizes
- ✅ Measured memory usage under load
- ✅ Understood tradeoffs between Framework-Dependent and Native AOT

## 🚀 Next Steps

### Option 1: Deep Dive (Recommended)
Read the full README for Module 1:
```powershell
cd modules\module1-runtime
Get-Content README.md | more
```

### Option 2: Extend to .NET 9/10
1. Install .NET 9 SDK (placeholder for .NET 10)
2. Update `shared/DomainModels/DomainModels.csproj` to multi-target:
   ```xml
   <TargetFrameworks>net8.0;net9.0</TargetFrameworks>
   ```
3. Rebuild all variants:
   ```powershell
   cd modules\module1-runtime
   .\build-all.ps1
   ```

### Option 3: Continue to Module 2
**Note**: Module 2 (PromotionsAPI) is not yet implemented. Refer to `IMPLEMENTATION-STATUS.md` for progress.

## 🛠️ Troubleshooting

### Issue: "Cannot find executable"

**Solution**: Build the service first:
```powershell
cd modules\module1-runtime
dotnet build
```

### Issue: "Port 5000 already in use"

**Solution**: Kill existing processes:
```powershell
Stop-Process -Name "PricingService" -Force
```

### Issue: "Load testing tool not found"

**Solution**: Install bombardier:
```powershell
choco install bombardier
```

Or skip the memory test and just measure cold-start and size.

### Issue: Native AOT build fails

**Cause**: Missing C++ build tools

**Solution**: Install Visual Studio Build Tools with "Desktop development with C++"

## 📚 Additional Resources

- **Implementation Status**: `IMPLEMENTATION-STATUS.md` (full workshop progress)
- **Tasks**: `specs/001-lts-performance-lab/tasks.md` (152 tasks)
- **Specification**: `specs/001-lts-performance-lab/spec.md` (7 user stories, 60 FRs)
- **Constitution**: `.specify/memory/constitution.md` (5 design principles)

## ✅ Success Criteria

You've completed the MVP when:
- ✅ Measured cold-start time for .NET 8 FX and AOT
- ✅ Compared binary sizes
- ✅ Measured memory usage (optional, requires load testing tool)
- ✅ Documented findings in `results/` folder
- ✅ Understood FX vs AOT tradeoffs

**Congratulations!** You've experienced the core value proposition of the .NET 8 to .NET 10 upgrade workshop.

---

**Time Investment**: 25 minutes (5 min read + 20 min hands-on)  
**Next Milestone**: Module 2 (PromotionsAPI) - Coming Soon
