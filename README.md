# .NET 8 → .NET 10 (LTS → LTS) Performance Lab Workshop  
**Duration**: 2 hours | **Level**: Intermediate | **Focus**: LTS-to-LTS Performance Improvements  
**Status**: 🚧 MVP Complete (Module 0 + Module 1) - 25 minutes runnable

## Welcome! 👋

This hands-on workshop compares **.NET 8** and **.NET 10** LTS releases using realistic retail scenarios. You'll measure real performance improvements and learn when to migrate your applications.

### What You'll Learn

- 🚀 **Runtime Performance**: Measure cold-start improvements (80%+ faster with Native AOT)
- ⚡ **API Throughput**: See throughput and latency gains (15%+ improvement)
- 💻 **Modern C#**: Explore C# 14 features that reduce boilerplate
- 📊 **Data Layer**: Optimize EF Core 10 JSON operations (30%+ faster)
- 🐳 **Containers**: Compare Docker image sizes (10%+ smaller)
- 📋 **Migration Planning**: Prioritize your services with a decision matrix

### Prerequisites

- Windows 10/11 with PowerShell 7+
- .NET 8 SDK (required) - .NET 9/10 SDK (optional, for full comparison)
- Basic C# knowledge
- Optional: Docker Desktop, bombardier/wrk for load testing

### Quick Start (MVP - 25 minutes)

1. **Check Prerequisites**:
   ```powershell
   .\shared\Scripts\check-prerequisites.ps1
   ```

2. **Run the MVP Workshop**:
   ```powershell
   # See QUICKSTART-MVP.md for detailed instructions
   cd modules\module0-warmup
   Get-Content README.md | more  # 5 min read
   
   cd ..\module1-runtime
   dotnet build                   # 3 min
   .\measure-coldstart.ps1        # 5 min
   .\measure-size.ps1             # 2 min
   .\measure-memory.ps1           # 8 min (optional)
   ```

3. **Check Implementation Status**:
   ```powershell
   Get-Content IMPLEMENTATION-STATUS.md | more
   # See what's complete and what's pending
   ```

### Current Status

- ✅ **Module 0**: Workshop Context (complete)
- ✅ **Module 1**: Runtime Performance (complete, .NET 8 only)
- ⏳ **Modules 2-7**: Coming soon (see IMPLEMENTATION-STATUS.md)

---

## 🗂️ Modules

### 0. Warm-Up & Framing (5 min)
- The retail performance bar: <100 ms API hops, zero-downtime during promos.
- What we’ll measure: startup time, p50/p95 latency, memory footprint, and container size.
- Why now: both .NET 8 and 10 are LTS; this is the next safe modernization step.

---

### 1. Runtime & Startup — Cold Start, Memory, Size (20 min)  
**Scenario:** *Pricing microservice startup benchmark.*

- Publish the same app under **.NET 8** and **.NET 10**.  
- Compare **framework-dependent** vs **Native AOT** builds using ready scripts.  
- Record binary sizes, time-to-first-200 OK, and working-set memory.

**Value for Meijer**
- Faster scale-to-zero APIs → lower cloud cost on promo bursts.
- Native AOT expands supported patterns and trims cold latency.

---

### 2. ASP.NET Core 10 — Throughput, Caching, Auth (25 min)  
**Scenario:** *Promotions API stress test.*

- Baseline .NET 8 minimal API → load test.  
- Upgrade to .NET 10:
  - Enable **Output/Response Caching**
  - Add **Rate Limiting**
  - Observe new **OpenAPI & diagnostics** behavior
  - Discuss **Identity Passkeys** for loyalty logins.

**Key Takeaways**
- Higher RPS and lower tail latency under identical load.  
- Safer defaults and simpler observability.  
- Prepares for future SSO/passkey rollout.

---

### 3. C# 14 — Modern Language Features for Large Codebases (30 min)  
**Goal:** Reduce boilerplate and risk in large enterprise solutions.

**Side-by-side demos**
1. **Extension Members** — consolidate cross-cutting concerns without modifying core types.  
2. **Field-Backed Properties** — lightweight validation/logging hooks.  
3. **Partial Constructors / Events** — cleaner layering with source generators.  
4. **User-Defined Compound Operators** — richer value objects (`Money += Discount`).  
5. **Expanded `Span<T>` Conversions** — fewer allocations in hot loops.  
6. **`nameof` on unbound generics** + **null-conditional assignment** — safer refactors.

**Value**
- Leaner domain models (SKU, Money, Cart) and fewer runtime allocations.

---

### 4. Data Layer — EF Core 10 Enhancements (15 min)  
**Scenario:** *Inventory attributes with JSON columns.*

- In EF 8: load → modify → `SaveChanges`.  
- In EF 10: use `ExecuteUpdate` with JSON path updates.  
- Observe fewer round trips and simpler code.  
- Optional: explore **vector containers** for recommendation/search workloads.

**Value**
- Faster nested updates in catalog and inventory tables.  
- Clear path toward hybrid relational + vector data patterns.

---

### 5. Containers & Deployment (10 min)
- Build images on `aspnet:8.0` vs `aspnet:10.0`.  
- Compare image size, startup, and memory in Docker.  
- Optional: AOT container for “pricing microservice.”

**Value**
- Smaller, faster images → faster CI/CD rollout and lower runtime memory pressure.

---

### 6. Wrap-Up & Migration Plan (5 min)
- Start with high-traffic APIs (checkout, cart, pricing).  
- Canary with A/B telemetry before full rollout.  
- Maintain LTS cadence to stay ahead of security fixes (e.g., Kestrel CVEs).  
- Resources: .NET 10 docs, EF 10 guide, and Meijer-internal perf dashboards.

---

## 🧰 Pre-Workshop Setup

| Requirement | Notes |
|--------------|-------|
| .NET 8 SDK & .NET 10 SDK | Verify with `dotnet --list-sdks` |
| VS Code / Visual Studio 2022 | Developer preference |
| Optional: Docker Desktop | For container module |
| Optional: Visual Studio Build Tools w/ Desktop C++ | Required for Native AOT on Windows |

Clone this repo and check out the `main` branch. Each module lives under `/labs/<module-name>` with its own README and scripts.

---

## 🧪 Deliverables

- **Working microservice samples** targeting both LTS frameworks.  
- **Benchmark tables** (startup / memory / throughput).  
- **C# 14 feature snippets** ready for production refactors.  
- **Migration checklist** for Meijer’s internal modernization roadmap.

---

## 📎 Resources

- [.NET 10 Release Notes](https://learn.microsoft.com/dotnet/core/whats-new/dotnet-10)  
- [C# 14 Language Features Overview](https://learn.microsoft.com/dotnet/csharp/whats-new/csharp-14)  
- [EF Core 10 Docs](https://learn.microsoft.com/ef/core/what-is-new/efcore-10)  
- [Native AOT Prerequisites](https://aka.ms/nativeaot-prerequisites)  
- [Kestrel Security Updates](https://learn.microsoft.com/aspnet/core/fundamentals/servers/kestrel/security)  

---

**Next step:**  
Start in `/labs/runtime-startup` to compare .NET 8 vs 10 cold-start and memory usage. The rest of the modules build on that foundation.
