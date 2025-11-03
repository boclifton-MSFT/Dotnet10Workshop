# Feature Specification: LTS to LTS Performance Lab Workshop

**Feature Branch**: `001-lts-performance-lab`  
**Created**: 2025-11-03  
**Status**: Draft  
**Input**: User description: "Develop a comprehensive .NET 8 to .NET 10 upgrade workshop called 'LTS to LTS Performance Lab' focused on enterprise retail systems at Meijer scale."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Runtime Performance Comparison (Priority: P1)

A workshop participant needs to understand cold-start performance differences between .NET 8 and .NET 10 to make informed migration decisions for their pricing microservices.

**Why this priority**: Cold-start performance directly impacts cloud costs during scale-to-zero scenarios and promotional traffic bursts, which are critical for retail operations.

**Independent Test**: Participant runs provided scripts, obtains comparison table showing four variants (8-FX, 8-AOT, 10-FX, 10-AOT) with binary size, startup time, and memory metrics within 5 minutes.

**Acceptance Scenarios**:

1. **Given** pre-built artifacts exist in artifacts/ folder, **When** participant runs measurement script, **Then** a comparison table displays startup time in milliseconds for all four variants
2. **Given** .NET 8 and .NET 10 SDKs are installed, **When** participant runs build script, **Then** all four pricing service variants compile successfully and output binary sizes
3. **Given** measurement script completes, **When** participant reviews results, **Then** .NET 10 Native AOT shows measurably faster cold-start than .NET 8 Native AOT

---

### User Story 2 - ASP.NET Core Throughput Analysis (Priority: P1)

A workshop participant needs to measure request throughput and latency improvements in .NET 10 to justify upgrading their promotions API.

**Why this priority**: High-traffic promotional APIs are mission-critical during sales events; performance improvements directly reduce infrastructure costs and improve customer experience.

**Independent Test**: Participant runs load tests against identical .NET 8 and .NET 10 versions of promotions API, obtains RPS and p95 latency metrics showing .NET 10 improvements within 5 minutes.

**Acceptance Scenarios**:

1. **Given** .NET 8 promotions API is running, **When** participant runs load test script, **Then** baseline RPS and p95 latency are captured
2. **Given** .NET 10 promotions API with caching is running, **When** participant runs same load test, **Then** improved RPS and reduced p95 latency are demonstrated
3. **Given** rate limiting is configured at 100 req/10sec, **When** load test exceeds limit, **Then** appropriate HTTP 429 responses are returned
4. **Given** both API versions are tested, **When** participant compares results, **Then** side-by-side performance improvement is quantified

---

### User Story 3 - Language Features for Maintainability (Priority: P2)

A workshop participant needs to see how C# 14 features reduce boilerplate and improve code safety in large retail codebases.

**Why this priority**: Large enterprise codebases at Meijer scale require maintainability improvements that reduce technical debt and onboarding time.

**Independent Test**: Participant reviews six side-by-side code examples (before/after), understands maintainability benefits, and can identify which feature solves which enterprise problem within 5 minutes per example.

**Acceptance Scenarios**:

1. **Given** Extension Members example, **When** participant reviews code, **Then** they understand how tax logic is consolidated without modifying Product/Order types
2. **Given** Field-Backed Properties example, **When** participant reviews code, **Then** they see how Money validation is added with logging hooks
3. **Given** all six examples, **When** participant completes module, **Then** they can map each C# 14 feature to a specific maintainability benefit for large codebases

---

### User Story 4 - Data Layer Performance (Priority: P2)

A workshop participant needs to understand EF Core 10 query optimization for JSON column updates in product catalog scenarios.

**Why this priority**: Product catalogs with dynamic attributes (colors, sizes, seasonal flags) use JSON columns; update performance impacts inventory management operations.

**Independent Test**: Participant runs measurement script comparing .NET 8 full-entity load vs .NET 10 ExecuteUpdate with JSON path, obtains query time comparison within 5 minutes.

**Acceptance Scenarios**:

1. **Given** Products table with JSONB attributes, **When** participant runs .NET 8 update script, **Then** query time for full entity load/modify/save is measured
2. **Given** same data, **When** participant runs .NET 10 ExecuteUpdate script, **Then** query time for JSON path update is measured and shown to be faster
3. **Given** both measurements complete, **When** participant reviews results, **Then** round-trip elimination benefit is quantified

---

### User Story 5 - Container Size Optimization (Priority: P2)

A workshop participant needs to measure container image size and startup improvements in .NET 10 for deployment optimization.

**Why this priority**: Smaller, faster-starting containers reduce CI/CD pipeline time and memory pressure in production, directly impacting deployment velocity.

