# Implementation Plan: LTS to LTS Performance Lab Workshop

**Branch**: `001-lts-performance-lab` | **Date**: 2025-11-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-lts-performance-lab/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

This is a comprehensive 2-hour hands-on workshop comparing .NET 8 and .NET 10 LTS releases for Meijer-scale retail systems. The workshop includes seven modules demonstrating measurable performance, reliability, and maintainability improvements through runtime benchmarks, ASP.NET Core enhancements, C# 14 language features, EF Core 10 optimizations, container deployment, and migration planning. Each module is independently runnable within 5 minutes with scripted measurements comparing both .NET versions under identical conditions using realistic retail domain scenarios (pricing, promotions, inventory, catalog).

## Technical Context

**Language/Version**: C# 13 (.NET 8) and C# 14 (.NET 10), dual SDK environment required  
**Primary Dependencies**: ASP.NET Core 8.0/10.0 (Minimal APIs), Entity Framework Core 8/10, System.Text.Json  
**Storage**: SQL Server or PostgreSQL with JSONB support (for Module 4 data layer demonstrations)  
**Testing**: Load testing via wrk or bombardier, performance measurement scripts using dotnet-counters  
**Target Platform**: Windows with PowerShell (primary), cross-platform scripts for WSL2/macOS/Linux (secondary)  
**Project Type**: Educational workshop with multiple independent module folders, each containing dual-version implementations  
**Performance Goals**: 
- Module 1: Demonstrate 20%+ cold-start improvement (.NET 10 AOT vs .NET 8 AOT)
- Module 2: Demonstrate 15%+ RPS improvement and p95 latency reduction (.NET 10 vs .NET 8)
- Module 4: Demonstrate 30%+ query time reduction (ExecuteUpdate vs full-entity load)
- Module 5: Demonstrate 10%+ container image size reduction and 15%+ startup improvement

**Constraints**: 
- Each module runnable within 5 minutes of checkout
- All performance measurements reproducible on standard hardware (4-core, 8GB RAM)
- Total workshop completion within 120 minutes (110 min allocated + 10 min buffer)
- Scripts must work on Windows PowerShell without external tool dependencies (except optional Docker for Module 5)
- Identical workloads across .NET versions (no confounding variables)

**Scale/Scope**: 
- Educational content for 7 modules (0-6)
- 2 minimal APIs (pricing service, promotions API)
- 11 domain entities (Product, SKU, Price, Discount, Cart, Order, InventoryItem, Promotion, Money, Quantity, PricingService/PromotionsAPI)
- 6 C# 14 feature demonstrations (before/after code examples)
- Pre-built artifacts for 4 variants (8-FX, 8-AOT, 10-FX, 10-AOT)
- Measurement/benchmark scripts for startup time, latency, memory, container size, RPS

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Educational Clarity Compliance:**
- [x] Module runnable within 5 minutes of checkout ✓ (quickstart.md documents pre-built artifacts in artifacts/ folder)
- [x] Performance measurements scripted and reproducible ✓ (research.md specifies scripted measurements with standard tools)
- [x] Retail scenarios relatable to enterprise operations ✓ (data-model.md uses Product, Promotion, Cart, Order, InventoryItem from retail domain)
- [x] Prerequisites documented ✓ (quickstart.md lists .NET 8 SDK, .NET 10 SDK, PowerShell, optional Docker, optional load testing tools)

**Fair Comparison Compliance:**
- [x] Identical scenarios for .NET 8 and .NET 10 ✓ (contracts/pricing-service-api.yaml and contracts/promotions-api.yaml define same endpoints for both versions)
- [x] Measurement scripts run both versions under identical conditions ✓ (research.md specifies cross-platform scripts run same workloads)
- [x] Trade-offs explicitly documented ✓ (research.md Native AOT patterns section documents reflection limitations and compatibility)
- [x] Results reproducible on standard hardware (4-core, 8GB RAM) ✓ (quickstart.md hardware recommendations section)

**Production Patterns Compliance:**
- [x] Code follows enterprise standards (logging, error handling, health checks) ✓ (contracts/pricing-service-api.yaml and promotions-api.yaml include /health endpoints, 400/422/429/500 error responses)
- [x] Security practices implemented (no hardcoded secrets, input validation) ✓ (contracts define validation rules: promoCode required, discountPercentage 0-100, rate limiting 100 req/10sec)
- [x] Performance thresholds met (<100ms p95 latency, cold-start optimized) ✓ (performance goals documented: 20%+ cold-start, 15%+ RPS, <100ms target)
- [x] Realistic data volumes and concurrency ✓ (quickstart.md documents Meijer scale: 240 stores, 2M+ daily transactions, 25K+ concurrent peak)

