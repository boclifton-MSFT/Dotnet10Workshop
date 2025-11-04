# Testing the PricingService

This module provides three build variants to test performance characteristics. You can test any of them using the methods below.

## Quick Start

### For .NET 10 (with built-in OpenAPI)

1. Start the service:
   ```powershell
   cd artifacts/pub10-fx
   .\PricingService.exe
   ```

2. **Option A: Use Swagger UI** - Open your browser to:
   ```
   http://localhost:5000/openapi/v1.json
   ```
   
   (Note: You can view the raw JSON schema here. For interactive Swagger UI, the workshop templates from Microsoft include Scalar UI which is also available.)

3. **Option B: Use PowerShell Test Script**:
   ```powershell
   .\test-pricing.ps1
   ```

### For .NET 8 (without built-in OpenAPI)

1. Start the service:
   ```powershell
   cd artifacts/pub8-fx
   .\PricingService.exe
   ```

2. **Use PowerShell Test Script**:
   ```powershell
   ..\..\..\modules\module1-runtime\test-pricing.ps1
   ```

### For Native AOT Variants

The AOT executables are located in:
- `.NET 8 AOT`: `artifacts/pub8-aot/PricingService.exe`
- `.NET 10 AOT`: `artifacts/pub10-aot/PricingService.exe`

Use the same test script or curl commands. Note that AOT builds are not designed to be stopped gracefully - just terminate them with Ctrl+C.

## Test Example

```powershell
# Default parameters
.\test-pricing.ps1

# Custom parameters
.\test-pricing.ps1 -sku "GADGET-500" -quantity 25 -customerId "CUST-999"
```

## Using curl

```bash
# Test with default values
curl -X POST http://localhost:5000/api/pricing/calculate \
  -H "Content-Type: application/json" \
  -d '{"sku":"WIDGET-001","quantity":10,"customerId":"CUST-123"}'

# Check health
curl http://localhost:5000/health
```

## Performance Testing

Run the measurement scripts:

```powershell
# Cold-start performance
.\measure-coldstart.ps1

# Binary sizes
.\measure-size.ps1

# Memory usage
.\measure-memory.ps1
```

## Key Design Decisions

### Why different setups for .NET 8 vs .NET 10?

This workshop demonstrates **built-in improvements** in .NET 10:

- **.NET 10** includes `Microsoft.AspNetCore.OpenApi` built-in to the SDK, enabling automatic OpenAPI/Swagger support
- **.NET 8** requires external packages for OpenAPI, so the workshop keeps it simple with direct API testing

This is an actual upgrade benefit - less dependencies, smaller surface area!

### Why Native AOT?

Native AOT compilation demonstrates the **startup performance** and **binary size** improvements in .NET 10:

- Faster cold-starts (important for serverless/containers)
- Smaller memory footprint
- See measurement scripts for quantified improvements
