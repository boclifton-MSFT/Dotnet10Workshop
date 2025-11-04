# Module 5: Container Optimization

**Duration: 15 minutes**  
**Objective**: Reduce container image size and improve Kubernetes deployment speed with .NET 10

## Run It

```powershell
# Build container images (requires Docker Desktop)
.\build-images.ps1

# Compare image sizes
.\compare-images.ps1

# Test startup times
.\test-containers.ps1
```

## The Business Problem

Meijer runs containerized microservices across 240 stores in Kubernetes:

- **Slow Deployments**: Rolling updates take 45 minutes to deploy across all stores
- **High Bandwidth Costs**: Pulling 295MB images × 1,200 pods = 354GB per deployment
- **Slow Auto-Scaling**: New pods take 12+ seconds to start during traffic spikes
- **Storage Costs**: Container registry stores multiple versions of every service

**The Issue**: Large container images slow everything down:
```
Scenario: Emergency hotfix deployment (critical bug fix)
Current: 295 MB image × 1,200 pods × 8s pull time = 2.6 hours to fully deploy
         During this time, some stores run old buggy version
         
Impact: Revenue loss from checkout bugs
        Customer support overload
        Engineering team on-call stress
```

## What You'll Measure

Compare .NET 8 vs .NET 10 container metrics:

| Metric | .NET 8 | .NET 10 | Improvement |
|--------|--------|---------|-------------|
| Base Image | 216 MB | 190 MB | **-12% (26MB)** |
| Total Image | 295 MB | 265 MB | **-10% (30MB)** |
| Pull Time | 8 sec | 7 sec | **-12%** |
| Cold Start | 2.3 sec | 1.95 sec | **-15%** |
| Warm Start | 1.1 sec | 0.95 sec | **-14%** |

**Expected improvements**:
- ✅ 30MB smaller images = faster pulls
- ✅ 15% faster startup = quicker scaling
- ✅ Lower registry costs
- ✅ Faster deployments

## The Old Approach (.NET 8 Containers)

Meijer's current container deployment:

```dockerfile
# Dockerfile.net8
FROM mcr.microsoft.com/dotnet/aspnet:8.0  # 216 MB base image

WORKDIR /app
COPY artifacts/prom8-fx .                 # + 79 MB app

ENTRYPOINT ["./PromotionsAPI"]
```

**Kubernetes deployment**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: promotions-api
spec:
  replicas: 5  # Per store
  template:
    spec:
      containers:
      - name: promotions
        image: meijer.azurecr.io/promotions:net8  # 295 MB
        imagePullPolicy: Always
```

**Problems**:
- ❌ 295MB image takes 8 seconds to pull per pod
- ❌ 2.3 second cold-start delays auto-scaling
- ❌ 240 stores × 5 pods = 1,200 pulls per deployment
- ❌ Registry bandwidth: 354GB per deployment

## The .NET 10 Solution

Smaller runtime, faster startup:

```dockerfile
# Dockerfile.net10
FROM mcr.microsoft.com/dotnet/aspnet:10.0  # 190 MB base (26MB smaller!)

WORKDIR /app
COPY artifacts/prom10-fx .                 # + 75 MB app (4MB smaller!)

ENTRYPOINT ["./PromotionsAPI"]
```

**Improvements**:
- ✅ 265MB total image (10% smaller)
- ✅ 7 second pull time (12% faster)
- ✅ 1.95 second cold-start (15% faster)
- ✅ 318GB bandwidth per deployment (36GB savings)

## Real-World Impact: Hotfix Deployment Across All Stores

**Before (.NET 8)**:
```
Time 0:00: Critical checkout bug discovered
Time 0:05: Hotfix tested, image built (295 MB)
Time 0:10: Rolling update starts (20% at a time to avoid downtime)
           
Batch 1 (240 pods): 295MB × 240 = 70.8GB transferred
                    8s pull + 2.3s start × 240 pods = 41 minutes

Batch 2 (240 pods): 41 more minutes
Batch 3 (240 pods): 41 more minutes
Batch 4 (240 pods): 41 more minutes
Batch 5 (240 pods): 41 more minutes

Time 3:25: All stores updated
         
Result: 3.5 hours with checkout bug impacting customers
```

**After (.NET 10)**:
```
Time 0:00: Critical checkout bug discovered
Time 0:05: Hotfix tested, image built (265 MB)
Time 0:10: Rolling update starts (20% at a time)
           
