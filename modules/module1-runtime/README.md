# Module 1: Runtime Performance

**Duration: 20 minutes**  
**Objective**: Compare cold-start time, binary size, and memory usage between .NET 8 and .NET 10 for a simple PricingService microservice.

---

## 🎯 Learning Objectives

By the end of this module, you will:
1. Build 4 variants of PricingService (.NET 8 FX, .NET 8 AOT, .NET 10 FX, .NET 10 AOT)
2. Measure cold-start time for each variant
3. Compare binary sizes
4. Measure memory usage under load
5. Understand tradeoffs between Framework-Dependent and Native AOT

---

## 📊 What You'll Measure

| Metric | Expected .NET 8 FX | Expected .NET 10 FX | Expected .NET 8 AOT | Expected .NET 10 AOT |
|--------|--------------------|--------------------|---------------------|---------------------|
| Cold-start time | ~800 ms | ~700 ms | ~150 ms | ~120 ms |
| Binary size | ~2 MB | ~2 MB | ~15 MB | ~12 MB |
| Memory usage | ~80 MB | ~70 MB | ~50 MB | ~40 MB |

---

## 🚀 Quick Start (2 minutes)

If you're short on time, use the pre-built artifacts:

```powershell
# Skip the build step and jump straight to measurements
.\measure-coldstart.ps1
.\measure-size.ps1
.\measure-memory.ps1
```

The pre-built binaries are in `../../artifacts/` and were built with optimizations enabled.

---

## 🔨 Build All Variants (10 minutes if building from source)

Build all 4 variants at once:

```powershell
.\build-all.ps1
```

This script will:
1. Build .NET 8 Framework-Dependent
2. Build .NET 8 Native AOT
3. Build .NET 10 Framework-Dependent
4. Build .NET 10 Native AOT
5. Copy outputs to `../../artifacts/` folders

**Note**: Native AOT builds can take 3-5 minutes each.

---

## 📏 Measurement Scripts

### 1. Cold-Start Time (5 minutes)

Measures how long it takes for the service to start and respond to the first request.

```powershell
.\measure-coldstart.ps1
```

**What it does:**
- Starts each variant in a separate process
- Waits for HTTP 200 on `/health` endpoint
- Records startup time
- Shuts down gracefully
- Repeats 5 times per variant and averages

**Expected output:**
```
=== Cold-Start Time Comparison ===
.NET 8 FX:    782 ms (avg of 5 runs)
.NET 8 AOT:   148 ms (avg of 5 runs)
.NET 10 FX:   697 ms (avg of 5 runs)
.NET 10 AOT:  119 ms (avg of 5 runs)

Winner: .NET 10 AOT (~85% faster than .NET 8 FX)
```

### 2. Binary Size (2 minutes)

Measures published output size for each variant.

```powershell
.\measure-size.ps1
```

**What it does:**
- Recursively sums file sizes in each `pub*` folder
- Reports sizes in MB
- Calculates overhead of Native AOT

**Expected output:**
```
=== Binary Size Comparison ===
.NET 8 FX:    2.3 MB
.NET 8 AOT:   14.8 MB
.NET 10 FX:   2.1 MB
.NET 10 AOT:  12.2 MB

AOT Overhead: ~6x larger than FX builds
.NET 10 Improvement: ~18% smaller AOT binaries
```

### 3. Memory Usage (8 minutes)

Measures memory consumption under HTTP load.

```powershell
.\measure-memory.ps1
```

**What it does:**
- Starts each variant
- Warms up with 100 requests
- Applies sustained load (500 req/sec for 30 seconds)
- Samples memory usage with `dotnet-counters`
- Reports peak working set

**Expected output:**
```
=== Memory Usage Comparison (under load) ===
.NET 8 FX:    82 MB (peak working set)
.NET 8 AOT:   51 MB (peak working set)
.NET 10 FX:   71 MB (peak working set)
.NET 10 AOT:  39 MB (peak working set)

Winner: .NET 10 AOT (~52% lower than .NET 8 FX)
```

---

## 🏗️ Architecture

### PricingService Overview

```
GET /api/pricing/calculate
{
  "sku": "WIDGET-001",
  "quantity": 5,
  "customerId": "CUST-12345"
}

Response:
{
  "sku": "WIDGET-001",
  "basePrice": 29.99,
  "quantity": 5,
  "discount": 7.50,
  "total": 142.45
}
```

### What the Service Does

1. Looks up product by SKU (in-memory mock data)
2. Calculates base price × quantity
3. Applies promotional discount (if customer is eligible)
4. Returns itemized pricing

### Why This Tests Runtime Performance

- **No database**: Pure compute workload
- **Minimal allocations**: Uses value types (`Money`, `SKU`, `Quantity`)
- **Typical API pattern**: JSON deserialization → compute → JSON serialization

---

## 📂 Folder Structure

```
module1-runtime/
├── README.md                    # This file
├── PricingService.csproj        # Shared project file
├── Program.cs                   # Minimal API endpoints
├── PricingCalculator.cs         # Business logic
├── build-all.ps1                # Builds all 4 variants
├── measure-coldstart.ps1        # Cold-start benchmark
├── measure-size.ps1             # Binary size comparison
├── measure-memory.ps1           # Memory usage benchmark
└── results/                     # Store your measurements here
    ├── coldstart-results.txt
    ├── size-results.txt
    └── memory-results.txt
```

