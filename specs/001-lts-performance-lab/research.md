# Research Document: LTS to LTS Performance Lab Workshop

**Feature**: 001-lts-performance-lab  
**Created**: 2025-11-03  
**Purpose**: Resolve technical unknowns and establish best practices for workshop implementation

## Research Areas

### 1. Workshop Structure & Educational Best Practices

**Decision**: Multi-module independent structure with progressive complexity

**Rationale**:
- Adult learning theory favors modular, self-contained lessons with immediate practical application
- Workshop time constraints (2 hours) require participants to skip modules if needed
- Independent modules allow participants to focus on relevant topics for their role
- Each module includes README with: objectives, prerequisites, step-by-step instructions, expected output, business value
- Pre-built artifacts (in `artifacts/`) reduce setup friction and ensure 5-minute runability

**Alternatives Considered**:
- **Linear sequential structure**: Rejected because participants cannot skip modules or focus on specific topics
- **Single monolithic demo**: Rejected because complexity overwhelms learners and violates Incremental Complexity principle
- **Separate repositories per module**: Rejected because increases setup complexity and violates Educational Clarity principle

**Best Practices Applied**:
- Time-boxed modules (5-30 minutes) with documented allocations
- "Why This Matters for Meijer" business value section in every README
- Hands-on measurement over passive observation
- Realistic domain objects (Product, SKU, Money, Cart) over toy examples

---

### 2. Native AOT Implementation Patterns

**Decision**: Demonstrate Native AOT for Module 1 (runtime/startup benchmarks) and Module 5 (container deployment) only

**Rationale**:
- Native AOT significantly impacts cold-start time and container size (primary metrics for Modules 1 & 5)
- AOT has compatibility constraints (reflection limitations) that must be explained honestly per Fair Comparison principle
- Modules 2-4 focus on features not requiring AOT demonstrations
- Dual builds (FX + AOT) show trade-off space per Technical Standards

**Alternatives Considered**:
- **AOT everywhere**: Rejected because adds complexity without educational value for ASP.NET Core features (Module 2), language features (Module 3), or EF Core (Module 4)
- **No AOT**: Rejected because cold-start and container size are critical Meijer metrics, and .NET 10 AOT improvements are significant selling points
- **AOT-only builds**: Rejected because doesn't show trade-offs and violates Fair Comparison principle

**Best Practices Applied**:
- Document AOT compatibility constraints in Module 1 README
- Show when FX is preferred (easier debugging, broader compatibility)
- Show when AOT is preferred (cold-start, container size, scale-to-zero workloads)
- Include build scripts for both variants with error handling

**AOT-Specific Considerations**:
- Use `PublishAot=true` in csproj for AOT builds
- Avoid reflection-heavy patterns (JSON source generators preferred)
- Document trimming warnings and resolution
- Measure trim analysis impact on binary size

---

### 3. Load Testing Tools & Methodology

**Decision**: Use `bombardier` as primary load testing tool with `wrk` as fallback

**Rationale**:
- `bombardier` is cross-platform (Windows, Linux, macOS), written in Go, single binary
- `wrk` requires WSL on Windows, less convenient for workshop participants
- `bombardier` provides clear output format (RPS, latency percentiles) without scripting
- Scripts include error handling for missing tools with instructions to install

**Alternatives Considered**:
- **wrk**: Rejected as primary because requires WSL on Windows, adds setup friction
- **Apache Bench (ab)**: Rejected because less accurate latency percentiles and limited concurrency
- **k6**: Rejected because requires JavaScript knowledge for test scripts, too complex for 2-hour workshop
- **Built-in .NET tools (NBomber)**: Rejected because adds code complexity, not a standard tool

**Best Practices Applied**:
- 10-second warmup before measurement to JIT compile hot paths
- Consistent load profile across .NET 8 and .NET 10 tests (same concurrency, duration, endpoints)
- Capture p50, p95, p99 latency plus RPS and error rate
- Test against localhost to eliminate network variability
- Document hardware baseline (4-core, 8GB RAM) for reproducibility

**Load Test Configuration**:
```powershell
# Module 2 load test parameters
$Concurrency = 10
$Duration = 30  # seconds after warmup
$Warmup = 10    # seconds
$Url = "http://localhost:5000/promotions"
```

---

### 4. EF Core 10 JSON Column Features

**Decision**: Demonstrate `ExecuteUpdate` with JSON path syntax for Module 4