Batch 1 (240 pods): 265MB × 240 = 63.6GB transferred
                    7s pull + 1.95s start × 240 pods = 36 minutes

Batch 2-5: 36 minutes each

Time 3:10: All stores updated
         
Result: 3 hours to fix (15 minutes faster = fewer impacted transactions)
```

**ROI**:
- **15% faster deployments** = quicker bug fixes
- **10% bandwidth savings** = 7.2GB saved per deployment
- **Better auto-scaling** = handle traffic spikes faster
- **Lower registry costs** = smaller images to store

## How to Run the Demo

### Prerequisites

```powershell
# Install Docker Desktop (if not already installed)
# https://www.docker.com/products/docker-desktop

# Verify Docker is running
docker --version
```

### Build and Compare

```powershell
# Build both .NET 8 and .NET 10 images
.\build-images.ps1

# Compare image sizes
.\compare-images.ps1
```

**Expected output**:
```
=== Container Image Comparison ===

.NET 8 Image:
  • Total Size: 295 MB
  • Base Image: 216 MB (mcr.microsoft.com/dotnet/aspnet:8.0)
  • App Layer: 79 MB (PromotionsAPI + dependencies)

.NET 10 Image:
  • Total Size: 265 MB (-10%)
  • Base Image: 190 MB (mcr.microsoft.com/dotnet/aspnet:10.0) [-26MB]
  • App Layer: 75 MB (PromotionsAPI + dependencies) [-4MB]

✓ 30 MB smaller (10% reduction)
✓ Faster pulls, faster scaling
```

### Test Startup Performance

```powershell
# Start .NET 8 container
docker run --name promotions-net8 -p 5000:8080 -d --rm promotions-service:net8

# Start .NET 10 container  
docker run --name promotions-net10 -p 5001:8080 -d --rm promotions-service:net10

# Check startup times in logs
docker logs promotions-net8 | Select-String "started"
docker logs promotions-net10 | Select-String "started"

# Test endpoints
curl http://localhost:5000/health
curl http://localhost:5001/health

# Cleanup
docker stop promotions-net8 promotions-net10
```

## Understanding the Size Reduction

### Image Layer Breakdown

**. NET 8 Container (295 MB)**:
```
├── Base Linux (Debian Slim)      70 MB
├── .NET 8 Runtime               140 MB  ← Heavy runtime
├── ASP.NET Core Libraries         6 MB
└── Application (PromotionsAPI)   79 MB
    ├── IL Assemblies             65 MB
    ├── Dependencies              12 MB
    └── Config files               2 MB
```

**.NET 10 Container (265 MB)**:
```
├── Base Linux (Debian Slim)      68 MB  ← 2MB smaller base
├── .NET 10 Runtime              115 MB  ← 25MB smaller! 
├── ASP.NET Core Libraries         7 MB
└── Application (PromotionsAPI)   75 MB  ← 4MB smaller
    ├── IL Assemblies             62 MB  ← Better compilation
    ├── Dependencies              11 MB  ← Trimmed deps
    └── Config files               2 MB
```

### Why .NET 10 Runtime Is 25MB Smaller

1. **Removed deprecated APIs**
   - Legacy remoting infrastructure
   - Old XML serializers
   - Unused compatibility shims

2. **Optimized JIT compiler**
   - More efficient code generation
   - Better compression
   - Smaller tiered compilation artifacts

3. **Trimmed base libraries**
   - Only include what ASP.NET Core needs
   - Removed desktop-only components
   - Better library factoring

4. **Improved native code**
   - More efficient P/Invoke stubs
   - Smaller R2R (ReadyToRun) images
   - Better dead code elimination

## Cost Analysis: Storage & Bandwidth

### Container Registry Costs

**Azure Container Registry (Premium tier)**:
```
Current (.NET 8):
  295 MB × 10 versions × 50 services = 147.5 GB stored
  Cost: 147.5 GB × $0.024/GB/day = $3.54/day
  Annual: $1,292

With .NET 10:
  265 MB × 10 versions × 50 services = 132.5 GB stored
  Cost: 132.5 GB × $0.024/GB/day = $3.18/day
  Annual: $1,161

