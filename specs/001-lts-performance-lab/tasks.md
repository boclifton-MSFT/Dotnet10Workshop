# Implementation Tasks: LTS to LTS Performance Lab Workshop

**Feature**: 001-lts-performance-lab  
**Branch**: `001-lts-performance-lab`  
**Generated**: 2025-11-03  
**Source**: [spec.md](./spec.md) | [plan.md](./plan.md)

## Overview

This task list implements a comprehensive 2-hour workshop comparing .NET 8 and .NET 10 LTS releases for Meijer-scale retail systems. Tasks are organized by user story to enable independent implementation and testing. Each module is independently runnable within 5 minutes with scripted measurements.

**Total Tasks**: 89  
**Parallelizable Tasks**: 47  
**User Stories**: 7 (organized by priority)

## Implementation Strategy

**MVP Scope**: User Story 7 + User Story 1 (Module 0 + Module 1) - establishes workshop context and demonstrates runtime improvements in ~30 minutes of participant time.

**Incremental Delivery**:
1. **Phase 1-2**: Setup infrastructure and shared domain models (Tasks T001-T020)
2. **Phase 3**: Deliver MVP (Module 0 + Module 1) for immediate value (Tasks T021-T035)
3. **Phase 4-5**: Add high-priority modules (Module 2 promotions API, Module 1 runtime benchmarks) (Tasks T036-T053)
4. **Phase 6-8**: Add maintainability and data layer modules (C# 14, EF Core, Containers) (Tasks T054-T082)
5. **Phase 9-10**: Add migration planning and polish (Tasks T083-T089)

**Parallel Execution Opportunities**: Identified with [P] marker. See "Parallel Execution Examples" section below.

---

## Phase 1: Setup & Infrastructure

**Goal**: Initialize project structure, shared utilities, and pre-built artifacts

### Setup Tasks

- [x] T001 Create repository root folder structure per plan.md: modules/, shared/, artifacts/, docs/
- [x] T002 [P] Create .gitignore for .NET projects (bin/, obj/, *.user, .vs/, artifacts/*.dll)
- [x] T003 [P] Create README.md at repository root with workshop overview and module index
- [x] T004 [P] Create global.json in repository root to document SDK requirements (8.0.x and 10.0.x)
- [x] T005 [P] Create shared/Scripts/check-prerequisites.ps1 to verify .NET 8 SDK, .NET 10 SDK, PowerShell, optional Docker, optional bombardier/wrk
- [x] T006 [P] Create shared/Scripts/check-prerequisites.sh (bash equivalent for cross-platform)
- [x] T007 [P] Create shared/Scripts/setup-environment.ps1 for one-time workshop environment setup
- [x] T008 [P] Create docs/workshop-guide.md facilitator guide with timing, troubleshooting tips, common issues
- [x] T009 [P] Create docs/participant-guide.md with learning objectives, note-taking template, completion checklist

### Artifact Preparation

- [x] T010 Create artifacts/ folder structure: pub8-fx/, pub8-aot/, pub10-fx/, pub10-aot/
- [x] T011 Add placeholder README.md in artifacts/ explaining pre-built binaries strategy and rebuild instructions

---

## Phase 2: Foundational - Shared Domain Models

**Goal**: Implement shared retail domain entities used across all modules

**Why Foundational**: All user story modules (1-6) reference these domain models. Must complete before any module implementation.

### Domain Model Implementation

- [x] T012 [P] Create shared/DomainModels/ folder and DomainModels.csproj targeting net8.0 and net10.0
- [x] T013 [P] Implement Money value object in shared/DomainModels/Money.cs with Amount, Currency, validation, arithmetic operations
- [x] T014 [P] Implement SKU value object in shared/DomainModels/SKU.cs with Value, Department, Category, ItemNumber, parsing logic
- [x] T015 [P] Implement Quantity value object in shared/DomainModels/Quantity.cs with Count, Unit, validation
- [x] T016 [P] Implement Product entity in shared/DomainModels/Product.cs with SKU, Name, BasePrice, Category, Attributes (JSON), InventoryQuantity
- [x] T017 [P] Implement Discount entity in shared/DomainModels/Discount.cs with Type, Value, AppliesTo, MaxDiscount
- [x] T018 [P] Implement Promotion entity in shared/DomainModels/Promotion.cs with Id, Code, Name, Discount, ValidFrom, ValidTo, ApplicableCategories, ExcludedSKUs
- [x] T019 [P] Implement Cart entity in shared/DomainModels/Cart.cs with Id, LineItems, Subtotal, AppliedPromotions, DiscountTotal, Tax, Total
- [x] T020 [P] Implement Order entity in shared/DomainModels/Order.cs with Id, OrderNumber, CustomerId, LineItems, Subtotal, Tax, Total, Status

---

## Phase 3: User Story 7 - Workshop Context Setting (P1)

**User Story**: Workshop participant needs to understand the retail performance bar and measurement approach in the first 5 minutes.

**Independent Test**: Participant reads Module 0 content, understands <100ms API requirement, zero-downtime expectations, and five metrics (startup, latency, memory, container size, RPS) within 5 minutes.

**Time Allocation**: 5 minutes

### Module 0 Implementation

- [x] T021 [US7] Create modules/module0-warmup/ folder
- [x] T022 [US7] Create modules/module0-warmup/README.md with retail performance bar explanation (<100ms API, zero-downtime during promos)
- [x] T023 [US7] Document five metrics in README: startup time, p50/p95 latency, memory footprint, container size, RPS
- [x] T024 [US7] Add "Why This Matters for Meijer" section explaining LTS-to-LTS modernization timing and business case
- [x] T025 [US7] Add "Workshop Structure" section with module index and time allocations
- [x] T026 [US7] Add "Expected Outcomes" section with quantified improvements (20%+ cold-start, 15%+ RPS, 30%+ query time, 10%+ container size)

---

## Phase 4: User Story 1 - Runtime Performance Comparison (P1)

**User Story**: Workshop participant needs to understand cold-start performance differences between .NET 8 and .NET 10 to make informed migration decisions for pricing microservices.

**Independent Test**: Participant runs provided scripts, obtains comparison table showing four variants (8-FX, 8-AOT, 10-FX, 10-AOT) with binary size, startup time, and memory metrics within 5 minutes.

**Time Allocation**: 20 minutes

### Module 1 Implementation

- [x] T027 [US1] Create modules/module1-runtime/ folder
- [x] T028 [US1] Create modules/module1-runtime/README.md with learning objectives, prerequisites (.NET 8/10 SDKs), instructions, expected output, business value
- [x] T029 [US1] Implement pricing API with PricingService.csproj targeting net8.0 (simplified single csproj per Educational Clarity principle)
- [x] T030 [US1] Implement pricing API in Program.cs with /health endpoint and /api/pricing/calculate endpoint (POST with quantity, customerId, SKU) per contracts/pricing-service-api.yaml
- [x] T031 [US1] Create PricingCalculator.cs with pricing logic and mock product/promotion data (no database required)
- [x] T032 [US1] Add value type usage (Money, SKU, Quantity) to reduce allocations and GC pressure
- [x] T033 [US1] Use Minimal APIs for fast startup (no controllers)
- [x] T034 [US1] Implement mock data with Products and Promotions for deterministic testing

### Build Scripts

- [x] T035 [P] [US1] Create modules/module1-runtime/build-all.ps1 to compile 4 variants: net8-fx, net8-aot, net9-fx (placeholder for 10), net9-aot
- [x] T036 [P] [US1] Configure build-all.ps1 to copy outputs to artifacts/ folders (pub8-fx/, pub8-aot/, pub10-fx/, pub10-aot/)

### Measurement Scripts

- [x] T037 [US1] Create modules/module1-runtime/measure-coldstart.ps1 to measure startup time with 5 iterations, averaging results
- [x] T038 [US1] Create modules/module1-runtime/measure-size.ps1 to measure binary size and calculate AOT overhead
- [x] T039 [US1] Create modules/module1-runtime/measure-memory.ps1 to measure memory usage under HTTP load
- [x] T040 [US1] Add error handling to all measurement scripts with helpful guidance

### Pre-Built Artifacts

- [x] T041 [US1] All measurement scripts reference pre-built artifacts in artifacts/ folders
- [x] T042 [US1] Provide fallback to user's own builds if pre-built artifacts missing
- [x] T043 [US1] PricingService verified to compile and run successfully on .NET 8
- [x] T044 [US1] Documented measurement script usage and expected outputs

---

## Phase 5: User Story 2 - ASP.NET Core Throughput Analysis (P1)

**User Story**: Workshop participant needs to measure request throughput and latency improvements in .NET 10 to justify upgrading their promotions API.

**Independent Test**: Participant runs load tests against identical .NET 8 and .NET 10 versions of promotions API, obtains RPS and p95 latency metrics showing .NET 10 improvements within 5 minutes.

**Time Allocation**: 25 minutes

### Module 2 Implementation

- [x] T045 [US2] Create modules/module2-aspnetcore/ folder
- [x] T046 [US2] Create modules/module2-aspnetcore/README.md with learning objectives, prerequisites, instructions, expected improvements (15%+ RPS), business value
- [x] T047 [US2] Implement PromotionsAPI using conditional compilation (#if NET10_0_OR_GREATER) for caching and rate limiting
- [x] T048 [US2] Implement GET /promotions, GET /promotions/{id}, POST /promotions/validate endpoints
- [x] T049 [US2] Create PromotionsAPI.csproj targeting net8.0 with ASP.NET Core 8.0 Minimal APIs
- [x] T050 [US2] Implement in-memory promotion data store with sample promotions (SAVE20, FREESHIP, BOGO50)
- [x] T051 [US2] Add GET /health endpoint for health checks
- [x] T052 [US2] Conditional output caching in .NET 10: CacheOutput() on GET /promotions
- [x] T053 [US2] Conditional rate limiting in .NET 10: FixedWindowRateLimiter (100 req/10 sec)
- [x] T054 [US2] Verify identical in-memory promotion data across variants
- [x] T055 [US2] Use Minimal APIs for both versions with conditional feature compilation

### Load Testing Scripts

- [x] T056 [US2] Create modules/module2-aspnetcore/build-all.ps1 to compile both variants
- [x] T057 [US2] Create modules/module2-aspnetcore/load-test.ps1 for bombardier/wrk load testing
- [x] T058 [US2] Configure load-test.ps1 to capture RPS and latency percentiles
- [x] T059 [US2] Create modules/module2-aspnetcore/compare-results.ps1 for side-by-side comparison
- [x] T060 [US2] Add error handling and installation guidance for load testing tools
- [x] T061 [US2] PromotionsAPI verified to compile and run successfully on .NET 8

---

## Phase 6: User Story 3 - Language Features for Maintainability (P2)

**User Story**: Workshop participant needs to see how C# 14 features reduce boilerplate and improve code safety in large retail codebases.

**Independent Test**: Participant reviews six side-by-side code examples (before/after), understands maintainability benefits, and can identify which feature solves which enterprise problem within 5 minutes per example.

**Time Allocation**: 30 minutes

### Module 3 Implementation

- [ ] T065 [US3] Create modules/module3-csharp14/ folder
- [ ] T066 [US3] Create modules/module3-csharp14/README.md with learning objectives, prerequisites, instructions, business value for large codebases
- [ ] T067 [US3] Add module overview explaining six features with maintainability focus (reduce boilerplate, improve type safety, optimize performance)

### Example 1: Extension Members

- [ ] T068 [P] [US3] Create modules/module3-csharp14/01-extension-members/ folder
- [ ] T069 [US3] Create Before.cs showing tax calculation duplicated in Product.CalculateTax() and Order.CalculateTax() methods
- [ ] T070 [US3] Create After.cs showing Extension Members consolidating tax logic in TaxExtensions without modifying Product/Order types
- [ ] T071 [US3] Create Program.cs demonstrating both approaches with console output showing identical results
- [ ] T072 [US3] Create README.md explaining maintainability benefit: consolidate cross-cutting concerns without modifying core types

### Example 2: Field-Backed Properties

- [ ] T073 [P] [US3] Create modules/module3-csharp14/02-field-backed-props/ folder
- [ ] T074 [US3] Create Before.cs showing Money value object with basic Amount/Currency properties
- [ ] T075 [US3] Create After.cs showing Field-Backed Properties adding validation with logging hooks using field keyword
- [ ] T076 [US3] Create Program.cs demonstrating validation catching negative amounts with logged warnings
- [ ] T077 [US3] Create README.md explaining observability benefit: add validation and logging without changing public API

### Example 3: Partial Constructors

- [ ] T078 [P] [US3] Create modules/module3-csharp14/03-partial-constructors/ folder
- [ ] T079 [US3] Create Before.cs showing InventoryItem with all constructor logic in one place
- [ ] T080 [US3] Create After.cs showing Partial Constructors for clean layering with source generator integration
- [ ] T081 [US3] Create Program.cs demonstrating layered construction with validation and computed fields
- [ ] T082 [US3] Create README.md explaining enterprise pattern benefit: supports source generators and layered initialization

### Example 4: User-Defined Compound Operators

- [ ] T083 [P] [US3] Create modules/module3-csharp14/04-compound-operators/ folder
- [ ] T084 [US3] Create Before.cs showing manual Money discount calculation: price = price - (price * discount.Percentage)
- [ ] T085 [US3] Create After.cs showing User-Defined Compound Operators enabling Money += Discount and Quantity *= Multiplier
- [ ] T086 [US3] Create Program.cs demonstrating both approaches with shopping cart scenarios
- [ ] T087 [US3] Create README.md explaining safety benefit: reduce error-prone manual calculations with domain-specific operators

### Example 5: Expanded Span<T> Conversions

- [ ] T088 [P] [US3] Create modules/module3-csharp14/05-span-conversions/ folder
- [ ] T089 [US3] Create Before.cs showing SKU parsing with string allocations in hot-path
- [ ] T090 [US3] Create After.cs showing Expanded Span<T> conversions reducing allocations in parsing logic
- [ ] T091 [US3] Create Program.cs with benchmark showing allocation reduction (memory profiling output)
- [ ] T092 [US3] Create README.md explaining performance benefit: hot-path optimization for high-throughput scenarios

### Example 6: nameof on Unbound Generics + Null-Conditional Assignment

- [ ] T093 [P] [US3] Create modules/module3-csharp14/06-nameof-generics/ folder
- [ ] T094 [US3] Create Before.cs showing generic repository with magic strings for type names (runtime errors on refactoring)
- [ ] T095 [US3] Create After.cs showing nameof on unbound generics for safer refactoring with compile-time checks
- [ ] T096 [US3] Create Program.cs demonstrating how renaming types breaks Before but not After
- [ ] T097 [US3] Create README.md explaining safety benefit: compile-time safety for generic repositories and reflection code

### Module 3 Integration

- [ ] T098 [US3] Create project files for all six examples targeting both net8.0 (without features) and net10.0 (with features)
- [ ] T099 [US3] Add inline comments to all After.cs files explaining "why" not just "what" per research.md decision 5

---

## Phase 7: User Story 4 - Data Layer Performance (P2)

**User Story**: Workshop participant needs to understand EF Core 10 query optimization for JSON column updates in product catalog scenarios.

**Independent Test**: Participant runs measurement script comparing .NET 8 full-entity load vs .NET 10 ExecuteUpdate with JSON path, obtains query time comparison within 5 minutes.

**Time Allocation**: 15 minutes

### Module 4 Implementation

- [ ] T100 [US4] Create modules/module4-efcore/ folder
- [ ] T101 [US4] Create modules/module4-efcore/README.md with learning objectives, prerequisites (SQL Server LocalDB or PostgreSQL), instructions, expected improvements (30%+ faster), business value
- [ ] T102 [US4] Create modules/module4-efcore/ProductCatalog.NET8/ folder with global.json pinning SDK 8.0.x
- [ ] T103 [US4] Create ProductCatalog.NET8/ProductCatalog.csproj targeting net8.0 with Microsoft.EntityFrameworkCore 8.x, provider packages
- [ ] T104 [US4] Implement ProductDbContext in ProductCatalog.NET8 with Products DbSet and JSON column mapping for Attributes
- [ ] T105 [US4] Implement .NET 8 update approach in ProductCatalog.NET8/Program.cs: load entity, deserialize JSON, modify property, serialize, SaveChangesAsync
- [ ] T106 [US4] Create modules/module4-efcore/ProductCatalog.NET10/ folder with global.json pinning SDK 10.0.x
- [ ] T107 [US4] Create ProductCatalog.NET10/ProductCatalog.csproj targeting net10.0 with Microsoft.EntityFrameworkCore 10.x
- [ ] T108 [US4] Implement ProductDbContext in ProductCatalog.NET10 (identical schema)
- [ ] T109 [US4] Implement .NET 10 update approach in ProductCatalog.NET10/Program.cs: ExecuteUpdateAsync with JSON path syntax for single property update
- [ ] T110 [US4] Add timing measurement to both Program.cs files using Stopwatch for query execution time

### Database Setup Scripts

- [ ] T111 [P] [US4] Create modules/module4-efcore/setup-database.ps1 to detect SQL Server LocalDB or PostgreSQL or fallback to SQLite, create Products table with JSONB/JSON column
- [ ] T112 [P] [US4] Create modules/module4-efcore/sample-data.sql with 100 product records including dynamic attributes: colorOptions, sizeChart, seasonal flags, tags
- [ ] T113 [US4] Configure setup-database.ps1 to run sample-data.sql after table creation

### Measurement Scripts

- [ ] T114 [US4] Create modules/module4-efcore/measure-queries.ps1 to run both ProductCatalog.NET8 and ProductCatalog.NET10, capture query times, output comparison table
- [ ] T115 [US4] Add error handling to measure-queries.ps1 for database connection failures with setup instructions

---

## Phase 8: User Story 5 - Container Size Optimization (P2)

**User Story**: Workshop participant needs to measure container image size and startup improvements in .NET 10 for deployment optimization.

**Independent Test**: Participant runs Docker build scripts, compares image sizes and startup times between .NET 8 and .NET 10 containers within 5 minutes.

**Time Allocation**: 10 minutes

### Module 5 Implementation

- [ ] T116 [US5] Create modules/module5-containers/ folder
- [ ] T117 [US5] Create modules/module5-containers/README.md with learning objectives, prerequisites (Docker Desktop), instructions, expected improvements (10%+ size, 15%+ startup), business value
- [ ] T118 [US5] Create modules/module5-containers/Dockerfile.net8 using mcr.microsoft.com/dotnet/aspnet:8.0 base image, copy PricingService.NET8 from Module 1
- [ ] T119 [US5] Create modules/module5-containers/Dockerfile.net10 using mcr.microsoft.com/dotnet/aspnet:10.0 base image, copy PricingService.NET10 from Module 1
- [ ] T120 [US5] Configure both Dockerfiles to use framework-dependent builds from artifacts/pub8-fx and artifacts/pub10-fx

### Build Scripts

- [ ] T121 [P] [US5] Create modules/module5-containers/build-images.ps1 to build both images: docker build -t pricing-service:net8 -f Dockerfile.net8 and pricing-service:net10 -f Dockerfile.net10
- [ ] T122 [P] [US5] Create modules/module5-containers/build-images.sh (bash equivalent)

### Comparison Scripts

- [ ] T123 [US5] Create modules/module5-containers/compare-images.ps1 to measure image size (docker images --format "{{.Size}}"), startup time (docker logs with timestamp parsing), memory (docker stats)
- [ ] T124 [P] [US5] Create modules/module5-containers/compare-images.sh (bash equivalent)
- [ ] T125 [US5] Configure compare-images.ps1 to output comparison table with columns: Image, Size MB, Startup Time ms, Memory MB
- [ ] T126 [US5] Add error handling to build-images.ps1 for Docker not running with instructions to start Docker Desktop
- [ ] T127 [US5] Add note to README.md that Module 5 is optional if Docker unavailable, reference pre-provided measurements

---

## Phase 9: User Story 6 - Migration Planning (P3)

**User Story**: Workshop participant needs a practical decision framework for prioritizing which services to migrate from .NET 8 to .NET 10.

**Independent Test**: Participant reviews decision matrix and pre-migration checklist, can identify service priority order for their scenario within 5 minutes.

**Time Allocation**: 5 minutes

### Module 6 Implementation

- [ ] T128 [US6] Create modules/module6-migration/ folder
- [ ] T129 [US6] Create modules/module6-migration/README.md with learning objectives, instructions, how to use decision matrix
- [ ] T130 [US6] Create modules/module6-migration/decision-matrix.md with service prioritization table: high-traffic APIs (checkout, cart, pricing) first, then background workers, then internal tools
- [ ] T131 [US6] Add columns to decision-matrix.md: Service Type, Traffic Level, AOT Compatibility, Expected Gains (from Modules 1-5), Priority Order
- [ ] T132 [US6] Create modules/module6-migration/pre-migration-checklist.md with steps: benchmark current performance, identify AOT compatibility issues, review dependency versions, plan rollback strategy
- [ ] T133 [US6] Reference measured improvements from Modules 1-5 in both documents with quantified gains (20%+ cold-start, 15%+ RPS, 30%+ query time, 10%+ container size)
- [ ] T134 [US6] Add "Calculating ROI" section to README explaining cloud cost reduction, deployment velocity improvement, TCO analysis

---

## Phase 10: Polish & Cross-Cutting Concerns

**Goal**: Finalize documentation, ensure consistency, validate all scripts work end-to-end

### Documentation Polish

- [ ] T135 [P] Validate all module README.md files include: learning objectives, prerequisites, step-by-step instructions, expected output, "Why This Matters for Meijer" section
- [ ] T136 [P] Ensure all scripts include error handling for missing prerequisites with helpful messages pointing to installation instructions
- [ ] T137 [P] Verify all performance comparisons use identical workloads per Fair Comparison principle
- [ ] T138 [P] Add troubleshooting section to repository root README.md covering common issues: SDK version mismatch, PowerShell execution policy, port conflicts, Docker not running, load testing tool not found

### Script Validation

- [ ] T139 Run check-prerequisites.ps1 to verify all prerequisites documented correctly
- [ ] T140 Run Module 0 through Module 6 end-to-end to validate time allocations (110 min allocated + 10 min buffer)
- [ ] T141 Verify all PowerShell scripts run on Windows without external tool dependencies (except optional Docker/bombardier/wrk)
- [ ] T142 Test all bash scripts on WSL2 or Linux to ensure cross-platform compatibility

### Constitution Compliance Validation

- [ ] T143 Verify Educational Clarity: All modules runnable within 5 minutes using pre-built artifacts
- [ ] T144 Verify Fair Comparison: Identical workloads across .NET 8 and .NET 10 in all measurements
- [ ] T145 Verify Production Patterns: All code includes logging, error handling, health checks, validation per contracts
- [ ] T146 Verify Incremental Complexity: Module progression clear (Module 0 warmup → Module 1 runtime → ... → Module 6 migration)
- [ ] T147 Verify Enterprise Context: All modules include "Why This Matters for Meijer" section with business value

### Final Quality Checks

- [ ] T148 [P] Verify all code compiles in both .NET 8 and .NET 10 SDKs
- [ ] T149 [P] Ensure all measurement scripts output comparison tables in consistent format
- [ ] T150 [P] Validate all pre-built artifacts checked into artifacts/ folder are up-to-date
- [ ] T151 Test workshop end-to-end on fresh environment to validate participant experience
- [ ] T152 Create workshop completion certificate template in docs/ folder

---

## Dependencies & Execution Order

### User Story Completion Order

**Priority 1 (Must Have)**:
1. **US7** (Module 0 - Context Setting) - No dependencies, establishes workshop goals → Tasks T021-T026
2. **US1** (Module 1 - Runtime Performance) - Depends on Foundational (shared domain models), blocked by T012-T020 → Tasks T027-T044
3. **US2** (Module 2 - ASP.NET Core Throughput) - Depends on Foundational (Promotion entity), blocked by T012-T020 → Tasks T045-T064

**Priority 2 (Should Have)**:
4. **US3** (Module 3 - C# 14 Language Features) - Depends on Foundational (all domain entities), blocked by T012-T020 → Tasks T065-T099
5. **US4** (Module 4 - EF Core Data Layer) - Depends on Foundational (Product entity), blocked by T012-T020 → Tasks T100-T115
6. **US5** (Module 5 - Container Size) - Depends on US1 completion (reuses PricingService), blocked by T027-T044 → Tasks T116-T127

**Priority 3 (Nice to Have)**:
7. **US6** (Module 6 - Migration Planning) - Depends on US1-US5 completion for quantified gains → Tasks T128-T134

### Critical Path

**Blocking Tasks** (must complete sequentially):
1. Phase 1 Setup (T001-T011) → Phase 2 Foundational (T012-T020)
2. Phase 2 Foundational (T012-T020) → Phase 3-8 User Stories (T021-T127)
3. Phase 4 US1 (T027-T044) → Phase 8 US5 (T116-T127) - Module 5 reuses Module 1 artifacts
4. Phases 3-8 User Stories (T021-T127) → Phase 9 US6 (T128-T134) - Migration planning needs metrics from all modules

**Non-Blocking Tasks** (can parallelize):
- All script creation tasks (.ps1 + .sh equivalents) can run in parallel
- All README.md creation tasks can run in parallel within same phase
- All example implementations in Module 3 can run in parallel (Examples 1-6)
- Documentation polish tasks (T135-T138) can run in parallel

---

## Parallel Execution Examples

### Phase 1: Setup Scripts (5 tasks in parallel)

Can execute simultaneously (different files, no dependencies):
- T002 (.gitignore)
- T003 (root README.md)
- T004 (global.json)
- T008 (workshop-guide.md)
- T009 (participant-guide.md)

### Phase 2: Domain Models (9 tasks in parallel)

Can execute simultaneously (different entity files, no cross-references):
- T013 (Money.cs)
- T014 (SKU.cs)
- T015 (Quantity.cs)
- T016 (Product.cs)
- T017 (Discount.cs)
- T018 (Promotion.cs)
- T019 (Cart.cs)
- T020 (Order.cs)
- T012 (DomainModels.csproj)

### Phase 6: Module 3 Examples (6 groups in parallel)

Can execute simultaneously (independent examples):
- T068-T072 (Example 1 - Extension Members)
- T073-T077 (Example 2 - Field-Backed Properties)
- T078-T082 (Example 3 - Partial Constructors)
- T083-T087 (Example 4 - Compound Operators)
- T088-T092 (Example 5 - Span Conversions)
- T093-T097 (Example 6 - nameof Generics)

### Phase 10: Polish (4 tasks in parallel)

Can execute simultaneously (different documentation files):
- T135 (validate module READMEs)
- T136 (ensure script error handling)
- T137 (verify identical workloads)
- T138 (add troubleshooting section)

---

## Task Summary by User Story

| User Story | Priority | Tasks | Parallelizable | Time Allocation |
|------------|----------|-------|----------------|-----------------|
| Setup & Foundational | N/A | 20 (T001-T020) | 13 | N/A |
| US7 - Context Setting | P1 | 6 (T021-T026) | 0 | 5 min |
| US1 - Runtime Performance | P1 | 18 (T027-T044) | 4 | 20 min |
| US2 - ASP.NET Core | P1 | 20 (T045-T064) | 3 | 25 min |
| US3 - C# 14 Features | P2 | 35 (T065-T099) | 24 | 30 min |
| US4 - EF Core Data Layer | P2 | 16 (T100-T115) | 2 | 15 min |
| US5 - Container Size | P2 | 12 (T116-T127) | 4 | 10 min |
| US6 - Migration Planning | P3 | 7 (T128-T134) | 0 | 5 min |
| Polish & Validation | N/A | 18 (T135-T152) | 7 | N/A |
| **Total** | | **152** | **57** | **110 min** |

---

## Notes

- **Test Generation**: Tests NOT generated per specification (no test requirements in spec.md)
- **Parallelization**: 57 tasks marked with [P] can execute simultaneously when assigned to different developers or scheduled in CI/CD pipeline
- **MVP Definition**: US7 + US1 (Module 0 + Module 1) provides immediate value - establishes context and demonstrates runtime improvements
- **Independent Testing**: Each user story phase includes participant-facing test criteria in module README
- **Hardware Baseline**: All measurements documented with baseline hardware (4-core, 8GB RAM, SSD) for reproducibility
- **Cross-Platform**: PowerShell scripts primary for Windows, bash equivalents secondary for WSL2/macOS/Linux per research.md decision 7
- **Pre-Built Artifacts**: Module 1 artifacts pre-built and checked into repo to enable 5-minute setup per Educational Clarity principle
- **Constitution Compliance**: Tasks T143-T147 validate all 5 principles + technical standards before delivery
