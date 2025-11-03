# Quick Start Guide: LTS to LTS Performance Lab Workshop

**Workshop Duration**: 2 hours  
**Target Audience**: .NET developers evaluating .NET 8 → .NET 10 migration  
**Difficulty**: Intermediate

## Overview

This hands-on workshop demonstrates measurable performance, reliability, and maintainability improvements between .NET 8 and .NET 10 LTS releases using realistic retail scenarios from Meijer-scale operations.

You will:
- ✅ Compare cold-start performance (4 variants: 8-FX, 8-AOT, 10-FX, 10-AOT)
- ✅ Measure API throughput and latency improvements
- ✅ Explore C# 14 language features for large codebases
- ✅ Optimize EF Core 10 JSON column updates
- ✅ Analyze container image size and startup time
- ✅ Plan migration strategy with decision matrix

**Performance Bar**: All examples target <100ms API latency (p95), sub-second cold-starts, and zero-downtime deployments for retail operations.

---

## Prerequisites

### Required Software

#### 1. .NET SDKs (Both Required)

**Installation**:
- Download [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- Download [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0) *(hypothetical link for workshop)*

**Verification**:
```powershell
dotnet --list-sdks
# Expected output (both versions):
# 8.0.xxx [C:\Program Files\dotnet\sdk]
# 10.0.xxx [C:\Program Files\dotnet\sdk]
```

**Notes**:
- Both SDKs install side-by-side without conflicts
- Each module folder includes `global.json` to pin SDK version
- Requires ~2GB disk space for both SDKs

#### 2. PowerShell 5.1 or Later

**Windows 10/11**: Pre-installed, verify version:
```powershell
$PSVersionTable.PSVersion
# Expected: Major 5 or higher
```

**PowerShell Core (Optional)**: Download from [Microsoft PowerShell](https://github.com/PowerShell/PowerShell)

#### 3. Git (for Cloning Repository)

**Installation**: Download from [git-scm.com](https://git-scm.com/)

**Verification**:
```powershell
git --version
# Expected: git version 2.x or higher
```

---

### Optional Software (Module-Specific)

#### Docker Desktop (Module 5 Only)

**Purpose**: Container deployment comparisons

**Installation**: Download from [Docker Desktop](https://www.docker.com/products/docker-desktop)

**Requirements**:
- Windows 10/11 Pro, Enterprise, or Education (with Hyper-V)
- OR Windows 11 Home with WSL 2
- 4GB RAM allocated to Docker

**Verification**:
```powershell
docker --version
# Expected: Docker version 20.x or higher

docker run hello-world
# Expected: "Hello from Docker!" message
```

**Notes**:
- Module 5 is optional if Docker not available
- Pre-built measurements provided in Module 5 README if skipping

#### Load Testing Tool (Module 2)

**Option 1: bombardier (Recommended)**

**Installation (Windows)**:
```powershell
# Download from GitHub releases
Invoke-WebRequest -Uri "https://github.com/codesenberg/bombardier/releases/download/v1.2.6/bombardier-windows-amd64.exe" -OutFile "$env:USERPROFILE\Downloads\bombardier.exe"

# Move to PATH location
Move-Item "$env:USERPROFILE\Downloads\bombardier.exe" "C:\Windows\System32\bombardier.exe"
```

**Verification**:
```powershell
bombardier --version
# Expected: bombardier version 1.2.x
```

**Option 2: wrk (Requires WSL)**

**Installation (WSL Ubuntu)**:
```bash
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev git
git clone https://github.com/wg/wrk.git
cd wrk
make
sudo cp wrk /usr/local/bin
```

**Verification**:
```bash
wrk --version
# Expected: wrk 4.x
```

**Notes**:
- Module 2 scripts detect which tool is available
- bombardier is cross-platform, wrk requires WSL on Windows
- Pre-built load test results provided if neither tool available

#### Database (Module 4 Only)

**Option 1: SQL Server LocalDB (Lightweight)**

**Installation**: Included with Visual Studio or download [SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)

**Verification**:
```powershell
sqllocaldb info
# Expected: List of LocalDB instances
```

**Option 2: PostgreSQL**

**Installation**: Download from [PostgreSQL](https://www.postgresql.org/download/windows/)

**Option 3: SQLite (Fallback)**

**Installation**: Included with .NET SDK (no separate install)

**Notes**:
- Module 4 scripts auto-detect database availability
- SQLite used as fallback if SQL Server/PostgreSQL unavailable
- JSON column features work on all three databases

---

## Repository Setup

### 1. Clone Repository

```powershell
cd C:\Repos  # Or your preferred location
git clone https://github.com/meijer/Dotnet10Workshop.git
cd Dotnet10Workshop
```

### 2. Checkout Feature Branch

```powershell
git checkout 001-lts-performance-lab
```

### 3. Verify Structure

```powershell
Get-ChildItem -Directory
# Expected folders:
# - modules/ (7 workshop modules)
# - shared/ (domain models and scripts)
# - artifacts/ (pre-built binaries)
# - docs/ (facilitator and participant guides)
```

### 4. Run Prerequisites Check

```powershell
.\shared\Scripts\check-prerequisites.ps1
```

**Expected Output**:
```
✅ .NET 8 SDK found: 8.0.xxx
✅ .NET 10 SDK found: 10.0.xxx
✅ PowerShell 5.1 or later: 7.x
✅ Git found: 2.x
⚠️  Docker not found (Module 5 will be skipped)
⚠️  Load test tool not found (Module 2 results pre-provided)
✅ SQL Server LocalDB found

Summary: 4 of 6 prerequisites met. You can proceed with most modules.
```

---

## Workshop Structure

### Time Allocation (Total: 2 hours)

| Module | Duration | Topic | Key Deliverable |
|--------|----------|-------|-----------------|
| 0 | 5 min | Warm-Up & Framing | Performance bar explanation |
| 1 | 20 min | Runtime & Startup | Cold-start comparison table |
| 2 | 25 min | ASP.NET Core Performance | RPS and p95 latency results |
| 3 | 30 min | C# 14 Language Features | 6 before/after examples |
| 4 | 15 min | EF Core 10 Data Layer | JSON update performance |
| 5 | 10 min | Container Deployment | Image size comparison |
| 6 | 5 min | Migration Planning | Decision matrix & checklist |
| Buffer | 10 min | Q&A | Discussion time |

### Independent Modules

Each module works standalone with isolated dependencies. You can:
- ✅ Run modules in any order (though 0 → 1 → 2 → ... recommended)
- ✅ Skip modules not relevant to your role
- ✅ Focus on specific topics (e.g., language features only)
- ✅ Complete modules at your own pace

---

## Quick Start Per Module

### Module 0: Warm-Up & Framing

**Time**: 5 minutes  
**Location**: `modules/module0-warmup/README.md`

**Action**: Read the README to understand:
- Retail performance bar (<100ms API, zero-downtime)
- Five metrics: startup time, latency, memory, container size, RPS
- LTS-to-LTS modernization timing and business case

**No scripts to run** – this is context-setting only.

---

### Module 1: Runtime & Startup

**Time**: 20 minutes  
**Location**: `modules/module1-runtime/`

**Quick Start**:
```powershell
cd modules\module1-runtime

# Option 1: Use pre-built artifacts (< 2 min)
.\measure-startup.ps1

# Option 2: Rebuild all variants (5-10 min)
.\build-all.ps1
.\measure-startup.ps1
```

**Expected Output**: Comparison table showing startup time, binary size, and memory for 4 variants.

---

### Module 2: ASP.NET Core Performance

**Time**: 25 minutes  
**Location**: `modules/module2-aspnetcore/`

**Quick Start**:
```powershell
cd modules\module2-aspnetcore

# Test .NET 8 baseline
cd PromotionsAPI.NET8
dotnet run &
cd ..
.\load-test.ps1 -TargetUrl "http://localhost:5001" -OutputFile "net8-results.json"

# Test .NET 10 with caching & rate limiting
cd PromotionsAPI.NET10
dotnet run &
cd ..
.\load-test.ps1 -TargetUrl "http://localhost:5001" -OutputFile "net10-results.json"

# Compare results
.\compare-results.ps1 -Net8File "net8-results.json" -Net10File "net10-results.json"
```

**Expected Output**: RPS and p95 latency improvements (15%+ in .NET 10).

---

### Module 3: C# 14 Language Features

**Time**: 30 minutes  
**Location**: `modules/module3-csharp14/`

**Quick Start**:
```powershell
cd modules\module3-csharp14

# Each subfolder has before/after examples
cd 01-extension-members
dotnet run  # Runs both versions, shows output

cd ..
cd 02-field-backed-props
dotnet run

# Repeat for all 6 examples
```

**Expected Output**: Console output showing before/after code behavior with inline explanations.

---

### Module 4: EF Core 10 Data Layer

**Time**: 15 minutes  
**Location**: `modules/module4-efcore/`

**Quick Start**:
```powershell
cd modules\module4-efcore

# Setup database (one-time)
.\setup-database.ps1

# Test .NET 8 approach
cd ProductCatalog.NET8
dotnet run

# Test .NET 10 approach
cd ..
cd ProductCatalog.NET10
dotnet run

# Compare query times
cd ..
.\measure-queries.ps1
```

**Expected Output**: Query time comparison showing 30%+ improvement in .NET 10.

---

### Module 5: Container Deployment

**Time**: 10 minutes (if Docker installed)  
**Location**: `modules/module5-containers/`

**Quick Start**:
```powershell
cd modules\module5-containers

# Build both images
.\build-images.ps1

# Compare sizes and startup
.\compare-images.ps1
```

**Expected Output**: Image size (10%+ reduction) and startup time (15%+ faster) comparison.

**If Docker Not Installed**: Read README for pre-provided measurements.

---

### Module 6: Migration Planning

**Time**: 5 minutes  
**Location**: `modules/module6-migration/`

**Action**: Review two documents:
1. `decision-matrix.md` - Service prioritization table
2. `pre-migration-checklist.md` - Steps before migrating

**No scripts to run** – planning guidance only.

---

## Troubleshooting

### Issue: PowerShell Execution Policy Blocks Scripts

**Error**: `cannot be loaded because running scripts is disabled`

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: .NET SDK Version Mismatch

**Error**: `The specified SDK version could not be found`

**Solution**:
- Check `global.json` in module folder
- Ensure corresponding SDK is installed: `dotnet --list-sdks`
- Install missing SDK from prerequisites section

### Issue: Port Already in Use

**Error**: `Unable to bind to http://localhost:5000`

**Solution**:
```powershell
# Find process using port
netstat -ano | findstr :5000

# Kill process (replace <PID> with process ID from above)
taskkill /PID <PID> /F
```

### Issue: Load Test Tool Not Found

**Error**: `bombardier: command not found`

**Solution**:
- Install bombardier per prerequisites section
- OR review pre-provided results in Module 2 README

### Issue: Docker Not Running

**Error**: `Cannot connect to the Docker daemon`

**Solution**:
- Start Docker Desktop
- Wait for "Docker is running" status in system tray
- OR skip Module 5 and review pre-provided measurements

---

## Getting Help

- **Workshop Issues**: Check `docs/troubleshooting.md`
- **Module-Specific Questions**: See individual module READMEs
- **Performance Variance**: Acceptable variance is ±10% due to hardware differences

---

## Next Steps After Workshop

1. **Assess Your Services**: Use Module 6 decision matrix to prioritize migration targets
2. **Benchmark Baseline**: Run Module 1 scripts against your own APIs
3. **Pilot Migration**: Start with one high-traffic API using patterns from Module 2
4. **Review Code**: Apply C# 14 features from Module 3 to reduce boilerplate
5. **Optimize Queries**: Implement EF Core 10 JSON updates from Module 4
6. **Containerize**: Use Module 5 Dockerfiles as templates

---

## Workshop Completion Checklist

After completing the workshop, you should be able to:

- [ ] Explain the retail performance bar (<100ms API, zero-downtime)
- [ ] Measure cold-start time, latency, memory, container size, RPS
- [ ] Quantify .NET 10 improvements (20%+ cold-start, 15%+ RPS, 30%+ query speed)
- [ ] Identify which C# 14 features reduce boilerplate in your codebase
- [ ] Demonstrate EF Core 10 JSON path updates
- [ ] Prioritize services for migration using decision matrix
- [ ] Document expected ROI (cloud cost, deployment velocity, TCO)

---

## Additional Resources

- **Constitution**: `.specify/memory/constitution.md` - Workshop principles
- **Facilitator Guide**: `docs/workshop-guide.md` - Timing, troubleshooting, tips
- **Participant Guide**: `docs/participant-guide.md` - Learning objectives, notes
- **API Contracts**: `specs/001-lts-performance-lab/contracts/` - OpenAPI specifications

---

## Hardware Recommendations

**Minimum**:
- 4-core CPU (Intel i5 / AMD Ryzen 5)
- 8GB RAM
- 10GB free disk space
- SSD storage

**Optimal**:
- 8-core CPU (Intel i7 / AMD Ryzen 7)
- 16GB RAM
- 20GB free disk space
- NVMe SSD

**Notes**:
- All performance measurements documented with baseline hardware
- Results will vary on different hardware (±10% acceptable)
- Docker requires 4GB RAM allocation (separate from OS)

---

**Ready to Begin?** Start with Module 0 and proceed sequentially: `cd modules\module0-warmup`
