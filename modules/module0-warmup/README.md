# Module 0: Workshop Warmup & Context

**Duration: 5 minutes**  
**Objective**: Understand the business case for upgrading from .NET 8 to .NET 10 and the performance improvements you'll measure.

---

## 🎯 Learning Objectives

By the end of this module, you will:
1. Understand the e-commerce microservice architecture used in this workshop
2. Learn about the performance bar for .NET 10
3. See real-world business impact of runtime improvements
4. Preview the 7 modules and what you'll measure

---

## 📊 The Business Case

### Scenario: E-Commerce Microservices at Scale

You're managing an e-commerce platform with three critical microservices:
- **PricingService**: Calculates prices with promotional discounts (Module 1)
- **PromotionsAPI**: Manages promotions with HTTP caching (Module 2)
- **ProductCatalog**: Full CRUD operations with EF Core (Modules 3-5)

### Current Pain Points (.NET 8)

| Issue | Business Impact |
|-------|----------------|
| Cold-start latency (800ms) | Poor user experience on first load |
| Large binary sizes (40MB+ with AOT) | Slow container deployments, high bandwidth costs |
| High memory footprint (150MB+ per pod) | Increased hosting costs in Kubernetes |
| Slow database bulk updates | Long maintenance windows for promotional campaigns |
| String concatenation allocations | GC pressure during peak traffic |

### Expected Improvements (.NET 10)

| Metric | .NET 8 Baseline | .NET 10 Target | Business Value |
|--------|-----------------|----------------|----------------|
| Cold-start time | 800ms | 120ms (~85% faster) | Instant serverless functions, better UX |
| Binary size (AOT) | 15MB | 12MB (~20% smaller) | Faster deployments, lower bandwidth costs |
| Memory usage | 150MB | 100MB (~33% reduction) | 33% more pods per node, lower costs |
| Bulk update speed | 10,000 rows/sec | 50,000 rows/sec (5x) | Faster promo updates, shorter maintenance |
| String allocations | High GC pressure | Near-zero allocations | Stable latency during traffic spikes |

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                       Client Browser                         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   API Gateway (Not Covered)                  │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ PricingService│   │PromotionsAPI │   │ProductCatalog│
│  (Module 1)   │   │  (Module 2)   │   │ (Modules 3-5)│
│               │   │               │   │               │
│ - Price calc  │   │ - HTTP cache  │   │ - EF Core     │
│ - No DB       │   │ - Rate limit  │   │ - CRUD ops    │
│ - Pure compute│   │ - Caching     │   │ - Bulk updates│
└──────────────┘    └──────────────┘    └──────────────┘
                                                │
                                                ▼
                                        ┌──────────────┐
                                        │  SQL Server  │
                                        │  PostgreSQL  │
                                        │    SQLite    │
                                        └──────────────┘
