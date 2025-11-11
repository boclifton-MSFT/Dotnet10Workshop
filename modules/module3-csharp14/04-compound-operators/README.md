# Feature 4: User-Defined Compound Assignment Operators

## Run It

```powershell
dotnet run -f net10.0
```

## The Business Problem

Meijer's checkout system processes millions of price calculations daily. Traditional operator overloading creates new objects for every operation, causing performance issues:

```csharp
public class Price
{
    public decimal Amount { get; set; }
    
    // Traditional binary operator - creates new Price instance
    public static Price operator -(Price price, Discount discount)
    {
        return new Price { Amount = price.Amount - (price.Amount * discount.Percentage) };
    }
}

// Usage: Creates 3 new Price objects!
var price = new Price { Amount = 100 };
price = price - discount1;  // Allocates new Price
price = price - discount2;  // Allocates new Price
price = price * taxRate;    // Allocates new Price
```

**Issues**:
- ❌ **Memory Allocations**: Creates new objects even when mutation would be fine
- ❌ **GC Pressure**: Frequent allocations trigger garbage collection
- ❌ **Performance Cost**: Object creation overhead in hot paths
- ❌ **Not Natural**: `price = price - discount` is verbose compared to `price -= discount`

For high-volume scenarios (thousands of calculations per second), these allocations add up:
- More memory usage
- More CPU time in garbage collector
- Slower checkout performance

## The Old Approach (C# 13 and Earlier)

In C# 13, when you write `price -= discount`, the compiler expands it to:

```csharp
price = price - discount;  // Always calls the binary operator
```

This means:
1. Call `operator -(Price, Discount)` to create a new Price
2. Assign the new Price back to `price`
3. Old Price object becomes garbage

**You couldn't define compound assignment operators directly.**

Even if you wanted in-place mutation, you had to work around it:

```csharp
public class Price
{
    public decimal Amount { get; set; }
    
    // Can only define binary operator
    public static Price operator -(Price price, Discount discount)
    {
        // Option 1: Return new instance (allocates)
        return new Price { Amount = price.Amount - (price.Amount * discount.Percentage) };
        
        // Option 2: Mutate and return (confusing!)
        price.Amount -= price.Amount * discount.Percentage;
        return price;  // Breaks immutability expectations
    }
}
```

❌ No way to define `operator -=` directly
❌ Always creates new objects or breaks immutability semantics

## The C# 14 Solution: User-Defined Compound Assignment Operators

C# 14 introduces a revolutionary feature: you can now define compound assignment operators (`+=`, `-=`, `*=`, `/=`) as **instance methods** that mutate objects in place:

```csharp
public class Price
{
    public decimal Amount { get; set; }
    
    // C# 14: Define compound assignment operator directly!
    public void operator -=(Discount discount)
    {
        Amount -= Amount * discount.Percentage;  // Mutates in place
    }
    
    public void operator *=(TaxRate tax)
    {
        Amount *= 1 + tax.Rate;  // Mutates in place
    }
}

// Usage: Natural syntax, no allocations!
var price = new Price { Amount = 100 };
price -= discount;  // Mutates existing object
price *= taxRate;   // Mutates existing object
```

**Why this matters**:
- ✅ **Zero Allocations**: Mutates in place, no new objects created
- ✅ **Natural Syntax**: `price -= discount` reads like math
- ✅ **Better Performance**: Eliminates object creation overhead
- ✅ **Explicit Intent**: Clearly shows mutation is intended

## Key Differences from Traditional Operators