**Incremental Complexity Compliance:**
- [x] Time allocation documented and realistic ✓ (quickstart.md time allocation table: 110 min allocated + 10 min buffer)
- [x] Module works independently with isolated setup ✓ (research.md workshop structure decision: multi-module independent approach)
- [x] Complexity progression clear (entry/exit criteria) ✓ (quickstart.md module sequence: 0 Warm-up → 1 Runtime → 2 ASP.NET → 3 C# 14 → 4 EF Core → 5 Containers → 6 Migration)

**Enterprise Context Compliance:**
- [x] Business value explicitly stated ✓ (quickstart.md completion checklist includes "document expected ROI: cloud cost, deployment velocity, TCO")
- [x] Large-scale impact documented ✓ (quickstart.md Meijer scale: 240 stores, 2M+ daily transactions, zero-downtime requirement)
- [x] Cloud cost implications calculated ✓ (research.md decision 6 specifies performance measurement standards including cost context)
- [x] Observability demonstrated ✓ (contracts include /health endpoints, research.md specifies dotnet-counters for memory monitoring)
- [x] Migration guidance provided ✓ (data-model.md includes migration planning entities, quickstart.md Module 6 decision matrix)

**Technical Standards Compliance:**
- [x] Framework-Dependent (FX) and Native AOT builds where applicable ✓ (research.md Native AOT patterns: Modules 1 & 5 include 4 variants: 8-FX, 8-AOT, 10-FX, 10-AOT)
- [x] Cross-platform scripts (PowerShell + bash) ✓ (research.md decision 7: PowerShell primary for Windows, bash secondary for WSL2/macOS/Linux)
- [x] Performance measurements capture: startup, latency (p50/p95/p99), memory, container size, RPS ✓ (research.md decision 6: Measure-Command for startup, dotnet-counters for memory, docker stats for containers, bombardier for RPS/latency)

**✅ CONSTITUTION CHECK: ALL REQUIREMENTS PASSED** (Post-Design Phase 1 Re-Evaluation)

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
modules/
├── module0-warmup/
│   └── README.md                    # Context setting, performance bar explanation
├── module1-runtime/
│   ├── README.md                    # Learning objectives, prerequisites, instructions
│   ├── PricingService.NET8/         # .NET 8 pricing API source
│   ├── PricingService.NET10/        # .NET 10 pricing API source
│   ├── build-all.ps1                # Build all 4 variants
│   ├── build-all.sh                 # Bash equivalent
│   ├── measure-startup.ps1          # Measure binary size, startup time, memory
│   └── measure-startup.sh           # Bash equivalent
├── module2-aspnetcore/
│   ├── README.md
│   ├── PromotionsAPI.NET8/          # .NET 8 baseline with 3 endpoints
│   ├── PromotionsAPI.NET10/         # .NET 10 with caching, rate limiting, OpenAPI
│   ├── load-test.ps1                # Load testing script (wrk/bombardier)
│   ├── load-test.sh
│   └── compare-results.ps1          # RPS and p95 latency comparison
├── module3-csharp14/
│   ├── README.md
│   ├── 01-extension-members/        # Tax calculation example (before/after)
│   ├── 02-field-backed-props/       # Money validation example
│   ├── 03-partial-constructors/     # InventoryItem layering example
│   ├── 04-compound-operators/       # Money += Discount example
│   ├── 05-span-conversions/         # SKU parsing hot-path example
│   └── 06-nameof-generics/          # Generic repository safety example
├── module4-efcore/
│   ├── README.md
│   ├── ProductCatalog.NET8/         # .NET 8 full-entity load approach
│   ├── ProductCatalog.NET10/        # .NET 10 ExecuteUpdate with JSON path
│   ├── setup-database.ps1           # Create Products table with JSONB column
│   ├── measure-queries.ps1          # Compare query execution times
│   └── sample-data.sql              # Product metadata: colors, sizes, flags
├── module5-containers/
│   ├── README.md
│   ├── Dockerfile.net8              # aspnet:8.0 base image
│   ├── Dockerfile.net10             # aspnet:10.0 base image
│   ├── build-images.ps1             # Build both images
│   ├── compare-images.ps1           # Image size, startup time, memory usage
│   └── compare-images.sh
├── module6-migration/
│   ├── README.md
│   ├── decision-matrix.md           # Service prioritization table
│   └── pre-migration-checklist.md  # Benchmark, AOT compat, dependencies, rollback
└── shared/
    ├── DomainModels/                # Shared retail domain objects
    │   ├── Product.cs
    │   ├── SKU.cs
    │   ├── Price.cs (Money value object)
    │   ├── Discount.cs
    │   ├── Cart.cs
    │   ├── Order.cs
    │   ├── InventoryItem.cs
    │   ├── Promotion.cs
    │   └── Quantity.cs
    └── Scripts/                     # Shared utility scripts
        ├── check-prerequisites.ps1   # Verify SDKs, Docker, load test tools
        └── setup-environment.ps1     # One-time workshop environment setup

artifacts/                           # Pre-built binaries (checked into repo)
├── pub8-fx/                         # .NET 8 framework-dependent build
├── pub8-aot/                        # .NET 8 Native AOT build
├── pub10-fx/                        # .NET 10 framework-dependent build
└── pub10-aot/                       # .NET 10 Native AOT build

docs/
├── workshop-guide.md                # Facilitator guide with timing, troubleshooting
└── participant-guide.md             # Participant handout with learning objectives
```

**Structure Decision**: Multi-module educational structure where each module is independently runnable. The `modules/` folder contains 7 workshop modules (0-6), each with dual-version implementations (.NET 8 vs .NET 10), measurement scripts, and comprehensive READMEs. Shared domain models are in `shared/DomainModels/` to demonstrate realistic retail entities. Pre-built artifacts reduce Module 1 setup time. This structure supports the Incremental Complexity principle (independent modules) and Educational Clarity principle (5-minute runability).

## Complexity Tracking

No constitution violations requiring justification. The multi-module structure is necessary for educational scaffolding and aligns with Incremental Complexity principle. Dual-version implementations (NET8/NET10) are mandated by Fair Comparison principle. Pre-built artifacts optimize for Educational Clarity (5-minute runability).
