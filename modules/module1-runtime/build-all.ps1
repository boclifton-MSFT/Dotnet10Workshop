# Build all 4 variants of PricingService
# Outputs to ../../artifacts/ folders

$ErrorActionPreference = "Stop"

# Function to initialize Visual Studio environment for Native AOT builds
function Initialize-VSEnvironment {
    # Try VS 2026 Insiders first
    $vsPath = "C:\Program Files\Microsoft Visual Studio\2026\Preview\VC\Auxiliary\Build\vcvars64.bat"
    if (-not (Test-Path $vsPath)) {
        $vsPath = "C:\Program Files\Microsoft Visual Studio\2026\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
    }
    if (-not (Test-Path $vsPath)) {
        $vsPath = "C:\Program Files\Microsoft Visual Studio\2026\Professional\VC\Auxiliary\Build\vcvars64.bat"
    }
    if (-not (Test-Path $vsPath)) {
        $vsPath = "C:\Program Files\Microsoft Visual Studio\2026\Community\VC\Auxiliary\Build\vcvars64.bat"
    }
    # Fall back to VS 2022
    if (-not (Test-Path $vsPath)) {
        $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
    }
    if (-not (Test-Path $vsPath)) {
        $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
    }
    if (-not (Test-Path $vsPath)) {
        $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    }
    
    if (Test-Path $vsPath) {
        Write-Host "Initializing Visual Studio environment for Native AOT..." -ForegroundColor Yellow
        Write-Host "  Using: $vsPath" -ForegroundColor Gray
        $tempFile = [System.IO.Path]::GetTempFileName()
        cmd /c "`"$vsPath`" && set" > $tempFile
        Get-Content $tempFile | ForEach-Object {
            if ($_ -match '^([^=]+)=(.*)$') {
                [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], [System.EnvironmentVariableTarget]::Process)
            }
        }
        Remove-Item $tempFile
        Write-Host "✅ Visual Studio environment initialized" -ForegroundColor Green
        return $true
    }
    return $false
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building PricingService (All Variants)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# First, restore packages for all target frameworks
Write-Host "Restoring packages for all frameworks..." -ForegroundColor Yellow
& dotnet restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Restore failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Restore completed" -ForegroundColor Green
Write-Host ""

# Define build configurations
# Set $skipAot = $true to skip Native AOT builds if Windows SDK is not installed
$skipAot = $false  # Change to $true to skip AOT builds

$builds = @(
    @{
        Name = ".NET 8 Framework-Dependent"
        TargetFramework = "net8.0"
        PublishAot = $false
        OutputDir = "..\..\artifacts\pub8-fx"
    },
    @{
        Name = ".NET 8 Native AOT"
        TargetFramework = "net8.0"
        PublishAot = $true
        OutputDir = "..\..\artifacts\pub8-aot"
    },
    @{
        Name = ".NET 10 Framework-Dependent"
        TargetFramework = "net10.0"  # Using .NET 9 as placeholder for .NET 10
        PublishAot = $false
        OutputDir = "..\..\artifacts\pub10-fx"
    },
    @{
        Name = ".NET 10 Native AOT"
        TargetFramework = "net10.0"  # Using .NET 9 as placeholder for .NET 10
        PublishAot = $true
        OutputDir = "..\..\artifacts\pub10-aot"
    }
)

# Filter out AOT builds if requested
if ($skipAot) {
    Write-Host "⚠️  Skipping Native AOT builds (Windows SDK required)" -ForegroundColor Yellow
    $builds = $builds | Where-Object { -not $_.PublishAot }
    Write-Host ""
}

foreach ($build in $builds) {
    Write-Host "Building: $($build.Name)" -ForegroundColor Yellow
    Write-Host "  Target: $($build.TargetFramework)" -ForegroundColor Gray
    Write-Host "  Output: $($build.OutputDir)" -ForegroundColor Gray
    
    # Initialize VS environment for AOT builds
    if ($build.PublishAot) {
        if (-not (Initialize-VSEnvironment)) {
            Write-Host "  ⚠️  Warning: Could not initialize Visual Studio environment" -ForegroundColor Yellow
            Write-Host "  Please run this script from 'Developer PowerShell for VS 2022'" -ForegroundColor Yellow
        }
    }
    
    # Build command
    $publishArgs = @(
        "publish",
        "-c", "Release",
        "-f", $build.TargetFramework,
        "-o", $build.OutputDir,
        "--self-contained", "true"
    )
    
    if ($build.PublishAot) {
        $publishArgs += @("-p:PublishAot=true", "-p:OptimizationPreference=Size")
        Write-Host "  AOT: Enabled with Size Optimization (this may take 3-5 minutes)" -ForegroundColor Magenta
    }
    
    # Execute build
    $startTime = Get-Date
    & dotnet @publishArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Build failed!" -ForegroundColor Red
        exit 1
    }
    
    $duration = (Get-Date) - $startTime
    Write-Host "  ✅ Build succeeded in $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Green
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All builds completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run .\measure-coldstart.ps1" -ForegroundColor Gray
Write-Host "  2. Run .\measure-size.ps1" -ForegroundColor Gray
Write-Host "  3. Run .\measure-memory.ps1" -ForegroundColor Gray
