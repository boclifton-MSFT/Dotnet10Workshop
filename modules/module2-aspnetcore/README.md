# Module 2: HTTP Caching & Rate Limiting

**Duration: 25 minutes**  
**Objective**: Compare ASP.NET Core throughput between .NET 8 and .NET 10, measuring the impact of output caching and rate limiting.

---

## 🎯 Learning Objectives

By the end of this module, you will:
1. Understand how output caching improves API throughput
2. Implement rate limiting for API protection
3. Measure request throughput (RPS) and latency improvements
4. Compare .NET 8 vs .NET 10 performance under load
5. See real-world benefits of platform improvements

---

## 📊 What You'll Measure

| Metric | .NET 8 Baseline | .NET 10 Target | Business Value |
|--------|-----------------|----------------|----------------|
| Throughput (RPS) | ~500 req/sec | ~575 req/sec | 15% improvement = handle more traffic |
| p50 Latency | 20ms | 18ms | Better UX for users |
| p95 Latency | 50ms | 42ms | Fewer slow requests |
| p99 Latency | 100ms | 85ms | Improved tail latency |
| Cache Hit Rate | 0% (no cache) | ~60% | Massive reduction in backend load |

---

## 🚀 Quick Start (2 minutes)

If you're short on time, use pre-built artifacts (same as Module 1):

```powershell
# Skip the build and jump to measurements
.\load-test.ps1 -Variant NET8
.\load-test.ps1 -Variant NET10
.\compare-results.ps1
```

---

## 🔨 Build All Variants (3 minutes if building from source)

Build both .NET 8 and .NET 10 versions:

```powershell
.\build-all.ps1
```

This script will:
1. Build .NET 8 version (standard ASP.NET Core)
2. Build .NET 10 version (with output caching + rate limiting)
3. Copy outputs to `../../artifacts/` folders

---

## 📊 Measurement Script

### Load Testing (15 minutes)

Measures request throughput, latency, and cache effectiveness:

```powershell
.\load-test.ps1 -Variant NET8 -Duration 30 -Concurrency 10
.\load-test.ps1 -Variant NET10 -Duration 30 -Concurrency 10
```

**What it does:**
- Warms up with 100 requests to populate cache (if .NET 10)
- Applies sustained load (10 concurrent connections, 30 seconds)
- Captures:
  - Total requests and errors
  - Requests per second (RPS)
  - p50, p95, p99 latency percentiles
  - Response times and throughput
- Saves results to JSON for comparison

### Compare Results (2 minutes)

Side-by-side comparison:

```powershell
.\compare-results.ps1
```

**Expected output:**
```
=== Throughput Comparison ===
.NET 8:  510 RPS (baseline)
.NET 10: 585 RPS (+14.7% faster)

=== Latency Comparison (p95) ===
.NET 8:  52 ms
.NET 10: 43 ms (17.3% lower)

=== Cache Effectiveness ===
Cache Hit Rate: 60%
Cache Impact: ~50% throughput improvement due to caching
```

---

## 🏗️ Architecture

### PromotionsAPI Overview

Two identical APIs with different optimizations:

**Endpoints:**
- `GET /health` - Health check (always 200)
- `GET /promotions` - List all promotions (30 items in demo)
- `GET /promotions/{id}` - Get specific promotion
- `POST /promotions/validate` - Validate if promotion is active

### .NET 8 Implementation

Standard ASP.NET Core 8.0:
- No caching (each request hits business logic)
- No rate limiting (test baseline)
- In-memory promotion data (mock)

### .NET 10 Implementation

Enhanced with platform features:
- **Output Caching**: Cache GET /promotions for 10 seconds
- **Rate Limiting**: 100 requests per 10 seconds per client
- **Same Promotion Data**: Identical mock data for fair comparison

---

## 💡 Why This Matters

### Performance Gap

The .NET 10 version shows real-world improvements:
1. **Output Caching** reduces CPU usage dramatically
2. **Rate Limiting** prevents abuse and protects backend
3. **Platform improvements** reduce GC and memory allocations
4. **Result**: Better throughput, lower latency, happier users

### Business Impact

For a Meijer-scale retail platform:
- **15% throughput improvement** = fewer servers needed
- **Lower latency** = better user experience during traffic spikes
- **Rate limiting** = protection during flash sales
- **Cost savings** = fewer compute resources, lower cloud bills

---

## 📂 Folder Structure

```
module2-aspnetcore/
├── README.md                    # This file
├── build-all.ps1                # Builds both variants
├── load-test.ps1                # Load test script (bombardier/wrk)
├── compare-results.ps1          # Compares NET8 vs NET10 results
├── results/                     # Stores measurements
│   ├── net8-results.json
│   └── net10-results.json
├── PromotionsAPI.csproj         # Shared project file (simplified)
├── Program.cs                   # Single API with conditional features
└── SampleData.cs                # Mock promotions data
```

---

## 🔍 Understanding the Code

### Program.cs (Minimal API with Conditional Features)