**Rationale**:
- EF Core 10 adds `ExecuteUpdate` method with JSON path support for single-property updates
- Eliminates round-trip for full entity load/modify/save cycle
- Realistic scenario: updating seasonal flags or color availability in product catalog
- Measurable performance benefit (30%+ faster per Success Criteria)

**Alternatives Considered**:
- **Raw SQL**: Rejected because doesn't demonstrate EF Core 10 improvements
- **Full entity load**: Used as .NET 8 baseline to show the before/after comparison
- **Stored procedures**: Rejected because adds database complexity and is not EF Core-specific

**Best Practices Applied**:
- Use PostgreSQL JSONB or SQL Server JSON columns (both supported)
- Show identical data modifications in .NET 8 (load/modify/save) and .NET 10 (ExecuteUpdate)
- Measure query execution time with dotnet-counters or Stopwatch
- Include setup script to create Products table schema
- Document JSON path syntax clearly in code comments

**EF Core 10 JSON Path Example**:
```csharp
// .NET 8 approach
var product = await context.Products.FindAsync(productId);
var attrs = JsonSerializer.Deserialize<Attributes>(product.AttributesJson);
attrs.Seasonal = true;
product.AttributesJson = JsonSerializer.Serialize(attrs);
await context.SaveChangesAsync();

// .NET 10 approach
await context.Products
    .Where(p => p.Id == productId)
    .ExecuteUpdateAsync(s => s.SetProperty(
        p => p.Attributes.Seasonal, true));
```

---

### 5. C# 14 Language Features Selection

**Decision**: Demonstrate six C# 14 features with before/after code examples focused on maintainability for large codebases

**Rationale**:
- C# 14 features reduce boilerplate, improve type safety, and optimize performance
- Features selected based on retail domain applicability and Meijer-scale codebase impact
- Before/after format clearly shows improvement without requiring participants to write code
- 30-minute time allocation allows 5 minutes per feature

**Features Selected**:

1. **Extension Members**: Consolidate tax calculation logic across Product and Order types without modifying core classes (reduces coupling)
2. **Field-Backed Properties**: Add validation and logging to Money value object (improves observability and data integrity)
3. **Partial Constructors**: Clean layering for InventoryItem with source generator integration (supports enterprise patterns)
4. **User-Defined Compound Operators**: Enable `Money += Discount` and `Quantity *= Multiplier` (reduces error-prone manual calculations)
5. **Expanded Span<T> Conversions**: Reduce allocations in SKU parsing hot-path (performance optimization)
6. **nameof on Unbound Generics + Null-Conditional Assignment**: Safer refactoring in generic repositories (prevents runtime errors)

**Alternatives Considered**:
- **All C# 14 features**: Rejected because too many for 30-minute module, dilutes focus
- **Performance-only features**: Rejected because maintainability is equally important for Meijer-scale codebases
- **Toy examples**: Rejected because violates Production Patterns principle

**Best Practices Applied**:
- Use realistic retail domain objects (Product, SKU, Money, Cart, Order, etc.)
- Inline comments explain "why" not just "what"
- Each example compiles and runs in both .NET 8 (without feature) and .NET 10 (with feature)
- READMEs tie features to enterprise concerns (10K+ LOC codebases, multi-team coordination, onboarding)

---

### 6. Performance Measurement Standards

**Decision**: Use consistent measurement methodology across all modules with scripted data collection

**Rationale**:
- Reproducibility requires standardized measurement approach
- Scripted measurements eliminate human error and ensure fair comparison
- Standard hardware baseline (4-core, 8GB RAM) allows meaningful comparison across participants

**Measurement Tools**:
- **Startup Time**: `Measure-Command` in PowerShell, capture first HTTP 200 response
- **Latency**: `bombardier` output (p50, p95, p99)
- **Memory**: `dotnet-counters` for working set, `docker stats` for containers
- **Container Size**: `docker images` command
- **RPS**: `bombardier` output

**Best Practices Applied**:
- 10-second warmup before measurement to stabilize JIT compilation
- Multiple runs (3-5) with median reported to reduce variance
- Document hardware specifications in results
- Identical workloads across .NET versions (same endpoints, payloads, concurrency)
- Scripts output comparison tables for easy visualization

