# Measure binary size for all 4 variants

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Binary Size Measurement" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define directories to measure
$variants = @(
    @{ Name = ".NET 8 FX"; Path = "..\..\artifacts\pub8-fx" },
    @{ Name = ".NET 8 AOT"; Path = "..\..\artifacts\pub8-aot" },
    @{ Name = ".NET 10 FX"; Path = "..\..\artifacts\pub10-fx" },
    @{ Name = ".NET 10 AOT"; Path = "..\..\artifacts\pub10-aot" }
)

$results = @{}

foreach ($variant in $variants) {
    Write-Host "Measuring: $($variant.Name)" -ForegroundColor Yellow
    
    if (-not (Test-Path $variant.Path)) {
        Write-Host "  ⚠️  Directory not found: $($variant.Path)" -ForegroundColor Red
        Write-Host "  Run .\build-all.ps1 first or use pre-built artifacts" -ForegroundColor Red
        continue
    }
    
    # Calculate total size
    $totalBytes = (Get-ChildItem -Path $variant.Path -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $totalMB = $totalBytes / 1MB
    
    $results[$variant.Name] = $totalMB
    
    Write-Host "  Size: $([math]::Round($totalMB, 2)) MB ($([math]::Round($totalBytes / 1KB, 0)) KB)" -ForegroundColor Cyan
    Write-Host ""
}

# Display summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Binary Size Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($key in $results.Keys | Sort-Object) {
    $value = $results[$key]
    Write-Host "$key : $([math]::Round($value, 2)) MB" -ForegroundColor White
}

Write-Host ""

# Calculate AOT overhead
if ($results.ContainsKey(".NET 8 FX") -and $results.ContainsKey(".NET 8 AOT")) {
    $fxSize = $results[".NET 8 FX"]
    $aotSize = $results[".NET 8 AOT"]
    $overhead = $aotSize / $fxSize
    Write-Host "📦 AOT Overhead: $([math]::Round($overhead, 1))x larger than FX" -ForegroundColor Yellow
}

# Calculate .NET 10 improvement
if ($results.ContainsKey(".NET 8 AOT") -and $results.ContainsKey(".NET 10 AOT")) {
    $net8Size = $results[".NET 8 AOT"]
    $net10Size = $results[".NET 10 AOT"]
    $improvement = (($net8Size - $net10Size) / $net8Size) * 100
    Write-Host "🏆 .NET 10 AOT is $([math]::Round($improvement, 0))% smaller than .NET 8 AOT" -ForegroundColor Green
}

Write-Host ""
Write-Host "Results saved to: results\size-results.txt" -ForegroundColor Gray

# Save results to file
$resultsDir = "results"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

$output = @"
Binary Size Measurement Results
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

"@

foreach ($key in $results.Keys | Sort-Object) {
    $value = $results[$key]
    $output += "$key : $([math]::Round($value, 2)) MB`n"
}

$output | Out-File -FilePath "$resultsDir\size-results.txt" -Encoding UTF8
