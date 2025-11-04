# Module 1: Runtime Performance

**Duration: 20 minutes**  
**Objective**: Measure the real performance differences between .NET 8 and .NET 10

## Run It

```powershell
# Quick start with pre-built binaries
.\measure-coldstart.ps1
.\measure-size.ps1
.\measure-memory.ps1

# Or build from source first
.\build-all.ps1
```

## The Business Problem

Meijer runs hundreds of microservices across 240 stores. Each service instance costs money:

- **Cold-start time**: Services in Kubernetes take 800ms to start → slow pod scaling during traffic spikes
- **Binary size**: Larger containers = longer deployment times, higher bandwidth costs
- **Memory usage**: 80MB per instance × 1,000 instances = 80GB memory footprint

**The Issue**: Current .NET 8 services are functional but expensive at scale:
```
Scenario: Black Friday traffic spike (10× normal load)
Current: 800ms startup → Takes 2-3 minutes to scale 100 pods
         80MB memory per pod → Requires expensive large nodes
         
Impact: Customers see slow checkout pages during peak hours
        Operations team deploys more expensive infrastructure "just in case"
```

## What You'll Measure

Compare 4 deployment strategies to find the best fit:

| Variant | Cold-Start | Binary Size | Memory | Best For |
|---------|-----------|-------------|---------|----------|
| .NET 8 FX | ~800 ms | ~2 MB | ~80 MB | Traditional servers |
| .NET 8 AOT | ~150 ms | ~15 MB | ~50 MB | Containers (size matters) |
| .NET 10 FX | ~700 ms | ~2 MB | ~70 MB | Migrating existing apps |
| .NET 10 AOT | ~120 ms | ~12 MB | ~40 MB | **Serverless, auto-scaling** |

**Expected improvements with .NET 10**:
- ✅ 15-20% faster cold-starts
- ✅ 5-10% smaller AOT binaries  
- ✅ 10-15% lower memory usage
- ✅ Better throughput under load

## The Old Approach (.NET 8)

Meijer's current deployment uses Framework-Dependent builds:

```yaml
# Kubernetes deployment
spec:
  containers:
  - name: pricing-service
    image: pricing:net8-fx
    resources:
      memory: "128Mi"      # Needs headroom for 80MB working set
      cpu: "250m"
    readinessProbe:
      httpGet:
        path: /health
      initialDelaySeconds: 3  # Wait for 800ms startup
```

**Problems**:
- ❌ Slow scaling: 800ms startup means slow response to traffic spikes
- ❌ Memory overhead: 80MB per pod limits pod density on nodes
- ❌ Resource waste: Need to over-provision for startup delays

## The .NET 10 Solution: Choose Your Deployment Model

### Framework-Dependent (FX) - Best for Traditional Servers

```yaml
spec:
  containers:
  - name: pricing-service
    image: pricing:net10-fx      # ← Just retarget, smaller runtime
    resources:
      memory: "96Mi"              # ← 15% lower memory
      cpu: "250m"
    readinessProbe:
      initialDelaySeconds: 2      # ← 15% faster startup
```

**Improvements**:
- ✅ 15% faster startup (800ms → 700ms)
- ✅ 15% lower memory (80MB → 70MB)
- ✅ Same deployment model
- ✅ Minimal code changes

### Native AOT - Best for Auto-Scaling & Serverless

```yaml
spec:
  containers:
  - name: pricing-service
    image: pricing:net10-aot     # ← AOT compilation
    resources:
      memory: "64Mi"              # ← 50% lower memory
      cpu: "250m"
    readinessProbe:
      initialDelaySeconds: 1      # ← 85% faster startup
```

**Improvements**:
- ✅ 85% faster startup (800ms → 120ms)
- ✅ 50% lower memory (80MB → 40MB)
- ✅ Self-contained (no runtime dependency)
- ✅ Perfect for horizontal pod autoscaler

## Real-World Impact: Black Friday Traffic Spike

**Before (.NET 8 FX)**:
```
10:00 AM: Traffic spike starts (2,000 → 20,000 req/sec)
10:01 AM: HPA triggers (scale 10 → 100 pods)
10:03 AM: Pods ready (800ms startup × staggered starts)
         
Result: 3 minutes of degraded performance
```