**Measurement Script Template**:
```powershell
# Standard measurement workflow
function Measure-Performance {
    param($ExePath, $Url)
    
    # Start process
    $proc = Start-Process $ExePath -PassThru
    
    # Wait for first HTTP 200
    $startTime = [DateTime]::Now
    while (-not (Test-Connection $Url)) { Start-Sleep -Milliseconds 100 }
    $startupTime = ([DateTime]::Now - $startTime).TotalMilliseconds
    
    # Warmup
    bombardier -c 1 -d 10s $Url | Out-Null
    
    # Measure
    $results = bombardier -c 10 -d 30s $Url --print=result
    
    # Cleanup
    Stop-Process $proc
    
    return @{
        StartupMs = $startupTime
        RPS = ...
        P50 = ...
        P95 = ...
        P99 = ...
    }
}
```

---

### 7. Cross-Platform Script Strategy

**Decision**: Primary focus on PowerShell for Windows, bash scripts provided for completeness

**Rationale**:
- Workshop assumes Windows machines per spec assumptions
- PowerShell is native to Windows, no additional installation required
- Bash scripts support WSL2, macOS, Linux for participants with those environments
- Constitution requires cross-platform scripts (PowerShell + bash)

**Alternatives Considered**:
- **PowerShell Core only**: Rejected because not all participants have PowerShell Core installed
- **Bash only**: Rejected because requires WSL on Windows, adds setup friction
- **Python scripts**: Rejected because adds dependency, not guaranteed to be installed

**Best Practices Applied**:
- Scripts named consistently: `script-name.ps1` and `script-name.sh`
- Bash scripts include shebang: `#!/bin/bash`
- Both scripts produce identical output format
- Error handling for missing tools with installation instructions
- Document execution policy for PowerShell in workshop prerequisites

---

### 8. Pre-Built Artifacts Strategy

**Decision**: Check pre-built binaries into `artifacts/` folder for Module 1

**Rationale**:
- Module 1 requires 4 variants (8-FX, 8-AOT, 10-FX, 10-AOT) to demonstrate startup comparison
- Building all variants from source takes 5-10 minutes (violates 5-minute runability)
- Pre-built artifacts reduce Module 1 setup to <2 minutes per Success Criteria
- Build scripts still provided for participants who want to rebuild

**Alternatives Considered**:
- **No pre-built artifacts**: Rejected because violates Educational Clarity principle (5-minute runability)
- **Download from releases**: Rejected because adds network dependency and complexity
- **Build on demand**: Rejected because takes too long for workshop time constraints

**Best Practices Applied**:
- Artifacts clearly labeled with version (pub8-fx, pub8-aot, pub10-fx, pub10-aot)
- Include build-all.ps1 script for rebuilding if needed
- Document artifact size in Module 1 README
- .gitignore excludes participant-generated artifacts (only pre-built ones checked in)

---

## Technical Decisions Summary

| Area | Decision | Primary Rationale |
|------|----------|-------------------|
| Workshop Structure | Multi-module independent | Incremental Complexity, Educational Clarity |
| Native AOT | Modules 1 & 5 only | Cold-start and container size focus |
| Load Testing | bombardier (wrk fallback) | Cross-platform, easy installation |
| EF Core 10 | ExecuteUpdate with JSON path | Measurable performance, realistic scenario |
| C# 14 Features | 6 features before/after | Maintainability for large codebases |
| Measurements | Scripted with standard tools | Reproducibility, Fair Comparison |
| Scripts | PowerShell primary, bash secondary | Windows focus, cross-platform support |
| Pre-Built Artifacts | Checked into repo | 5-minute runability for Module 1 |

---

## Open Questions / Risks

### Risk: Load Testing Tool Installation
**Mitigation**: Scripts detect missing tool and provide installation instructions with download links. Module 2 README includes troubleshooting section.

### Risk: SDK Version Conflicts
**Mitigation**: Workshop prerequisites require .NET 8 SDK and .NET 10 SDK installed side-by-side. global.json files in each module folder pin SDK version.

### Risk: Docker Not Installed
**Mitigation**: Module 5 marked as optional in workshop guide. README includes Docker Desktop installation instructions.

### Risk: Database Not Available for Module 4
**Mitigation**: Module 4 can use SQLite with JSON support as fallback. Setup script detects database and configures appropriately.

### Risk: Hardware Variance Affects Results
**Mitigation**: Document standard baseline (4-core, 8GB RAM). Scripts include hardware detection and note variance in output.

---

## Next Steps

1. **Phase 1**: Create data-model.md with 11 domain entities
2. **Phase 1**: Create contracts/ folder with OpenAPI specs for PricingService and PromotionsAPI
3. **Phase 1**: Create quickstart.md with workshop setup instructions
4. **Phase 1**: Update agent context with selected technologies
5. **Phase 2**: Generate tasks.md via `/speckit.tasks` command