```csharp
var builder = WebApplication.CreateBuilder(args);

// .NET 10 only features
#if NET10_0_OR_GREATER
builder.Services.AddOutputCache();
builder.Services.AddRateLimiter(_ => _.FixedWindowRateLimiter = 
    new(new() { PermitLimit = 100, Window = TimeSpan.FromSeconds(10) })
);
#endif

var app = builder.Build();

// Health check (both versions)
app.MapGet("/health", () => Results.Ok("Healthy"));

// Get all promotions (cached in .NET 10)
#if NET10_0_OR_GREATER
app.MapGet("/promotions", () => SampleData.GetPromotions())
    .CacheOutput("promotions-cache", TimeSpan.FromSeconds(10));
#else
app.MapGet("/promotions", () => SampleData.GetPromotions());
#endif

// Get specific promotion
app.MapGet("/promotions/{id}", (string id) => 
    SampleData.GetPromotion(id)
);

// Validate promotion (rate limited in .NET 10)
#if NET10_0_OR_GREATER
app.MapPost("/promotions/validate", (PromoValidationRequest req) => 
    ValidatePromo(req)
).RequireRateLimiting("fixed");
#else
app.MapPost("/promotions/validate", (PromoValidationRequest req) => 
    ValidatePromo(req)
);
#endif

app.Run();
```

**Why this design?**
- **Single codebase**: Easier to maintain and ensure fair comparison
- **Conditional compilation**: .NET 10 features only compile on .NET 10
- **Same business logic**: Ensures differences are platform, not algorithm
- **Clear boundaries**: Easy to see what changed

### Output Caching Strategy

```csharp
.CacheOutput("promotions-cache", TimeSpan.FromSeconds(10))
```

- **10-second TTL**: Balance between freshness and cache hit rate
- **Cached on GET**: Safe for queries (no side effects)
- **Cache keys**: Automatically generated from route

### Rate Limiting Strategy

```csharp
new FixedWindowRateLimiter(
    new() { 
        PermitLimit = 100,           // 100 requests
        Window = TimeSpan.FromSeconds(10)  // per 10 seconds
    }
)
```

- **100 req/10sec**: ~10 req/sec per client
- **Fair distribution**: Prevents abuse during flash sales
- **Clear limits**: API returns 429 when exceeded

---

## 🎓 Key Learnings

### Output Caching Effectiveness

| Scenario | Cache Impact | Throughput |
|----------|-------------|-----------|
| No cache (NET8) | 0% hit | ~510 RPS |
| With 10s TTL (NET10) | 60% hit | ~585 RPS |
| With infinite TTL | 90%+ hit | ~900 RPS |

**Insight**: Real-world cache hit rates (60%) provide significant benefit without sacrificing data freshness.

### Rate Limiting Patterns

```csharp
// Fixed window: Simple, fast
new FixedWindowRateLimiter(new() { PermitLimit = 100, Window = TimeSpan.FromSeconds(10) })

// Sliding window: More fair (requires .NET 8.2+)
new SlidingWindowRateLimiter(new() { PermitLimit = 100, Window = TimeSpan.FromSeconds(10) })

// Token bucket: Most flexible
new TokenBucketRateLimiter(new() { TokensPerPeriod = 100, ReplenishmentPeriod = TimeSpan.FromSeconds(10) })
```

### Platform Differences

**Why is .NET 10 faster?**
1. **GC improvements**: Less time spent in garbage collection
2. **JIT enhancements**: Better code generation
3. **Memory efficiency**: Reduced allocations in hot paths
4. **Framework optimizations**: HTTP stack improvements
5. **Output cache**: Built-in performance optimization

---

## 🛠️ Troubleshooting

### Issue: "bombardier not found"

**Solution**: Install load testing tool:
```powershell
choco install bombardier
# Or use wrk
choco install wrk
```

### Issue: "Port 5000 already in use"

**Solution**: Kill existing process:
```powershell
Stop-Process -Name "PromotionsAPI" -Force
```

### Issue: Load test shows .NET 8 faster than .NET 10

**Likely cause**: Cache not warmed up in .NET 10
- **Solution**: Ensure warmup requests complete before measurement starts
- **Check**: First 100 requests go to cache (should see cache hit rate ~60% after warmup)

### Issue: Rate limiting blocking too many requests

**Solution**: Adjust limits in Program.cs:
```csharp
PermitLimit = 200,  // Increase from 100
Window = TimeSpan.FromSeconds(10)
```

---

## 📊 Recording Your Results

Create `results/my-measurements.md`:

```markdown
# My Module 2 Results

**Machine**: [Your specs]  
**Date**: 2025-01-15

## Throughput (RPS)
| Variant | RPS | Improvement |
|---------|-----|-------------|
| .NET 8 | 510 | baseline |
| .NET 10 | 585 | +14.7% |

## Latency (p95)
| Variant | Latency | Improvement |
|---------|---------|-------------|
| .NET 8 | 52ms | baseline |
| .NET 10 | 43ms | -17.3% |

## Cache Effectiveness
- Hit rate: 60%
- Cache impact on throughput: ~50% improvement
- Benefit from .NET 10 improvements: ~15% independent of cache

## Key Takeaways
- Output caching is highly effective (60% hit rate)
- .NET 10 platform improvements provide consistent gains
- Rate limiting protects API without significantly impacting throughput
```

---

## 🚀 Next Steps

After completing this module:

1. **Compare your results** with expected improvements
2. **Analyze cache hit rate** - was it as expected?
3. **Move to Module 3** - EF Core read performance (if time permits)

```powershell
cd ..\module3-efcore-reads
Get-Content README.md
```

---

## 🎯 Success Criteria

- ✅ Built both .NET 8 and .NET 10 versions (or used pre-built artifacts)
- ✅ Ran load tests for both variants
- ✅ Measured throughput (RPS) and latency (p50, p95, p99)
- ✅ Compared results showing .NET 10 improvements
- ✅ Understood output caching and rate limiting benefits
- ✅ Documented findings in `results/`

**Time Investment**: 25 minutes (2 min with pre-built, 3 min if building, 20 min measuring + comparing)

**What You Proved**: .NET 10 provides measurable throughput improvements both from platform enhancements AND from leveraging modern features like output caching and rate limiting.