Savings: $131/year per 50 services
```

### Bandwidth Costs

**Deployments per week**: 3 (normal) + 2 (hotfixes) = 5

```
Current (.NET 8):
  295 MB × 1,200 pods × 5 deploys/week = 1.77 TB/week
  Cost: 1.77 TB × $0.087/GB = $154/week
  Annual: $8,008

With .NET 10:
  265 MB × 1,200 pods × 5 deploys/week = 1.59 TB/week
  Cost: 1.59 TB × $0.087/GB = $138/week
  Annual: $7,176

Savings: $832/year in bandwidth costs
```

### Total Annual Savings

```
Container Registry:  $  131
Bandwidth:          $  832
Faster incident fix: $5,000 (estimated customer satisfaction)
─────────────────────────
Total:              $5,963/year

Plus: Intangible benefits
  • Faster deployments = happier developers
  • Quicker scaling = better customer experience
  • Smaller images = easier local development
```

## Kubernetes Auto-Scaling Benefits

### Horizontal Pod Autoscaler (HPA) Performance

**Scenario**: Black Friday traffic spike (10× normal load)

**.NET 8 Scaling Timeline**:
```
11:00:00 - Traffic spike detected (100 → 1000 req/sec)
11:00:05 - HPA triggers scale-up (5 → 50 pods)
11:00:13 - First new pod ready (8s pull + 2.3s start)
11:00:21 - 10 pods ready (staggered starts)
11:00:37 - 25 pods ready
11:00:53 - 50 pods ready (53 seconds total)

Impact: 53 seconds of degraded performance
        Requests timing out, angry customers
```

**.NET 10 Scaling Timeline**:
```
11:00:00 - Traffic spike detected (100 → 1000 req/sec)
11:00:05 - HPA triggers scale-up (5 → 50 pods)
11:00:12 - First new pod ready (7s pull + 1.95s start)
11:00:19 - 10 pods ready (staggered starts)
11:00:33 - 25 pods ready
11:00:47 - 50 pods ready (47 seconds total)

Impact: 47 seconds of degraded performance
        6 seconds faster = fewer failed requests
```

**Result**: 6 seconds faster scaling = ~120 fewer failed requests during spike

## Advanced: Multi-Stage Builds for Even Smaller Images

### Current Single-Stage Build

```dockerfile
# Simple but includes build tools in final image
FROM mcr.microsoft.com/dotnet/sdk:10.0
WORKDIR /app
COPY . .
RUN dotnet publish -c Release -o out
ENTRYPOINT ["dotnet", "out/PromotionsAPI.dll"]

# Result: 700+ MB (includes SDK!)
```

### Optimized Multi-Stage Build

```dockerfile
# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["PromotionsAPI.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Stage 2: Runtime (only this goes in final image)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["./PromotionsAPI"]

# Result: 265 MB (runtime only!)
```

**Benefits**:
- ✅ No build tools in production image
- ✅ Smaller attack surface (fewer packages)
- ✅ Faster security scans
- ✅ Layer caching for dependencies

### Alpine Linux for Minimal Size

```dockerfile
# Use Alpine-based runtime (much smaller base)
FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["./PromotionsAPI"]

# Result: 120 MB! (56% smaller than Debian-based)
```

**Alpine tradeoffs**:
- ✅ 56% smaller base image (68MB → 30MB)
- ✅ Faster pulls and starts
- ⚠️ Uses musl libc (not glibc) - test thoroughly
- ⚠️ Some native dependencies may need rebuilding

## Docker Layer Caching Strategy

### Poor Caching (Slow Builds)

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY . .                    # ← Changes every time = cache miss!
RUN dotnet restore          # ← Always runs
RUN dotnet publish -o out
ENTRYPOINT ["dotnet", "out/PromotionsAPI.dll"]
```

### Optimized Caching (Fast Builds)

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy and restore dependencies FIRST
COPY ["PromotionsAPI.csproj", "./"]
RUN dotnet restore          # ← Cached unless .csproj changes!

# Then copy and build code
COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["./PromotionsAPI"]
```

**Result**:
- First build: 2 minutes
- Subsequent builds (code changes only): 20 seconds
- Subsequent builds (dependency changes): 1 minute

---

## "But We Already Do This!" - Addressing Common Pushback

### Pushback #1: "Our images are already small enough"

**You might say**: "Our .NET 8 images work fine. Why optimize further?"

**Response**: Scale reveals the cost:

**At Meijer's scale**:
```
Scenario: 50 microservices, 240 stores, 5 pods each = 60,000 pods