**Independent Test**: Participant runs Docker build scripts, compares image sizes and startup times between .NET 8 and .NET 10 containers within 5 minutes.

**Acceptance Scenarios**:

1. **Given** Dockerfiles for aspnet:8.0 and aspnet:10.0, **When** participant runs build script, **Then** both images build successfully
2. **Given** both images built, **When** participant runs comparison script, **Then** .NET 10 image size is shown to be smaller
3. **Given** containers are started, **When** startup time is measured via logs, **Then** .NET 10 container starts faster

---

### User Story 6 - Migration Planning (Priority: P3)

A workshop participant needs a practical decision framework for prioritizing which services to migrate from .NET 8 to .NET 10.

**Why this priority**: Migration planning with quantified benefits enables informed business decisions and risk-managed rollout strategies.

**Independent Test**: Participant reviews decision matrix and pre-migration checklist, can identify service priority order for their scenario within 5 minutes.

**Acceptance Scenarios**:

1. **Given** decision matrix, **When** participant reviews service types, **Then** they understand why high-traffic APIs are prioritized first
2. **Given** pre-migration checklist, **When** participant plans a migration, **Then** they know to benchmark, check AOT compatibility, review dependencies, and plan rollback
3. **Given** all module measurements, **When** participant completes workshop, **Then** they can quantify expected gains (startup time, latency, memory, container size) for their own services

---

### User Story 7 - Workshop Context Setting (Priority: P1)

A workshop participant needs to understand the retail performance bar and measurement approach in the first 5 minutes.

**Why this priority**: Setting clear performance goals and measurement methodology ensures participants understand "why" before "how," improving learning outcomes.

**Independent Test**: Participant reads Module 0 content, understands sub-100ms API requirement, zero-downtime expectations, and the five metrics (startup, latency, memory, container size, RPS) within 5 minutes.

**Acceptance Scenarios**:

1. **Given** Module 0 content, **When** participant reads it, **Then** they understand the retail performance bar: <100ms API, zero-downtime during promos
2. **Given** Module 0 content, **When** participant completes it, **Then** they know they will measure startup time, p50/p95 latency, memory, container size, and RPS
3. **Given** Module 0 content, **When** participant reviews it, **Then** they understand LTS-to-LTS modernization timing and business case

---

### Edge Cases

- What happens when .NET 8 or .NET 10 SDK is missing? Module READMEs must clearly document prerequisites and provide installation links
- What happens when Docker is not installed for Module 5? README must mark Module 5 as optional with clear Docker setup instructions
- What happens when load testing tools are unavailable? Scripts must gracefully handle missing tools and suggest alternatives
- What happens when PowerShell execution policy blocks scripts? READMEs must include execution policy guidance
- What happens when participant hardware differs from baseline (4-core, 8GB RAM)? Results will vary; each module must note hardware dependency

## Requirements *(mandatory)*

### Functional Requirements

#### Module 0: Workshop Context (5 minutes)

- **FR-001**: Module MUST provide a README explaining the retail performance bar: <100ms API latency, zero-downtime during promotional events
- **FR-002**: Module MUST document the five metrics participants will measure: startup time, p50/p95 latency, memory footprint, container size, RPS
- **FR-003**: Module MUST explain the business case for LTS-to-LTS modernization timing
- **FR-004**: Module MUST be completable in 5 minutes or less

#### Module 1: Runtime & Startup (20 minutes)

- **FR-005**: Module MUST include a simple pricing microservice API with one endpoint calculating discounted prices
- **FR-006**: Module MUST include pre-built artifacts in four folders: artifacts/pub8-fx/, artifacts/pub8-aot/, artifacts/pub10-fx/, artifacts/pub10-aot/
- **FR-007**: Module MUST include a PowerShell build script that compiles all four variants
- **FR-008**: Module MUST include a PowerShell measurement script that captures binary size (MB), time-to-first-HTTP-200 (ms), and working-set memory (MB)
- **FR-009**: Measurement script MUST output a comparison table showing all four variants side-by-side
- **FR-010**: Module README MUST document: learning objectives, prerequisites (.NET 8 SDK, .NET 10 SDK), step-by-step instructions, expected output, and business value for Meijer
- **FR-011**: Module MUST be completable in 20 minutes or less

#### Module 2: ASP.NET Core Performance (25 minutes)

