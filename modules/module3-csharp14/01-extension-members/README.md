# Module 3.1: C# 14 Extension Members

## Overview

Learn how C# 14's new `extension` keyword revolutionizes how we extend types we don't own. This exercise demonstrates the evolution from traditional extension methods to the new extension members syntax.

## Run It

```powershell
dotnet run
```

## The Problem

Tax calculation logic is duplicated in `ProductBefore.CalculateTax()` and `OrderBefore.CalculateTax()`. Every time you find a tax calculation bug, you have to fix it in **multiple places**—leading to:
- **Code duplication**: Same logic repeated across classes
- **Maintenance burden**: Update logic in N places instead of 1
- **Error-prone**: Easy to miss updating one location

## Traditional Solution (C# 13 and earlier)

Before C# 14, you could solve this with extension methods using `this` parameter:

```csharp
static class TaxExtensions
{
    public static decimal CalculateTax(this IProduct p, decimal taxRate = 0.085m)
        => p.Price * taxRate;

    public static decimal CalculateTax(this IOrder o, decimal taxRate = 0.085m)
        => o.Subtotal * taxRate;
}
```

This consolidated the logic, but the syntax was verbose with the `this` keyword required.

## Modern Solution (C# 14)

C# 14 introduces the `extension` keyword with a cleaner, block-based syntax:

```csharp
static class TaxExtensions
{
    // Extension members for IProduct
    extension(IProduct product)
    {
        public decimal CalculateTax(decimal taxRate = 0.085m)
            => product.Price * taxRate;
    }

    // Extension members for IOrder
    extension(IOrder order)
    {
        public decimal CalculateTax(decimal taxRate = 0.085m)
            => order.Subtotal * taxRate;
    }
}
```

### Key Advantages

✓ **Cleaner Syntax**: No more `this` parameter—the receiver is declared in the `extension()` block  
✓ **Better Organization**: Extension members grouped by type in dedicated blocks  
✓ **Enhanced Capabilities**: Supports extension properties and indexers (not just methods)  
✓ **Single Source of Truth**: Change logic once, all types benefit automatically  
✓ **Clean Classes**: Original classes stay small and focused on their core responsibilities  

## Files in This Exercise

- **Program.cs**: Complete demonstration comparing both approaches
  - `ProductBefore` / `OrderBefore`: Traditional approach with duplicated methods
  - `ProductAfter` / `OrderAfter`: Modern approach using C# 14 extension members
  - `TaxExtensions`: The new extension members syntax in action

## How Extension Members Work

### Syntax

```csharp
static class MyExtensions
{
    extension(TypeName receiverName)
    {
        // Extension methods
        public ReturnType MethodName(parameters) => receiverName.DoSomething();
        
        // Extension properties (NEW in C# 14!)
        public PropertyType PropertyName => receiverName.Value;
        
        // Extension indexers (NEW in C# 14!)
        public ItemType this[int index] => receiverName.GetItem(index);
    }
}
```

### Usage

Extension members are called just like regular members:

```csharp
var product = new ProductAfter { Price = 10.00m };
decimal tax = product.CalculateTax();        // Extension method
decimal taxWithRate = product.CalculateTax(0.10m); // With custom rate
```

## When to Use Extension Members

✅ **Use extension members when**:
- Logic applies to multiple types but doesn't belong in any single type
- You want to add functionality to types you don't own (libraries, frameworks)
- You need extension properties or indexers (impossible with traditional methods)
- You want cleaner, more organized code with grouped extensions by type

❌ **Don't use extension members when**:
- The logic truly belongs as a core part of the type
- You have full control over the type and can modify it directly
- The extension requires mutable state or backing fields

## Deep Dive: What Changed?

### Traditional Extension Methods (C# 3.0 - C# 13)
```csharp
public static decimal CalculateTax(this IProduct p, decimal taxRate)
    => p.Price * taxRate;
```
- Requires `this` keyword on first parameter
- Only supports methods (no properties or indexers)
- All extensions flat in the class

### C# 14 Extension Members
```csharp
extension(IProduct product)
{
    public decimal CalculateTax(decimal taxRate)
        => product.Price * taxRate;
}
```
- Uses `extension()` block syntax
- No `this` keyword needed—receiver declared once
- Supports methods, properties, and indexers
- Extensions grouped by type for better organization

## Learning Objectives

After completing this exercise, you should understand:

1. **The Problem**: Why code duplication is costly and error-prone
2. **Evolution**: How extension methods evolved from C# 3.0 to C# 14
3. **New Syntax**: How to declare extension members with the `extension` keyword
4. **Benefits**: Why the new syntax is cleaner and more capable
5. **Practical Use**: When to use extension members in real-world scenarios

## Next Steps

- Try adding an extension property to calculate tax as a percentage string
- Experiment with extension indexers for collection-like types
- Compare the compiled IL to see that both approaches produce similar code
- Explore other C# 14 features in the adjacent modules

## Additional Resources

- [Microsoft Learn: Extension Members Tutorial](https://learn.microsoft.com/en-us/dotnet/csharp/whats-new/tutorials/extension-members)
- [Microsoft Docs: Extension Methods](https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/extension-methods)
- [C# Language Specification: Extension Members](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/proposals/csharp-14.0/extensions)