**After (.NET 10 AOT)**:
```
10:00 AM: Traffic spike starts (2,000 → 20,000 req/sec)
10:01 AM: HPA triggers (scale 10 → 100 pods)
10:01:30: Pods ready (120ms startup)
         
Result: 30 seconds to full capacity (6× faster)
```

**ROI**:
- **Better Customer Experience**: Faster scaling = fewer timeouts
- **Lower Infrastructure Costs**: 50% memory reduction = 2× pod density
- **Simplified Operations**: Faster deployments, quicker rollbacks

## The Measurements

### 1. Cold-Start Time

```powershell
.\measure-coldstart.ps1
```

**What it measures**: Time from process start to first HTTP 200 response

**Why it matters**: Kubernetes readiness probes, auto-scaling speed, serverless cold-starts

**Expected results**:
- .NET 8 FX: ~800ms
- .NET 10 FX: ~700ms (15% faster)
- .NET 10 AOT: ~120ms (85% faster)

### 2. Binary Size

```powershell
.\measure-size.ps1
```

**What it measures**: Total size of published output

**Why it matters**: Container image size, deployment bandwidth, storage costs

**Expected results**:
- FX builds: ~2MB (no runtime included)
- .NET 8 AOT: ~15MB (includes runtime)
- .NET 10 AOT: ~12MB (better trimming, 20% smaller)

**Note**: AOT binaries are larger because they include the runtime, but eliminate the need for a separate .NET runtime layer in containers.

### 3. Memory Usage Under Load

```powershell
.\measure-memory.ps1
```

**What it measures**: Peak working set during sustained 500 req/sec load

**Why it matters**: Pod density, node utilization, infrastructure costs

**Expected results**:
- .NET 8 FX: ~80MB
- .NET 10 FX: ~70MB (15% lower)
- .NET 10 AOT: ~40MB (50% lower)

## What the PricingService Does

Simple pricing calculation API (no database, pure compute):

```csharp
// Endpoint
app.MapPost("/api/pricing/calculate", (PricingRequest req) =>
{
    var calculator = new PricingCalculator();
    return calculator.Calculate(req);
});

// Business logic
public PricingResponse Calculate(PricingRequest request)
{
    var product = GetProduct(request.Sku);  // In-memory lookup
    var basePrice = product.BasePrice * request.Quantity;
    var discount = ApplyDiscount(basePrice, request.CustomerId);
    return new PricingResponse { Total = basePrice - discount };
}
```

**Why this design**:
- ✅ No I/O variability (isolates runtime performance)
- ✅ Uses value types (Money, SKU, Quantity) to minimize allocations
- ✅ Typical API pattern (JSON in/out, compute in middle)

---

## "But We Already Do This!" - Addressing Common Pushback

### Pushback #1: "We already use .NET 8 - it's fast enough"

**You might say**: "Our services start in under a second. Why optimize further?"

**Response**: .NET 8 is excellent, but scale changes the equation:

**When "fast enough" isn't enough**:
- **Auto-scaling scenarios**: 100 pods × 800ms = 80 seconds total startup time during traffic spikes
- **Serverless**: Azure Functions charge for execution time - 800ms cold-start per invocation adds up
- **Cost at scale**: 80MB vs 40MB = 2× pod density = 50% infrastructure savings

**Real example**:
```
Meijer Black Friday: 10 → 100 pods in 1 minute
.NET 8 FX: ~3 minutes to all pods ready
.NET 10 AOT: ~30 seconds to all pods ready

Difference: 2.5 minutes of degraded customer experience
```

### Pushback #2: "AOT binaries are huge - that's a deal-breaker"

**You might say**: "15MB vs 2MB is a 7× size increase. We can't accept that."

**Response**: Look at the full container image, not just the binary:

