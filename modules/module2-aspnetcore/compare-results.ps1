# Compare load test results between .NET 8 and .NET 10

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Load Test Comparison" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load results
$net8File = "results/net8-results.json"
$net10File = "results/net10-results.json"

if (-not (Test-Path $net8File)) {
    Write-Host "❌ NET8 results not found: $net8File" -ForegroundColor Red
    Write-Host "Run: .\load-test.ps1 -Variant NET8" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $net10File)) {
    Write-Host "❌ NET10 results not found: $net10File" -ForegroundColor Red
    Write-Host "Run: .\load-test.ps1 -Variant NET10" -ForegroundColor Yellow
    exit 1
}

# Parse results
$net8Results = Get-Content $net8File | ConvertFrom-Json
$net10Results = Get-Content $net10File | ConvertFrom-Json

Write-Host "Results from $($net8Results.timestamp)" -ForegroundColor Gray
Write-Host ""

# Display raw output for analysis
Write-Host "=== .NET 8 Results ===" -ForegroundColor Yellow
Write-Host $net8Results.raw_output
Write-Host ""

Write-Host "=== .NET 10 Results ===" -ForegroundColor Yellow
Write-Host $net10Results.raw_output
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Analysis Notes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "For detailed comparison, analyze the tool output above:" -ForegroundColor Gray
Write-Host "- .NET 8: Baseline (no caching, no rate limiting)" -ForegroundColor Gray
Write-Host "- .NET 10: With output caching (GET /promotions cached) and rate limiting" -ForegroundColor Gray
Write-Host ""
Write-Host "Expected improvements in .NET 10:" -ForegroundColor Yellow
Write-Host "  • 15%+ higher RPS (due to both caching and platform improvements)" -ForegroundColor Gray
Write-Host "  • 10-20% lower average latency" -ForegroundColor Gray
Write-Host "  • 20-30% lower p95/p99 latency (more consistent performance)" -ForegroundColor Gray
Write-Host ""
Write-Host "Cache hit analysis:" -ForegroundColor Yellow
Write-Host "  • .NET 10 caches GET /promotions (60% of typical load)" -ForegroundColor Gray
Write-Host "  • Expect ~60% cache hit rate for typical access patterns" -ForegroundColor Gray
Write-Host "  • This contributes significantly to throughput improvement" -ForegroundColor Gray
Write-Host ""

Write-Host "Results files saved:" -ForegroundColor Green
Write-Host "  • $net8File" -ForegroundColor Gray
Write-Host "  • $net10File" -ForegroundColor Gray
