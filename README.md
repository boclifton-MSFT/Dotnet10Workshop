# .NET 8 → .NET 10 (LTS → LTS) Performance Lab Workshop  
**Duration**: 2 hours | **Level**: Intermediate | **Focus**: LTS-to-LTS Performance Improvements  

## Welcome! 👋

This hands-on workshop compares **.NET 8** and **.NET 10** LTS releases using realistic e-commerce scenarios. You'll measure real performance improvements and learn when to migrate your applications.

### What You'll Learn

- 🚀 **Runtime Performance**: Measure cold-start, binary size, and memory usage improvements
- ⚡ **API Throughput**: Compare HTTP caching and rate limiting between versions
- 💻 **Modern C#**: Explore C# 14 features that reduce boilerplate
- 📊 **Data Layer**: Compare EF Core 8 vs EF Core 10 query performance
- 🐳 **Containers**: Build and compare Docker image sizes
- 🌐 **Real-Time Features**: Explore .NET 10's Server-Sent Events API

---

## 📋 Prerequisites

### Required
- **Windows 10/11** with **PowerShell 7+**
- **.NET 8 SDK** (8.0.100 or later)
- **.NET 10 SDK** (10.0.100-rc.2 or later) - for .NET 10 comparisons
- **Visual Studio 2026 Preview** or **VS Code** (optional but recommended)
- **Basic C# knowledge**

### Optional (for specific modules)
- **Docker Desktop** (for Module 5: Containers)
- **Visual Studio Build Tools with C++ Desktop Development** (for Native AOT on Windows)

### Quick Prerequisites Check

```powershell
# Run the automated check
.\shared\Scripts\check-prerequisites.ps1

# Or manually verify
dotnet --list-sdks           # Should show 8.0.x and 10.0.x
$PSVersionTable.PSVersion    # Should be 7.0 or higher
docker --version             # (Optional) For container module
```

---

## 🚀 Quick Start (30 minutes)

### Step 1: Check Prerequisites (2 minutes)

```powershell
# Clone the repository (if you haven't already)
git clone https://github.com/dochoss/Dotnet10Workshop.git
cd Dotnet10Workshop

# Verify prerequisites
.\shared\Scripts\check-prerequisites.ps1
```

### Step 2: Read Workshop Context (5 minutes)

```powershell
cd modules\module0-warmup
# Read the README to understand the business scenario
notepad README.md
# Or use your preferred text editor
```

### Step 3: Measure Runtime Performance (15 minutes)

```powershell
cd ..\module1-runtime

# Build all 4 variants (.NET 8/10, Framework/AOT)
.\build-all.ps1              # Takes 3-5 minutes

# Run measurements
.\measure-coldstart.ps1      # Compare startup times (~2 min)
.\measure-size.ps1           # Compare binary sizes (~1 min)
.\measure-memory.ps1         # Compare memory usage (~3 min)

# Review results in the results\ folder
```

### Step 4: Test API Performance (8 minutes)

```powershell
cd ..\module2-aspnetcore

# Build both .NET 8 and .NET 10 versions
.\build-all.ps1              # Takes 2-3 minutes

# Run load tests (requires bombardier or wrk)
.\load-test.ps1 -Variant NET8
.\load-test.ps1 -Variant NET10

# Compare results
.\compare-results.ps1
```

---

## 📚 Workshop Modules

| Module | Duration | Description |
|--------|----------|-------------|
| **Module 0: Warmup** | 5 min | Workshop context and business case |
| **Module 1: Runtime** | 20 min | Cold-start, size, memory comparison |
| **Module 2: ASP.NET Core** | 25 min | HTTP caching & rate limiting |
| **Module 3: C# 14** | 30 min | Modern language features |
| **Module 4: EF Core** | 15 min | Query performance improvements |
| **Module 5: Containers** | 15 min | Docker image optimization |
| **Module 6: Server-Sent Events** | 15 min | Real-time features in .NET 10 |

**Total Duration**: ~2 hours

---

## � Module Details

### Module 0: Warm-Up & Context (5 min)
📁 `modules/module0-warmup/`

**What You'll Learn:**
- Understand the e-commerce business scenario
- Learn about the performance goals (<100ms API response)
- Preview what you'll measure across all modules

**Action Items:**
```powershell
cd modules\module0-warmup
notepad README.md    # Read the business case
```

---

### Module 1: Runtime Performance (20 min)
📁 `modules/module1-runtime/`

**Scenario:** Compare PricingService startup and resource usage

**What You'll Measure:**

