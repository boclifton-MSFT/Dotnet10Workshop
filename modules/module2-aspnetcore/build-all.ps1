# Build PromotionsAPI for both .NET 8 and .NET 10
# Simplified single-project approach using conditional compilation

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building PromotionsAPI (Both Variants)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define build configurations
$builds = @(
    @{
        Name = ".NET 8 (No Caching/Rate Limiting)"
        TargetFramework = "net8.0"
        OutputDir = "../../artifacts/prom8-fx"
    },
    @{
        Name = ".NET 10 (With Caching/Rate Limiting)"
        TargetFramework = "net10.0"
        OutputDir = "../../artifacts/prom10-fx"
    }
)

foreach ($build in $builds) {
    Write-Host "Building: $($build.Name)" -ForegroundColor Yellow
    Write-Host "  Target: $($build.TargetFramework)" -ForegroundColor Gray
    Write-Host "  Output: $($build.OutputDir)" -ForegroundColor Gray
    
    # Note: Conditional compilation is handled via #if NET10_0_OR_GREATER in Program.cs
    # .NET 9 targets will have the .NET 10+ features compiled in
    
    $publishArgs = @(
        "publish",
        "-c", "Release",
        "-f", $build.TargetFramework,
        "-o", $build.OutputDir,
        "--self-contained", "false"
    )
    
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
Write-Host "  1. Run .\load-test.ps1 -Variant NET8" -ForegroundColor Gray
Write-Host "  2. Run .\load-test.ps1 -Variant NET10" -ForegroundColor Gray
Write-Host "  3. Run .\compare-results.ps1" -ForegroundColor Gray
