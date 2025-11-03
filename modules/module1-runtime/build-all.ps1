# Build all 4 variants of PricingService
# Outputs to ../../artifacts/ folders

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building PricingService (All Variants)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define build configurations
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
        TargetFramework = "net9.0"  # Using .NET 9 as placeholder for .NET 10
        PublishAot = $false
        OutputDir = "..\..\artifacts\pub10-fx"
    },
    @{
        Name = ".NET 10 Native AOT"
        TargetFramework = "net9.0"  # Using .NET 9 as placeholder for .NET 10
        PublishAot = $true
        OutputDir = "..\..\artifacts\pub10-aot"
    }
)

foreach ($build in $builds) {
    Write-Host "Building: $($build.Name)" -ForegroundColor Yellow
    Write-Host "  Target: $($build.TargetFramework)" -ForegroundColor Gray
    Write-Host "  Output: $($build.OutputDir)" -ForegroundColor Gray
    
    # Build command
    $publishArgs = @(
        "publish",
        "-c", "Release",
        "-f", $build.TargetFramework,
        "-o", $build.OutputDir,
        "--self-contained", "true"
    )
    
    if ($build.PublishAot) {
        $publishArgs += @("-p:PublishAot=true")
        Write-Host "  AOT: Enabled (this may take 3-5 minutes)" -ForegroundColor Magenta
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