```

---

## 📚 Workshop Module Roadmap

### Module 1: Runtime Performance (20 minutes)
**PricingService** - Measure cold-start time, binary size, memory usage
- ✅ No database required
- ✅ Compare .NET 8 vs .NET 10
- ✅ Compare Framework-Dependent vs Native AOT

### Module 2: HTTP Caching & Rate Limiting (20 minutes)
**PromotionsAPI** - Measure cache hit rates, rate limiting effectiveness
- ✅ Uses output caching (new in .NET 8, improved in .NET 10)
- ✅ Fixed-window rate limiting
- ✅ No database required

### Module 3: EF Core Performance - Reads (15 minutes)
**ProductCatalog** - Measure query performance, async patterns
- ⚠️ Requires SQL Server, PostgreSQL, or SQLite
- ✅ Compare compiled queries vs regular queries
- ✅ Measure pagination performance

### Module 4: EF Core Performance - Writes (15 minutes)
**ProductCatalog** - Measure bulk insert/update/delete speed
- ⚠️ Requires database from Module 3
- ✅ JSON column updates with ExecuteUpdate (FR-28)
- ✅ Bulk operations performance

### Module 5: EF Core Advanced (15 minutes)
**ProductCatalog** - Measure advanced scenarios
- ⚠️ Requires database from Module 3
- ✅ N+1 query detection
- ✅ Connection pooling impact
- ✅ Change tracking overhead

### Module 6: C# 14 Language Features (10 minutes)
**Code Samples** - Modern C# syntax and performance
- ✅ Collection expressions
- ✅ Primary constructors
- ✅ Params collections
- ✅ Field keyword in properties

### Module 7: Real-World Deployment (10 minutes)
**Docker & Kubernetes** - Deploy .NET 8 vs .NET 10
- ✅ Container image size comparison
- ✅ Startup time in containers
- ✅ Kubernetes resource limits

---

## 🚀 Quick Start

### Prerequisites Checklist

Before starting Module 1, verify your environment:

```powershell
# Run the prerequisites check script
.\shared\Scripts\check-prerequisites.ps1
```

Expected output:
```
✅ .NET 8 SDK installed (8.0.x)
✅ .NET 10 SDK installed (10.0.x or 9.0.x as placeholder)
✅ PowerShell 7+ installed
✅ Git installed
✅ Docker installed (optional for Module 7)
✅ Load testing tool installed (bombardier or wrk)
```

### Workshop Structure

Each module follows this pattern:
1. **README.md** - Objectives, instructions, expected results
2. **Source code** - Microservice implementation(s)
3. **Build scripts** - `build-all.ps1` for all variants
4. **Measurement scripts** - `measure-<metric>.ps1` for each metric
5. **Results folder** - Store your measurements for comparison

---

## 📊 Measurement Approach

### Fair Comparison Principles

To ensure apples-to-apples comparisons:

1. **Identical Code**: Same business logic across .NET 8 and .NET 10
2. **Isolated Processes**: Each measurement runs in a separate process
3. **Warm-up Iterations**: Discard first 3 requests to JIT compile hot paths
4. **Multiple Samples**: Average of 10 measurements per metric
5. **Consistent Load**: Same request patterns for all tests

### Metrics You'll Collect

| Metric | Tool | Module |
|--------|------|--------|
| Cold-start time | PowerShell `Measure-Command` | 1 |
| Binary size | `Get-ChildItem` | 1 |
| Memory usage | `dotnet-counters` | 1 |
| HTTP throughput | `bombardier` or `wrk` | 1, 2 |
| Cache hit rate | Custom counters | 2 |
| Rate limit effectiveness | HTTP status codes | 2 |
| Query performance | SQL profiler + EF logs | 3, 4, 5 |
| Bulk update speed | EF Core logging | 4 |
| Container size | Docker CLI | 7 |

---

## 🎓 Learning Philosophy

### Educational Clarity
- **5-minute runability**: Pre-built artifacts in `artifacts/` folder
- **Simple code**: No complex frameworks or patterns
- **Clear outputs**: Measurement scripts show before/after comparison

### Fair Comparison
- **Consistent hardware**: All tests run on your machine
- **Same business logic**: No differences in algorithmic complexity
- **Documented tradeoffs**: Understand when to use Framework-Dependent vs AOT

### Production Patterns
- **Real microservices**: Not toy examples
- **Docker support**: Deployable to Kubernetes
- **Observability**: Logging, metrics, health checks

### Incremental Complexity
- **Module 1**: Simplest (no database)
- **Module 2**: Adds HTTP caching
- **Modules 3-5**: EF Core complexity
- **Module 6**: Language features
- **Module 7**: Deployment

### Enterprise Context
- **Multi-microservice**: 3 different services
- **Polyglot persistence**: Support SQL Server, PostgreSQL, SQLite
- **Production-ready**: Health checks, graceful shutdown

---

## 🛠️ Troubleshooting

### Issue: .NET 10 SDK not available

**Solution**: Use .NET 9 as a placeholder. The APIs are compatible, and you'll still see performance improvements.

```powershell
dotnet --list-sdks
# If you see 9.0.x, that's fine for this workshop
```

### Issue: Prerequisite script fails

**Solution**: Run the setup script to install missing tools:

```powershell
.\shared\Scripts\setup-environment.ps1
```

### Issue: "Permission denied" on scripts

**Solution**: Ensure PowerShell execution policy allows scripts:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## 📝 Note-Taking Template

Use this template to track your findings:

```
# My .NET 8 to .NET 10 Upgrade Results

## Module 1: Runtime Performance
- Cold-start time (FX): .NET 8 = ___ ms, .NET 10 = ___ ms
- Cold-start time (AOT): .NET 8 = ___ ms, .NET 10 = ___ ms
- Binary size (FX): .NET 8 = ___ MB, .NET 10 = ___ MB
- Binary size (AOT): .NET 8 = ___ MB, .NET 10 = ___ MB
- Memory usage (FX): .NET 8 = ___ MB, .NET 10 = ___ MB

## Module 2: HTTP Caching & Rate Limiting
- Cache hit rate: .NET 8 = ___%, .NET 10 = ___%
- Rate limit accuracy: .NET 8 = ___, .NET 10 = ___

... (continue for all modules)
```

---

## 🎯 Success Criteria

By the end of the workshop, you should have:
- ✅ Completed measurements for at least Modules 0-2 (MVP)
- ✅ Documented performance improvements in your notes
- ✅ Understood tradeoffs between Framework-Dependent and AOT
- ✅ Identified which modules are relevant to your production workloads

---

## 🚀 Ready to Start?

Move to **Module 1: Runtime Performance** to measure your first metrics!

```powershell
cd modules\module1-runtime
Get-Content README.md
```

---

**Estimated Time Allocation:**
- Module 0: 5 minutes (this document)
- Module 1: 20 minutes (MVP)
- Module 2: 20 minutes (MVP)
- Modules 3-7: 65 minutes (optional depth)
- Buffer: 10 minutes

**Total Workshop Time: 2 hours (120 minutes)**
