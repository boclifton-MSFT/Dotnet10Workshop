# Module 1: Runtime Performance - Setup Complete ✅

## Summary

All 4 build variants are now **functional and ready for testing**:

| Variant | Status | Notes |
|---------|--------|-------|
| `.NET 8 Framework-Dependent` | ✅ Working | Includes simple HTML test endpoint at `/test` |
| `.NET 8 Native AOT` | ✅ Working | Pure native executable, no .NET runtime required |
| `.NET 10 Framework-Dependent` | ✅ Working | **Includes built-in OpenAPI/Swagger support** |
| `.NET 10 Native AOT` | ✅ Working | Pure native executable with OpenAPI schema |

## Key Features Implemented

### 1. **Conditional Compilation** (`#if NET10_0_OR_GREATER`)
- `.NET 10`: Uses built-in `Microsoft.AspNetCore.OpenApi` for automatic Swagger/OpenAPI support
- `.NET 8`: Keeps it simple with no external dependencies (demonstrating simplification as an upgrade benefit)

### 2. **Native AOT Support** 
- Source-generated `JsonSerializerContext` with `[JsonSourceGenerationOptions]` and `[JsonSerializable]` attributes
- **No reflection** - everything resolved at compile time
- All serializable types registered: `HealthResponse`, `PricingRequest`, `PricingResponse`

### 3. **Easy Testing for Workshop Participants**
- **PowerShell test script**: `test-pricing.ps1` (works for all 4 variants)
- **curl compatible**: All endpoints accept standard HTTP requests
- **.NET 10 Swagger UI**: Built-in OpenAPI schema at `/openapi/v1.json`

## How It Solves Your Problems

### Problem #1: "Getting stuck when running exe in terminal"
**Solution**: Test script runs the exe in a non-blocking way and validates responses

### Problem #2: "Need easy way for attendees to test POST endpoint"  
**Solution**: 
- For `.NET 10`: Built-in Swagger/OpenAPI (no extra dependencies!)
- For `.NET 8`: Simple PowerShell/curl testing (same API works for both)
- Both are "workshop-friendly" - no Postman installation needed

### Problem #3: "What about .NET 8 vs .NET 10 differences?"
**Solution**: Conditional compilation shows actual upgrade benefit:
```csharp
#if NET10_0_OR_GREATER
    builder.Services.AddOpenApi();  // Built-in!
#endif
```

## Testing Commands

### Quick Start
```powershell
# Test .NET 10 with OpenAPI support
cd artifacts/pub10-fx
.\PricingService.exe

# In another terminal
..\..\..\modules\module1-runtime\test-pricing.ps1
```

### All Variants
```powershell
# Test script auto-discovers running service
.\test-pricing.ps1                                    # Uses localhost:5000
.\test-pricing.ps1 -hostname 127.0.0.1 -port 5001  # Custom host/port
```

### Check Endpoints

```powershell
# Health check
curl http://localhost:5000/health

# Pricing request
curl -X POST http://localhost:5000/api/pricing/calculate `
  -H "Content-Type: application/json" `
  -d '{"sku":"WIDGET-001","quantity":10,"customerId":"CUST-123"}'

# .NET 10 OpenAPI schema (view in browser or json viewer)
curl http://localhost:5000/openapi/v1.json
```

## Next Steps for Workshop

1. **Run measurement scripts**:
   ```powershell
   .\measure-coldstart.ps1  # Compare startup times
   .\measure-size.ps1       # Compare binary sizes
   .\measure-memory.ps1     # Compare memory usage
   ```

2. **Compare results** across all 4 variants to show:
   - `.NET 10 AOT` faster cold-start than `.NET 8 AOT`
   - `.NET 10 AOT` smaller binary than `.NET 8 AOT` (with size optimization)
   - `.NET 10` built-in features reducing dependencies

3. **Live Demo**: Start service, run test script, show results

## Technical Details

### JsonSerializerContext Configuration
```csharp
// Configure TypeInfoResolver globally for all JSON operations
options.SerializerOptions.TypeInfoResolver = PricingSerializerContext.Default;

// All types explicitly registered for AOT
[JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
[JsonSerializable(typeof(HealthResponse))]
[JsonSerializable(typeof(PricingRequest))]
[JsonSerializable(typeof(PricingResponse))]
internal partial class PricingSerializerContext : JsonSerializerContext { }
```

### Why Source Generation Matters for AOT
- **No reflection** at runtime (impossible in AOT)
- **Compiler generates** serialization code during build
- **Zero runtime cost** for serialization lookups
- **Same API** for both Framework-Dependent and AOT builds

### Build Configuration
- Multi-targeting: `TargetFrameworks=net8.0;net10.0`
- AOT optimization: `OptimizationPreference=Size`
- Conditional package: OpenAPI only for net10.0

## Files Modified

1. **PricingService.csproj**
   - Added `Microsoft.AspNetCore.OpenApi` (conditional for net10.0 only)
   - Multi-targeting configuration

2. **Program.cs**
   - Added conditional compilation for OpenAPI support
   - Implemented `PricingSerializerContext` with source generation
   - Created `HealthResponse` record for serialization
   - Configured `TypeInfoResolver` in HttpJsonOptions

3. **New Files**
   - `test-pricing.ps1` - Workshop participant testing script
   - `TESTING.md` - Testing documentation

## Workshop Talking Points

1. **"Built-in improvements"**: .NET 10 has OpenAPI built-in - no NuGet dependency!
2. **"Same code, different capabilities"**: Conditional compilation shows version-specific features
3. **"AOT everywhere"**: Both versions support Native AOT - important for cloud scenarios
4. **"Performance matters"**: Source generation = fast, predictable JSON serialization
5. **"Workshop-friendly"**: Simple PowerShell scripts, no external tools needed

---

**Status**: ✅ Module 1 fully functional. Ready for measurement and comparison!
