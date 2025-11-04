# Feature 1: Extension Members

## Run It

```powershell
dotnet run
```

## The Problem

Tax calculation logic duplicated in `Product.CalculateTax()`, `Order.CalculateTax()`, and `Invoice.CalculateTax()`. Every time you find a tax calculation bug, you have to fix it in THREE places.

## The Solution

C# 14 Extension Members consolidate this into ONE place (`TaxExtensions.cs`). Now you have a single source of truth.

## Files

- **Before.cs**: Tax calculation methods in each class (duplication)
- **After.cs**: Tax calculation in extension methods (consolidated)
- **Program.cs**: Runs both approaches, shows identical output

## Key Insight

✓ Same behavior, cleaner code  
✓ Change logic once, all types benefit  
✓ Original classes stay small and focused  

## When to Use

Use extension members when you have logic that applies to multiple types but doesn't belong in any single type.
