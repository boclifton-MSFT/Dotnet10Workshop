# Measure cold-start time for all 4 variants
# Averages 5 runs per variant

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cold-Start Time Measurement" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define test configurations
$variants = @(
    @{
        Name = ".NET 8 FX"
        Executable = "..\..\artifacts\pub8-fx\PricingService.exe"
        Port = 5000
    },
    @{
        Name = ".NET 8 AOT"
        Executable = "..\..\artifacts\pub8-aot\PricingService.exe"
        Port = 5001
    },
    @{
        Name = ".NET 10 FX"
        Executable = "..\..\artifacts\pub10-fx\PricingService.exe"
        Port = 5002
    },
    @{
        Name = ".NET 10 AOT"
        Executable = "..\..\artifacts\pub10-aot\PricingService.exe"
        Port = 5003
    }
)

$iterations = 5
$results = @{}

foreach ($variant in $variants) {
    Write-Host "Testing: $($variant.Name)" -ForegroundColor Yellow
    
    if (-not (Test-Path $variant.Executable)) {
        Write-Host "  ⚠️  Executable not found: $($variant.Executable)" -ForegroundColor Red
        Write-Host "  Run .\build-all.ps1 first or use pre-built artifacts" -ForegroundColor Red
        continue
    }
    
    $times = @()
    
    for ($i = 1; $i -le $iterations; $i++) {
        Write-Host "  Run $i/$iterations..." -ForegroundColor Gray
        
        # Set environment variable for port
        $env:ASPNETCORE_URLS = "http://localhost:$($variant.Port)"
        
        # Start process and measure startup time
        $startTime = Get-Date
        $process = Start-Process -FilePath $variant.Executable `
            -WindowStyle Hidden `
            -PassThru
        
        # Wait for health endpoint to respond
        $healthUrl = "http://localhost:$($variant.Port)/health"
        $timeout = 30 # seconds
        $elapsed = 0
        $ready = $false
        
        while ($elapsed -lt $timeout) {
            Start-Sleep -Milliseconds 100
            try {
                $response = Invoke-WebRequest -Uri $healthUrl -TimeoutSec 1 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    $ready = $true
                    break
                }
            }
            catch {
                # Service not ready yet
            }
            $elapsed += 0.1
        }
        
        $endTime = Get-Date
        
        if ($ready) {
            $duration = ($endTime - $startTime).TotalMilliseconds
            $times += $duration
            Write-Host "    ✅ Started in $([math]::Round($duration, 0)) ms" -ForegroundColor Green
        }
        else {
            Write-Host "    ❌ Timeout after $timeout seconds" -ForegroundColor Red
        }
        
        # Graceful shutdown
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500 # Allow port to be released
    }
    
    if ($times.Count -gt 0) {
        $avg = ($times | Measure-Object -Average).Average
        $results[$variant.Name] = $avg
        Write-Host "  Average: $([math]::Round($avg, 0)) ms" -ForegroundColor Cyan
    }
    
    Write-Host ""
}

# Display summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cold-Start Time Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($key in $results.Keys | Sort-Object) {
    $value = $results[$key]
    Write-Host "$key : $([math]::Round($value, 0)) ms" -ForegroundColor White
}

Write-Host ""

# Calculate improvements
if ($results.ContainsKey(".NET 8 FX") -and $results.ContainsKey(".NET 10 AOT")) {
    $baseline = $results[".NET 8 FX"]
    $fastest = $results[".NET 10 AOT"]
    $improvement = (($baseline - $fastest) / $baseline) * 100
    Write-Host "🏆 .NET 10 AOT is $([math]::Round($improvement, 0))% faster than .NET 8 FX" -ForegroundColor Green
}

Write-Host ""
Write-Host "Results saved to: results\coldstart-results.txt" -ForegroundColor Gray

# Save results to file
$resultsDir = "results"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

$output = @"
Cold-Start Time Measurement Results
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

"@

foreach ($key in $results.Keys | Sort-Object) {
    $value = $results[$key]
    $output += "$key : $([math]::Round($value, 0)) ms`n"
}

$output | Out-File -FilePath "$resultsDir\coldstart-results.txt" -Encoding UTF8