- **FR-012**: Module MUST include a promotions API with three endpoints: GET /promotions (list), GET /promotions/{id} (details), POST /promotions/validate (validate code)
- **FR-013**: Module MUST include a load testing script generating concurrent requests
- **FR-014**: Module MUST show .NET 8 baseline implementation
- **FR-015**: Module MUST show .NET 10 upgraded implementation with output caching on list endpoint
- **FR-016**: Module MUST configure rate limiting at 100 requests per 10 seconds on all endpoints
- **FR-017**: Module MUST include enhanced OpenAPI documentation in .NET 10 version
- **FR-018**: Module MUST include before/after load test scripts showing RPS and p95 latency
- **FR-019**: Module MUST mention (but not implement) passkey authentication for future loyalty program logins
- **FR-020**: Module README MUST document prerequisites, instructions, expected performance improvements, and business value
- **FR-021**: Module MUST be completable in 25 minutes or less

#### Module 3: C# 14 Language Features (30 minutes)

- **FR-022**: Module MUST include six side-by-side code examples: before C# 13 and after C# 14
- **FR-023**: Example 1 MUST demonstrate Extension Members consolidating tax calculation across Product and Order types
- **FR-024**: Example 2 MUST demonstrate Field-Backed Properties adding validation with logging to Money value object
- **FR-025**: Example 3 MUST demonstrate Partial Constructors for clean layering in InventoryItem with source generator integration
- **FR-026**: Example 4 MUST demonstrate User-Defined Compound Operators enabling Money += Discount and Quantity *= Multiplier
- **FR-027**: Example 5 MUST demonstrate Expanded Span<T> conversions reducing allocations in SKU parsing hot-path
- **FR-028**: Example 6 MUST demonstrate nameof on unbound generics plus null-conditional assignment for safer refactoring in generic repositories
- **FR-029**: Each example MUST include inline comments explaining maintainability or performance benefit for large codebases
- **FR-030**: All examples MUST use realistic retail domain objects: Product, SKU, Price, Discount, Cart, Order, InventoryItem, Promotion, Money, Quantity
- **FR-031**: Module README MUST document learning objectives, prerequisites, and business value for large enterprise codebases
- **FR-032**: Module MUST be completable in 30 minutes or less

#### Module 4: EF Core 10 Data Layer (15 minutes)

- **FR-033**: Module MUST include a Products table schema with JSONB attributes column
- **FR-034**: Module MUST demonstrate .NET 8 approach: load entity, deserialize JSON, modify property, serialize, SaveChanges
- **FR-035**: Module MUST demonstrate .NET 10 approach: ExecuteUpdate with JSON path syntax for single nested property update
- **FR-036**: Module MUST include a measurement script comparing query execution time between both approaches
- **FR-037**: Module MUST show product metadata examples: color options, size charts, seasonal flags
- **FR-038**: Module MUST mention (but not implement) vector containers for product recommendations and semantic search
- **FR-039**: Module README MUST document prerequisites, instructions, expected query time improvements, and business value
- **FR-040**: Module MUST be completable in 15 minutes or less

#### Module 5: Container Deployment (10 minutes)

- **FR-041**: Module MUST include Dockerfiles for aspnet:8.0 and aspnet:10.0 base images
- **FR-042**: Dockerfiles MUST build the same pricing microservice from Module 1
- **FR-043**: Module MUST include a PowerShell script that builds both images
- **FR-044**: Module MUST include a script that compares image sizes using docker images command
- **FR-045**: Module MUST include a script that measures container startup time using docker logs timestamps
- **FR-046**: Module MUST include a script that measures memory usage using docker stats
- **FR-047**: Module MUST demonstrate .NET 10 image is smaller and starts faster
- **FR-048**: Module README MUST document prerequisites (Docker), instructions, expected improvements, and business value
- **FR-049**: Module MUST be completable in 10 minutes or less

#### Module 6: Migration Planning (5 minutes)

- **FR-050**: Module MUST include a decision matrix markdown table showing service prioritization: high-traffic APIs (checkout, cart, pricing) first, then background workers, then internal tools
- **FR-051**: Module MUST include a pre-migration checklist covering: benchmark current performance, identify AOT compatibility, review dependencies, plan rollback strategy
- **FR-052**: Module MUST reference measured improvements from Modules 1-5 with quantified gains
- **FR-053**: Module README MUST document how to use decision matrix for participant's own environment
- **FR-054**: Module MUST be completable in 5 minutes or less

#### Cross-Module Requirements

- **FR-055**: Every module MUST include a README.md with: clear learning objectives, prerequisites, step-by-step instructions, expected output, and "Why This Matters for Meijer" business value section
- **FR-056**: All scripts MUST work on Windows with PowerShell
- **FR-057**: All scripts MUST include error handling for missing tools with helpful error messages
- **FR-058**: Every performance comparison MUST use identical workloads across .NET versions
- **FR-059**: All code MUST use realistic retail domain objects: Product, SKU, Price, Discount, Cart, Order, InventoryItem, Promotion
- **FR-060**: Total workshop time MUST fit within 2 hours (110 minutes allocated + 10-minute buffer)