| Feature | Traditional (C# 13) | Compound Assignment (C# 14) |
|---------|--------------------|-----------------------------|
| Syntax | `public static Price operator -` | `public void operator -=` |
| Type | Static method | Instance method |
| Returns | New instance | void (mutates this) |
| Usage | `price = price - discount` | `price -= discount` |
| Allocations | Creates new object | Zero allocations |

## Real-World Example: Meijer's Checkout Flow

**Before** (C# 13 - creates 3 objects):
```csharp
var subtotal = new Price { Amount = 149.99m };
var memberDiscount = new Discount { Percentage = 0.10m };
var promoDiscount = new Discount { Percentage = 0.05m };
var taxRate = new TaxRate { Rate = 0.06m };

// Each operation allocates a new Price object
subtotal = subtotal - memberDiscount;  // Allocation #1
subtotal = subtotal - promoDiscount;   // Allocation #2
subtotal = subtotal * taxRate;         // Allocation #3
```

**After** (C# 14 - zero allocations):
```csharp
var subtotal = new Price { Amount = 149.99m };
var memberDiscount = new Discount { Percentage = 0.10m };
var promoDiscount = new Discount { Percentage = 0.05m };
var taxRate = new TaxRate { Rate = 0.06m };

// Each operation mutates in place (no allocations!)
subtotal -= memberDiscount;  // Mutates
subtotal -= promoDiscount;   // Mutates
subtotal *= taxRate;         // Mutates
```

## Performance Benefits

For a busy checkout system processing 10,000 transactions per hour:

**Traditional Approach:**
- 30,000 Price objects created per hour (3 per transaction)
- Increased GC pressure
- CPU cycles spent on allocation and collection

**C# 14 Compound Operators:**
- 0 additional Price objects created
- Minimal GC pressure
- CPU focused on business logic, not memory management

**Estimated Savings:**
- 30% reduction in GC time for price calculation hot paths
- Lower memory footprint
- Faster checkout processing

---

## Common Questions

### "When should I use compound assignment operators vs. traditional operators?"

**Use Compound Assignment Operators (`+=`, `-=`, `*=`) when:**
- ✅ Mutation is acceptable or desired
- ✅ You want to avoid unnecessary object allocations
- ✅ Working with mutable reference types or large value types
- ✅ Performance is critical (hot paths, high-volume operations)

**Use Traditional Binary Operators (`+`, `-`, `*`) when:**
- ✅ Immutability is important
- ✅ Working with small value types (records, readonly structs)
- ✅ You need functional-style programming
- ✅ Thread safety is a concern

**Example - Both in One Type:**
```csharp
public class Price
{
    public decimal Amount { get; set; }
    
    // Traditional binary operator (immutable style)
    public static Price operator -(Price price, Discount discount)
    {
        return new Price { Amount = price.Amount - (price.Amount * discount.Percentage) };
    }
    
    // C# 14 compound assignment operator (mutable style)
    public void operator -=(Discount discount)
    {
        Amount -= Amount * discount.Percentage;
    }
}

// Use traditional operator when you need immutability
var original = new Price { Amount = 100 };
var discounted = original - discount;  // original unchanged

// Use compound operator when mutation is fine
var price = new Price { Amount = 100 };
price -= discount;  // price modified in place
```

### "Can I use both operators in the same class?"

Yes! You can provide both traditional binary operators (for immutability) and compound assignment operators (for performance). The compiler will use the appropriate one based on context.

### "What about thread safety?"

Compound assignment operators mutate state, so they're not thread-safe by default. For multi-threaded scenarios:
- Use traditional immutable operators
- Or add locking around compound operator usage
- Or use immutable value types (records, readonly structs)

---

## Summary: Why C# 14 Compound Assignment Operators Matter

**What C# 14 compound assignment operators provide:**
- ✅ **Zero Allocations**: Mutate objects in place instead of creating new ones
- ✅ **Natural Syntax**: Write `price -= discount` instead of `price = price - discount`
- ✅ **Better Performance**: Eliminate object creation overhead in hot paths
- ✅ **Explicit Control**: Choose between immutable (binary operators) and mutable (compound operators) styles
- ✅ **Instance Methods**: Defined as `public void operator -=` not static methods

**Best Practices:**
- ✅ Use compound operators for mutable types in performance-critical code
- ✅ Keep traditional binary operators for immutable scenarios
- ✅ Document which operators mutate and which create new instances
- ✅ Consider thread safety implications of mutation
- ❌ Don't surprise users - if type is immutable, don't add compound operators

**Perfect for:**
- Financial calculations (prices, discounts, taxes) in high-volume systems
- Large data structures (tensors, matrices, collections)
- Game development (vector math, transform operations)
- Any hot path where object allocation is a bottleneck