---

## 🔍 Understanding the Code

### Program.cs (Minimal API)

```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/health", () => Results.Ok("Healthy"));

app.MapPost("/api/pricing/calculate", (PricingRequest req) =>
{
    var calculator = new PricingCalculator();
    return calculator.Calculate(req);
});

app.Run();
```

**Why minimal API?**
- Lower overhead than controllers
- Faster startup time
- Simpler for workshop participants

### PricingCalculator.cs (Business Logic)

```csharp
public class PricingCalculator
{
    public PricingResponse Calculate(PricingRequest request)
    {
        var product = GetProduct(request.Sku);
        var basePrice = product.BasePrice * request.Quantity;
        var discount = ApplyDiscount(basePrice, request.CustomerId);
        var total = basePrice - discount;

        return new PricingResponse
        {
            Sku = request.Sku,
            BasePrice = product.BasePrice,
            Quantity = request.Quantity,
            Discount = discount,
            Total = total
        };
    }
}
```

**Why this design?**
- **Value types**: `Money`, `SKU`, `Quantity` reduce GC pressure
- **No async**: This is a CPU-bound operation
- **Mock data**: In-memory lookup avoids I/O variability

---

## 🎓 Key Learnings

### Framework-Dependent vs Native AOT

| Aspect | Framework-Dependent | Native AOT |
|--------|---------------------|------------|
| Binary size | ~2 MB | ~12-15 MB |
| Cold-start time | ~700-800 ms | ~120-150 ms |
| Memory usage | ~70-80 MB | ~40-50 MB |
| Deployment | Requires .NET runtime installed | Self-contained (no runtime needed) |
| Best for | Traditional servers, long-running processes | Serverless, containers, short-lived processes |

### When to Choose Each

**Framework-Dependent (FX)**:
- ✅ Lower disk usage (smaller deployments)
- ✅ Faster builds
- ✅ Supports all .NET features (reflection, dynamic code)
- ❌ Slower cold-starts
- ❌ Requires runtime pre-installed

**Native AOT**:
- ✅ Fastest cold-starts (~85% faster)
- ✅ Lowest memory usage (~50% reduction)
- ✅ No runtime dependency
- ❌ Larger binaries (~6x size)
- ❌ Limited reflection/dynamic code
- ❌ Slower build times

---

## 🛠️ Troubleshooting

### Issue: `dotnet-counters` not found

**Solution**: Install the tool:
```powershell
dotnet tool install -g dotnet-counters
```

### Issue: "Port 5000 already in use"

**Solution**: Kill existing processes:
```powershell
Stop-Process -Name "PricingService" -Force
```

### Issue: Native AOT build fails

**Common causes:**
1. Missing C++ build tools (required for AOT)
   - Install Visual Studio Build Tools with "Desktop development with C++"
2. Incompatible NuGet packages (e.g., packages using reflection)
   - Check `PricingService.csproj` for AOT warnings

### Issue: Measurements show unexpected results

**Solution**: Ensure no background processes are consuming resources:
```powershell
# Close browsers, IDEs, etc. before measuring
Get-Process | Where-Object {$_.WorkingSet -gt 500MB}
```

---

## 📊 Recording Your Results

Create `results/my-measurements.md`:

```markdown
# My Module 1 Results

**Machine**: Dell XPS 15, Intel i7-11800H, 32GB RAM  
**Date**: 2025-01-15

## Cold-Start Time
| Variant | Average (ms) | Improvement |
|---------|--------------|-------------|
| .NET 8 FX | 785 ms | baseline |
| .NET 8 AOT | 152 ms | 81% faster |
| .NET 10 FX | 701 ms | 11% faster |
| .NET 10 AOT | 121 ms | 85% faster |

## Binary Size
| Variant | Size (MB) | Notes |
|---------|-----------|-------|
| .NET 8 FX | 2.3 MB | |
| .NET 8 AOT | 14.8 MB | 6.4x larger |
| .NET 10 FX | 2.1 MB | |
| .NET 10 AOT | 12.2 MB | 18% smaller than .NET 8 AOT |

## Memory Usage (Peak Working Set)
| Variant | Memory (MB) | Improvement |
|---------|-------------|-------------|
| .NET 8 FX | 82 MB | baseline |
| .NET 8 AOT | 51 MB | 38% lower |
| .NET 10 FX | 71 MB | 13% lower |
| .NET 10 AOT | 39 MB | 52% lower |

## Key Takeaways
- Native AOT cold-starts are dramatically faster (~85%)
- .NET 10 AOT binaries are 18% smaller than .NET 8
- Memory usage improved by 52% in .NET 10 AOT
- FX builds are still suitable for long-running services
```

---

## 🚀 Next Steps

After completing this module:

1. **Compare your results** with the expected values
2. **Document surprises** - Did anything behave unexpectedly?
3. **Move to Module 2** - HTTP Caching & Rate Limiting

```powershell
cd ..\module2-caching
Get-Content README.md
```

---

## 🎯 Success Criteria

- ✅ Built all 4 variants (or used pre-built artifacts)
- ✅ Measured cold-start time
- ✅ Measured binary size
- ✅ Measured memory usage
- ✅ Understood FX vs AOT tradeoffs
- ✅ Documented findings in `results/`

**Time Investment**: 20 minutes (2 min with pre-built, 10 min if building, 8 min measuring)