### Key Entities

- **PricingService**: Microservice API calculating discounted prices; single endpoint accepting original price and discount percentage, returning final price
- **PromotionsAPI**: API managing promotional campaigns; endpoints for listing active promotions, getting details, and validating promo codes
- **Product**: Retail product entity with SKU, base price, attributes (JSON), category, inventory quantity
- **SKU**: Stock Keeping Unit identifier; string format with parsing logic
- **Price**: Monetary value with currency; supports arithmetic operations
- **Discount**: Promotional discount with percentage or fixed amount; applies to Price
- **Cart**: Shopping cart containing line items with products and quantities
- **Order**: Completed purchase with line items, total, tax, and payment status
- **InventoryItem**: Warehouse inventory record with SKU, quantity, location, and dynamic attributes
- **Promotion**: Marketing promotion with code, discount rules, validity period, and applicability conditions
- **Money**: Value object representing monetary amounts with validation; supports compound operators
- **Quantity**: Value object representing item counts with unit; supports multiplier operations

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Participants can complete entire workshop (Modules 0-6) within 120 minutes
- **SC-002**: Each module can be completed within its allocated time: Module 0 in 5 min, Module 1 in 20 min, Module 2 in 25 min, Module 3 in 30 min, Module 4 in 15 min, Module 5 in 10 min, Module 6 in 5 min
- **SC-003**: Module 1 measurement scripts produce comparison tables showing .NET 10 Native AOT has measurably faster cold-start than .NET 8 Native AOT (at least 20% improvement)
- **SC-004**: Module 2 load tests demonstrate .NET 10 promotions API achieves higher RPS and lower p95 latency than .NET 8 version under identical load (at least 15% improvement)
- **SC-005**: Module 3 provides six working code examples that compile and run in both .NET 8 and .NET 10
- **SC-006**: Module 4 measurement demonstrates .NET 10 ExecuteUpdate with JSON path is faster than .NET 8 full-entity load approach (at least 30% faster)
- **SC-007**: Module 5 demonstrates .NET 10 container image is smaller than .NET 8 image (at least 10% reduction) and starts faster (at least 15% faster)
- **SC-008**: All scripts run successfully on Windows with PowerShell without manual intervention (given prerequisites are met)
- **SC-009**: 90% of participants successfully run all measurement scripts and obtain comparison metrics
- **SC-010**: Participants can explain the business value of at least 4 out of 6 modules in terms of Meijer-scale retail operations
- **SC-011**: All performance measurements are reproducible on standard hardware (4-core CPU, 8GB RAM) with variance less than 10%
- **SC-012**: Pre-built artifacts in artifacts/ folders reduce Module 1 setup time to under 2 minutes

## Assumptions

- Participants have Windows machines with PowerShell 5.1 or later
- Participants have local administrator rights to install SDKs and Docker
- .NET 8 SDK and .NET 10 SDK can be installed side-by-side without conflicts
- Standard development hardware (4-core CPU, 8GB RAM, SSD) is available for consistent measurements
- Docker Desktop (if used for Module 5) is available and functional on Windows
- Network connectivity is available for NuGet package restoration and container image pulls
- Load testing tools (wrk or bombardier) can be installed or are pre-installed
- Participants have basic familiarity with REST APIs and can read C# code
- Module completion times assume participants follow instructions sequentially without extended troubleshooting
- Business value examples are relevant to retail operations (inventory, pricing, promotions, checkout)

## Workshop Structure

**Total Time**: 2 hours (120 minutes)
**Allocated Time**: 110 minutes (10-minute buffer for Q&A)

**Module Time Allocations**:
- Module 0: 5 minutes (context setting)
- Module 1: 20 minutes (runtime performance)
- Module 2: 25 minutes (ASP.NET Core)
- Module 3: 30 minutes (C# 14 features)
- Module 4: 15 minutes (EF Core 10)
- Module 5: 10 minutes (containers)
- Module 6: 5 minutes (migration planning)

**Prerequisites Documentation**: Each module README documents required SDKs, tools, and setup instructions
**Independent Modules**: Each module works standalone with isolated dependencies and setup scripts
**Incremental Complexity**: Modules progress from simple (cold-start) to complex (language features, data layer)
**Business Value**: Every module ties technical improvements to Meijer-scale retail business outcomes