| Metric | .NET 8 FX | .NET 8 AOT | .NET 10 FX | .NET 10 AOT |
|--------|-----------|------------|------------|-------------|
| Cold-Start | ~800ms | ~150ms | ~700ms | ~120ms |
| Binary Size | ~2MB | ~15MB | ~2MB | ~12MB |
| Memory | ~80MB | ~50MB | ~70MB | ~40MB |

**Scripts:**
```powershell
cd modules\module1-runtime

.\build-all.ps1              # Build all 4 variants (3-5 min)
.\measure-coldstart.ps1      # Measure startup times
.\measure-size.ps1           # Compare binary sizes  
.\measure-memory.ps1         # Measure memory usage
.\test-pricing.ps1           # Test the API endpoints
```

**Key Findings:**
- .NET 10 AOT starts 20% faster than .NET 8 AOT
- .NET 10 binaries are 5-10% smaller
- .NET 10 uses 10-15% less memory

---

### Module 2: ASP.NET Core Performance (25 min)
📁 `modules/module2-aspnetcore/`

**Scenario:** Load test PromotionsAPI with caching and rate limiting

**What You'll Measure:**

| Metric | .NET 8 | .NET 10 | Improvement |
|--------|--------|---------|-------------|
| Throughput (RPS) | ~500 | ~575 | +15% |
| p50 Latency | 20ms | 18ms | -10% |
| p95 Latency | 50ms | 42ms | -16% |
| Cache Hit Rate | 0% | ~60% | Built-in caching |

**Scripts:**
```powershell
cd modules\module2-aspnetcore

.\build-all.ps1                  # Build both versions
.\load-test.ps1 -Variant NET8    # Test .NET 8
.\load-test.ps1 -Variant NET10   # Test .NET 10
.\compare-results.ps1            # View comparison
```

**Key Features:**
- Output caching (improves cache hit rate to ~60%)
- Rate limiting for API protection
- Built-in OpenAPI support in .NET 10

---

### Module 3: C# 14 Features (30 min)
📁 `modules/module3-csharp14/`

**Goal:** Learn modern C# features that reduce boilerplate

**Topics Covered:**
1. **Extension Members** - Add methods to existing types without inheritance
2. **Field-Backed Properties** - Automatic validation and logging
3. **Partial Constructors** - Better code organization with source generators
4. **Compound Operators** - Custom operators for value objects
5. **Span Conversions** - Reduce allocations in hot paths
6. **nameof with Generics** - Safer refactoring

**How to Explore:**
```powershell
cd modules\module3-csharp14

# Each subfolder has examples and explanations
cd 01-extension-members
notepad README.md          # Read the explanation
notepad Example.cs         # See the code

# Repeat for other features
cd ..\02-field-backed-props
# etc.
```

**Business Value:**
- Leaner domain models (SKU, Money, Cart)
- Fewer runtime allocations
- Safer refactoring

---

### Module 4: EF Core Performance (15 min)
📁 `modules/module4-efcore/`

**Scenario:** Compare JSON column updates and query performance

**What You'll Compare:**
- Traditional `SaveChanges()` approach (EF Core 8)
- `ExecuteUpdate()` with JSON paths (EF Core 10)
- Query performance improvements

**Scripts:**
```powershell
cd modules\module4-efcore

.\measure-queries.ps1        # Compare query performance
```

**Key Findings:**
- JSON column updates are ~30% faster in EF Core 10
- Fewer database round trips
- Simplified code patterns

---

### Module 5: Container Optimization (15 min)
📁 `modules/module5-containers/`

**Scenario:** Build and compare Docker images for PromotionsAPI

**What You'll Build:**
- Docker images for .NET 8 and .NET 10
- Compare image sizes, pull times, and startup performance

**Scripts:**
```powershell
cd modules\module5-containers

.\build-images.ps1           # Build Docker images (requires Docker Desktop)
.\compare-images.ps1         # Compare sizes and metrics
.\test-containers.ps1        # Test startup times
```

**Expected Results:**
- .NET 10 images are ~10% smaller
- Faster container startup
- Lower bandwidth costs at scale

**Note:** Requires Docker Desktop to be running

---

### Module 6: Server-Sent Events (15 min)
📁 `modules/module6-serversentevents/`

**Scenario:** Explore real-time data streaming with SSE

**What You'll Learn:**
- .NET 10's built-in Server-Sent Events (SSE) API
- Real-time data streaming without WebSockets
- Use cases for live updates

**How to Run:**
```powershell
cd modules\module6-serversentevents

dotnet run                   # Start the server
# Open ServerSentEvents.http in VS Code to test endpoints
```

**Use Cases:**
- Live inventory updates
- Real-time order status
- Price change notifications

