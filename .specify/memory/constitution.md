Hey man<!--
Sync Impact Report:
- Version change: NEW → 1.0.0
- This is the initial constitution for Dotnet10Workshop
- Principles added: Educational Clarity, Fair Comparison, Production Patterns, Incremental Complexity, Enterprise Context
- Templates status:
  ✅ plan-template.md - Constitution Check section will reference these principles
  ✅ spec-template.md - User stories align with educational and incremental complexity principles
  ✅ tasks-template.md - Task organization supports incremental complexity principle
- Follow-up: Ensure all workshop modules comply with the 5-minute runnable requirement
-->

# Dotnet10Workshop Constitution

## Core Principles

### I. Educational Clarity (NON-NEGOTIABLE)

Every example, comparison, and exercise MUST be self-explanatory and runnable within 5 minutes of checkout.

**Requirements:**
- Each module includes ready-to-run scripts (PowerShell/bash) for measurements
- Performance comparisons MUST be measurable with included tooling (no external dependencies)
- All retail scenarios MUST be relatable to enterprise operations (inventory, pricing, cart, checkout)
- Code samples include inline comments explaining .NET 8 vs .NET 10 differences
- Prerequisites clearly documented at module level

**Rationale:** Workshop participants have limited time; complexity barriers reduce learning outcomes. Five-minute runability ensures focus remains on framework differences rather than environment troubleshooting.

### II. Fair Comparison

.NET 8 and .NET 10 MUST be compared under identical conditions with reproducible measurements and honest trade-off presentation.

**Requirements:**
- Identical business scenarios implemented for both .NET 8 and .NET 10 (same API, same logic, same data)
- Measurement scripts MUST run both versions with identical load, duration, and environment
- All performance claims MUST be reproducible on standard hardware (documented baseline: 4-core, 8GB RAM)
- Trade-offs explicitly documented (e.g., AOT limitations, migration effort, compatibility impacts)
- No cherry-picking: show both wins and regressions where applicable

**Rationale:** Educational integrity demands honest comparison. Meijer-scale decisions require understanding both benefits and costs of LTS-to-LTS migration.

### III. Production Patterns

All code examples MUST reflect patterns suitable for Meijer-scale retail operations, with security, reliability, and maintainability baked in from the start.

**Requirements:**
- Code follows enterprise standards: structured logging, error handling, health checks, configuration management
- Security practices mandatory: no hardcoded secrets, input validation, authentication/authorization examples
- Performance thresholds enforced: <100ms API latency (p95), cold-start optimization for scale-to-zero
- Realistic data volumes and concurrency patterns (1000+ RPS scenarios, catalog with 100K+ SKUs)
- Production-ready patterns: retry logic, circuit breakers, graceful degradation

**Rationale:** Workshop graduates deploy to production systems serving millions of customers. Toy examples create technical debt; production patterns create transfer-ready knowledge.

### IV. Incremental Complexity

Workshop modules MUST progress from simple to complex with clear time allocations, and each module MUST work independently.

**Requirements:**
- 2-hour workshop structure with documented time budgets per module (5-30 minutes)
- Module 0 establishes baseline, modules 1-6 build incrementally
- Each module can be run standalone (independent setup scripts, isolated dependencies)
- Complexity progression documented: minimal API → caching → language features → data layer → containers
- Clear entry/exit criteria for each module (what you'll learn, what you'll measure)

**Rationale:** Mixed-skill audiences require scaffolded learning. Time pressure demands modularity; independent modules allow focus on relevant topics without requiring full completion.

### V. Enterprise Context

Every feature demo MUST tie to large-scale codebase considerations, cloud cost optimization, observability, and measurable business value.

**Requirements:**
- Business value explicitly stated for each module (e.g., "faster scale-to-zero → lower promo-burst costs")
- Large-scale impact documented (10K+ LOC codebases, multi-team coordination, deployment frequency)
- Cloud cost implications calculated (container size, memory footprint, cold-start frequency)
- Observability demonstrated: metrics, logging, tracing, diagnostics endpoints
- Migration planning guidance: risk assessment, rollback strategy, incremental adoption path

**Rationale:** Meijer operates at enterprise scale with cloud cost accountability and zero-downtime requirements. Features must demonstrate impact on TCO, team velocity, and system reliability.

## Technical Standards

### Dual-Build Requirement

Where applicable, examples MUST include both **Framework-Dependent (FX)** and **Native AOT** builds to demonstrate trade-off space.

**Mandatory for:** Runtime/startup benchmarks, container size comparisons, API cold-start measurements.

**Documentation Required:** When to choose FX vs AOT, compatibility constraints, reflection limitations.

### Cross-Platform Scripts

All automation (build, publish, measure, load test) MUST support both PowerShell and bash execution.

**Requirements:**
- Scripts named with `.ps1` and `.sh` extensions
- Shebang lines and execution permissions for bash scripts
- Equivalent functionality across platforms (verified on Windows 11 + WSL2, macOS, Linux)

### Performance Measurement Standards

All performance claims MUST be backed by scripted measurements capturing:

1. **Startup Time**: Time from process start to first successful HTTP 200 response
2. **Latency**: p50, p95, p99 response times under load
3. **Memory**: Working set (MB) after warmup and under load
4. **Container Size**: Published image size (MB) for both .NET 8 and .NET 10
5. **RPS (Requests Per Second)**: Throughput under sustained load (10s duration minimum)

**Tooling:** Scripts use `dotnet-counters`, `wrk` or `bombardier`, and `docker images` where applicable.

## Workshop Delivery Standards

### Time Allocation Enforcement

- Module 0: 5 minutes (framing + measurement overview)
- Module 1: 20 minutes (runtime & startup benchmarks)
- Module 2: 25 minutes (ASP.NET Core features + load testing)
- Module 3: 30 minutes (C# 14 language features)
- Module 4: 15 minutes (EF Core 10 enhancements)
- Module 5: 10 minutes (container optimizations)
- Module 6: 5 minutes (migration planning + wrap-up)

**Total:** 110 minutes (10-minute buffer for Q&A)

### Prerequisites Documentation

Each module README MUST document:
- Required SDKs (.NET 8 SDK, .NET 10 SDK)
- Optional tools (Docker, wrk/bombardier for load testing)
- Platform-specific setup (Windows Terminal, WSL2, macOS Homebrew)

## Governance

This constitution supersedes all other workshop development practices. Every module, script, and example MUST comply with these principles.

**Amendment Process:**
- Proposed changes documented in `.specify/memory/` with rationale
- Version incremented per semantic versioning (MAJOR: principle removal/redefinition; MINOR: new principle; PATCH: clarification)
- All templates and existing modules reviewed for consistency after amendment

**Compliance Review:**
- New modules reviewed against constitution checklist before merge
- Performance measurements validated on standard hardware before claiming results
- Principle violations flagged in code review with explicit justification required

**Version Control:**
- Constitution changes tracked with git commits referencing version bump
- Breaking changes (MAJOR version) require migration guide for existing modules

**Version**: 1.0.0 | **Ratified**: 2025-11-03 | **Last Amended**: 2025-11-03