.NET 8: 60,000 × 295 MB = 17.7 TB in production
.NET 10: 60,000 × 265 MB = 15.9 TB in production

Savings: 1.8 TB less data transferred per deployment
         At 5 deployments/week: 9 TB/week = 468 TB/year
         Cost: 468 TB × $0.087/GB = $40,716/year saved!
```

**Plus**: Faster deployments = fewer hotfix delays = happier customers

### Pushback #2: "Startup time doesn't matter - pods run for days"

**You might say**: "Once a pod is running, startup time is irrelevant."

**Response**: Startup time matters most when you're under pressure:

**Critical scenarios**:

1. **Auto-scaling during traffic spikes**
   - Black Friday flash sale: Need 500 new pods in 1 minute
   - .NET 8: 12s per pod = 6,000 seconds = 100 minutes (unacceptable!)
   - .NET 10: 9.95s per pod = 4,975 seconds = 83 minutes (17% faster)

2. **Pod crashes/restarts**
   - Memory leak → pod OOMKilled → needs immediate replacement
   - 2.3s vs 1.95s = customers get served 350ms sooner

3. **Rolling updates during business hours**
   - Must minimize unavailability window
   - 15% faster startup = 15% shorter vulnerability window

### Pushback #3: "Multi-stage builds are complex"

**You might say**: "Our simple Dockerfiles work. Why complicate things?"

**Response**: Multi-stage builds are simpler than you think:

**Your current Dockerfile** (single-stage):
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0
COPY artifacts/ /app
WORKDIR /app
ENTRYPOINT ["./PromotionsAPI"]
```

**Multi-stage version** (just 4 more lines):
```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["./PromotionsAPI"]
```

**Benefits**:
- ✅ No need to build outside Docker (CI/CD simplifies)
- ✅ Consistent builds across environments
- ✅ Layer caching makes rebuilds fast
- ✅ All devs use same build process

### Pushback #4: "Alpine Linux breaks our dependencies"

**You might say**: "We tried Alpine and got weird native library errors."

**Response**: Alpine requires testing, but .NET 10 improved compatibility:

**Common issues (and fixes)**:

1. **Native dependencies** (OpenSSL, libgdiplus, etc.)
   ```dockerfile
   # Add missing libraries
   RUN apk add --no-cache \
       icu-libs \
       krb5-libs \
       libgcc \
       libintl \
       libssl1.1 \
       libstdc++ \
       zlib
   ```

2. **Culture/globalization**
   ```csharp
   // Enable invariant mode if you don't need localization
   <InvariantGlobalization>true</InvariantGlobalization>
   ```

3. **Time zones**
   ```dockerfile
   RUN apk add --no-cache tzdata
   ```

**Decision matrix**:
- ✅ Use Alpine for: Stateless APIs, microservices, high pod counts
- ⚠️ Stick with Debian for: Heavy native deps, complex globalization
- ✅ .NET 10 makes Alpine easier (better compatibility)

---

## Summary: Container Optimization Benefits

**Size Reduction**:
- 10% smaller images (.NET 8: 295MB → .NET 10: 265MB)
- 12% smaller base runtime (216MB → 190MB)
- 56% smaller with Alpine (265MB → 120MB)

**Speed Improvements**:
- 12% faster image pulls (8s → 7s)
- 15% faster cold starts (2.3s → 1.95s)
- 17% faster full deployments across all stores

**Cost Savings** (for Meijer's scale):
- $832/year in bandwidth costs
- $131/year in registry storage
- $5,000/year in faster incident response
- **Total: ~$6,000/year + intangibles**

**Operational Benefits**:
- ✅ Faster auto-scaling response
- ✅ Quicker hotfix deployments
- ✅ Lower bandwidth during outages
- ✅ Happier developers (faster local builds)

---

## Quick Reference

### Build Multi-Stage Image
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["./MyApp"]
```

### Compare Image Sizes
```powershell
docker images | findstr promotions
# Or
docker image ls --format "table {{.Repository}}\t{{.Size}}" | findstr promotions
```

### Test Startup Time
```powershell
Measure-Command { docker run --rm promotions-service:net10 }
```

---

## Next Steps

```powershell
cd ..\module6-serversentevents
```

Module 6 covers **Server-Sent Events**: Build real-time features with the new SSE API in .NET 10.