---

## 🧰 Full Workshop Setup

If you want to run the entire workshop start-to-finish:

```powershell
# From repository root

# Module 0: Read the context (5 min)
cd modules\module0-warmup
notepad README.md

# Module 1: Runtime Performance (20 min)
cd ..\module1-runtime
.\build-all.ps1
.\measure-coldstart.ps1
.\measure-size.ps1
.\measure-memory.ps1

# Module 2: ASP.NET Core (25 min)
cd ..\module2-aspnetcore
.\build-all.ps1
.\load-test.ps1 -Variant NET8
.\load-test.ps1 -Variant NET10
.\compare-results.ps1

# Module 3: C# 14 (30 min)
cd ..\module3-csharp14
# Explore each subfolder's README and examples

# Module 4: EF Core (15 min)
cd ..\module4-efcore
.\measure-queries.ps1

# Module 5: Containers (15 min)
cd ..\module5-containers
.\build-images.ps1
.\compare-images.ps1
.\test-containers.ps1

# Module 6: Server-Sent Events (15 min)
cd ..\module6-serversentevents
dotnet run
# Test with ServerSentEvents.http
```

---

## 🧪 What You'll Take Away

After completing this workshop, you'll have:

- **Benchmark Results**: Actual performance comparisons from your machine
- **Working Code Samples**: Microservices targeting both .NET 8 and .NET 10
- **C# 14 Knowledge**: Modern language features ready for production
- **Migration Insights**: Data to prioritize which services to upgrade first
- **Decision Framework**: Know when .NET 10 provides meaningful benefits

---

## 📎 Resources

### Official Documentation
- [.NET 10 Release Notes](https://learn.microsoft.com/dotnet/core/whats-new/dotnet-10)
- [C# 14 Language Features](https://learn.microsoft.com/dotnet/csharp/whats-new/csharp-14)
- [EF Core 10 What's New](https://learn.microsoft.com/ef/core/what-is-new/efcore-10)
- [ASP.NET Core 10 Overview](https://learn.microsoft.com/aspnet/core/release-notes/aspnetcore-10)

### Native AOT
- [Native AOT Prerequisites](https://aka.ms/nativeaot-prerequisites)
- [Publishing trimmed/AOT apps](https://learn.microsoft.com/dotnet/core/deploying/native-aot/)

### Performance
- [.NET Performance Improvements](https://devblogs.microsoft.com/dotnet/)
- [Kestrel Performance Tips](https://learn.microsoft.com/aspnet/core/fundamentals/servers/kestrel/performance)

---

## 💡 Tips for Success

### Before the Workshop
1. ✅ Install all prerequisites (especially .NET 10 SDK)
2. ✅ Clone the repository
3. ✅ Run `.\shared\Scripts\check-prerequisites.ps1`
4. ✅ Read Module 0 to understand the context

### During the Workshop
1. ⏱️ Don't rush - each module builds on the previous
2. 📊 Save your benchmark results for comparison
3. 🤔 Think about which services in your org would benefit most
4. ❓ Ask questions if something doesn't match expected results

### After the Workshop
1. 📋 Prioritize services for migration (high-traffic APIs first)
2. 🧪 Test in pre-production before migrating
3. 📈 Monitor metrics after migration
4. 🔄 Share learnings with your team

---

## 🆘 Troubleshooting

### Build Errors

**Problem:** `.NET 10 SDK not found`
```powershell
# Solution: Install .NET 10 SDK
# Download from: https://dotnet.microsoft.com/download/dotnet/10.0
```

**Problem:** `Native AOT build fails`
```powershell
# Solution: Install Visual Studio Build Tools with C++ workload
# Or run from Developer PowerShell for VS 2022/2026
```

### Docker Issues

**Problem:** `Docker daemon not running`
```powershell
# Solution: Start Docker Desktop
```

**Problem:** `Cannot find PromotionsAPI executable`
```powershell
# Solution: Build the PromotionsAPI artifacts first
cd modules\module2-aspnetcore
.\build-all.ps1
```

### Performance Variations

**Note:** Performance results vary by machine. Your numbers may differ from the targets shown. Focus on the **relative improvement** between .NET 8 and .NET 10 rather than absolute numbers.

---

## 📧 Questions or Feedback?

- **Issues**: Open an issue on GitHub
- **Discussions**: Use GitHub Discussions
- **Contributions**: Pull requests welcome!

---

**Ready to begin?** Start with Module 0 to understand the business context, then work through each module in order.

```powershell
cd modules\module0-warmup
notepad README.md
```

Good luck! 🚀
