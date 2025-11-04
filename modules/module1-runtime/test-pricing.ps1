# Simple pricing service test script for workshop attendees
# Usage: .\test-pricing.ps1 [-sku WIDGET-001] [-quantity 10] [-customerId CUST-123] [-serverName localhost] [-port 5000]

param(
    [string]$sku = "WIDGET-001",
    [int]$quantity = 10,
    [string]$customerId = "CUST-123",
    [string]$serverName = "localhost",
    [int]$port = 5000
)

$url = "http://$serverName`:$port/api/pricing/calculate"

Write-Host "Testing PricingService at $url" -ForegroundColor Cyan
Write-Host "  SKU: $sku" -ForegroundColor Gray
Write-Host "  Quantity: $quantity" -ForegroundColor Gray
Write-Host "  Customer ID: $customerId" -ForegroundColor Gray
Write-Host ""

$request = @{
    sku = $sku
    quantity = $quantity
    customerId = $customerId
} | ConvertTo-Json

try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $request -ContentType "application/json" -ErrorAction Stop
    $stopwatch.Stop()
    
    Write-Host "✅ Success! Response time: $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pricing Details:" -ForegroundColor Cyan
    Write-Host "  Base Price:   `$$($response.basePrice)" -ForegroundColor White
    Write-Host "  Quantity:     $($response.quantity)" -ForegroundColor White
    Write-Host "  Discount:     `$$($response.discount)" -ForegroundColor Yellow
    Write-Host "  Total Price:  `$$($response.total)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