**Framework-Dependent container**:
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0  # 216MB base
COPY publish/ /app                        # +2MB app
# Total: 218MB
```

**Native AOT container**:
```dockerfile
FROM mcr.microsoft.com/dotnet/nightly/runtime-deps:10.0  # 122MB base
COPY publish/ /app                                       # +12MB app
# Total: 134MB (38% smaller!)
```

**Why AOT is actually smaller**:
- FX needs full ASP.NET runtime (JIT, reflection, etc.)
- AOT includes only what you use (trimmed runtime)
- Result: Smaller containers, faster pulls

### Pushback #3: "We can't use AOT - we need reflection"

**You might say**: "Our code uses reflection for JSON serialization, dependency injection, etc."

**Response**: Modern .NET handles this with source generators:

**Old reflection code (incompatible with AOT)**:
```csharp
JsonSerializer.Deserialize<Product>(json);  // ← Fails at runtime in AOT
```

**New source-gen code (AOT-compatible)**:
```csharp
[JsonSerializable(typeof(Product))]
public partial class AppJsonContext : JsonSerializerContext { }

JsonSerializer.Deserialize(json, AppJsonContext.Default.Product);  // ← Works!
```

**Most common patterns now support AOT**:
- ✅ JSON serialization (System.Text.Json with source generators)
- ✅ Dependency injection (minimal API, constructor injection)
- ✅ Configuration binding (IOptions with source generators)
- ✅ HTTP clients (typed clients with source generators)

**When you can't use AOT**:
- ❌ Heavy reflection (dynamic proxy generation)
- ❌ Runtime code generation (T4 templates, Roslyn compilation)
- ❌ Third-party libraries that haven't updated

**For this workshop**: PricingService is intentionally AOT-compatible to show the benefits

### Pushback #4: "Our customers don't care about milliseconds"

**You might say**: "800ms vs 120ms - customers won't notice 680ms"

**Response**: Customers don't see startup time directly, but they feel the effects:

**Scenario 1: Deployment velocity**
```
Rolling update of 50 pods:
.NET 8 FX: 800ms startup × 50 = 40 seconds minimum
.NET 10 AOT: 120ms startup × 50 = 6 seconds minimum

Impact: 6× faster deployments = less risk, more frequent releases
```

**Scenario 2: Auto-scaling during flash sales**
```
Traffic spike: 1,000 → 10,000 req/sec
Need to scale: 10 → 100 pods

.NET 8 FX: Pods ready in 3 minutes → Errors/timeouts for 2.5 minutes
.NET 10 AOT: Pods ready in 30 seconds → Errors/timeouts for 15 seconds

Impact: 10× fewer failed requests
```

**Scenario 3: Cost optimization**
```
1,000 pods × 80MB = 80GB memory
.NET 10 AOT: 1,000 pods × 40MB = 40GB memory

Impact: 50% lower memory cost, or 2× more services per node
```

---

## Summary: When to Use Each Deployment Model

**Use Framework-Dependent (.NET 10 FX) when**:
- ✅ Migrating existing .NET 8 apps (minimal code changes)
- ✅ Long-running services (VMs, on-prem servers)
- ✅ Need full reflection/dynamic features
- ✅ Build time matters more than startup time

**Use Native AOT (.NET 10 AOT) when**:
- ✅ Serverless functions (Azure Functions, AWS Lambda)
- ✅ Kubernetes with auto-scaling (HPA)
- ✅ Container-heavy environments (cost optimization)
- ✅ Services that start/stop frequently

**Key takeaway**: .NET 10 gives you the flexibility to choose the right model for each service. Not every service needs AOT, but having the option unlocks new deployment patterns.

---

## Quick Reference: Build & Measure Commands

```powershell
# Build all 4 variants (takes ~10 minutes)
.\build-all.ps1

# Or use pre-built artifacts (instant)
# Located in: ..\..\artifacts\pub8-fx, pub8-aot, pub10-fx, pub10-aot

# Measure cold-start (5 minutes)
.\measure-coldstart.ps1

# Measure binary size (1 minute)
.\measure-size.ps1

# Measure memory under load (8 minutes)
.\measure-memory.ps1
```

## Troubleshooting

**`dotnet-counters` not found**: `dotnet tool install -g dotnet-counters`

**Port 5000 in use**: `Stop-Process -Name "PricingService" -Force`

**AOT build fails**: Install Visual Studio Build Tools with "Desktop development with C++"

---

## Next Steps

```powershell
cd ..\module2-aspnetcore
```

Module 2 covers **ASP.NET Core performance**: output caching, rate limiting, and throughput improvements.
