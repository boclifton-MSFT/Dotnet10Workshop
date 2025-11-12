# Feature 2: Field-Backed Properties

## Run It

```powershell
dotnet run -f net10.0
```

## The Business Problem

Imagine you've shipped a pricing service at Meijer that handles product prices. It's been running for months, and customers are using it. Now you discover a critical issue:

- **The Issue**: Prices can be set to negative values or unrealistic amounts (e.g., $999,999.99 instead of $99.99)
- **The Risk**: This causes inventory mismatches, financial reports are inaccurate, and customer complaints spike
- **The Constraint**: You can't change the public API without breaking all existing code that depends on it

## The Old Approach (C# 13)

To add validation to properties in C# 13, you had to manually create backing fields:

```csharp
// Must manually declare backing field
private decimal _amount;

public decimal Amount 
{ 
    get => _amount;
    set 
    { 
        if (value < 0)
            throw new ArgumentException("Invalid price");
        _amount = value;
    }
}
```

**Problems with this approach**:
- ❌ **Boilerplate code**: Must manually declare `_amount` for every property needing logic
- ❌ **Naming conventions**: Need to manage naming (e.g., `_amount`, `m_amount`, `amount_`)
- ❌ **Potential bugs**: Can accidentally access `_amount` directly elsewhere, bypassing validation
- ❌ **Refactoring overhead**: Converting from auto-property to validated property requires adding backing field

## The C# 14 Solution: The `field` Keyword

C# 14 introduces the `field` contextual keyword that lets you access the compiler-generated backing field directly:

```csharp
// No manual backing field needed!
public decimal Amount 
{ 
    get => field;  // 'field' refers to compiler-generated backing field
    set 
    { 
        if (value < 0)
            throw new ArgumentException("Invalid price");
        field = value;  // Assign to compiler-generated backing field
    }
}
```

**Why this matters**:
- ✅ **No boilerplate**: Compiler generates the backing field automatically
- ✅ **Same API**: Existing code using `money.Amount = 50` still works
- ✅ **Validation added**: Invalid values are rejected immediately
- ✅ **Encapsulated**: `field` is only accessible within property accessors
- ✅ **Clean refactoring**: Easy to convert auto-properties to validated properties
- ✅ **Zero performance cost**: Compiles to identical IL as manual backing fields

## Key Features of the `field` Keyword

1. **Contextual keyword**: `field` only has special meaning inside property accessors (get/set/init)
2. **Compiler-generated**: The backing field is created automatically by the compiler
3. **Accessor-only access**: Cannot reference `field` from anywhere except inside the property
4. **Mix and match**: Can use `field` in one accessor and auto-implement the other

## Real-World Example: Meijer's Pricing Service

**Before** (C# 13 - manual backing field):
```csharp
private decimal _amount;
private string _currency = "";

public decimal Amount 
{ 
    get => _amount;
    set => _amount = value;  // No validation
}
```

**After** (C# 14 - field keyword with validation):
```csharp
// No manual backing fields needed!
public decimal Amount 
{ 
    get => field;
    set 
    { 
        if (value < 0)
            Console.WriteLine("⚠️ Warning: Negative amount!");
        field = value;
    }
}

public string Currency 
{ 
    get => field;
    set => field = value ?? "";  // Null-safe with default
}
```

This means:
- **Faster bug detection**: Issues caught at the property boundary
- **Less code to maintain**: No manual backing field declarations
- **Safer refactoring**: Validation can't be bypassed by accessing backing field
- **Better encapsulation**: Backing field is compiler-controlled

## When to Use the `field` Keyword

Use the `field` keyword when you need to:
- ✅ Add validation to properties without declaring backing fields
- ✅ Track changes to important business data  
- ✅ Maintain backward compatibility while improving safety
- ✅ Add logging or auditing without API changes
- ✅ Enforce business rules (e.g., "price must be positive")
- ✅ Refactor auto-properties to validated properties cleanly

## Comparison with Other Approaches

### Manual Backing Fields (C# 13 and earlier)

**You might say**: "We've been doing this for years:"

```csharp
private decimal _amount;

public decimal Amount 
{ 
    get => _amount;
    set 
    { 
        if (value < 0) throw new ArgumentException();
        _amount = value;
    }
}
```

**Response**: You're right! But C# 14's `field` keyword improves this:

**Old Way (C# 13)**: You had to **manually create** the backing field:
```csharp
private decimal _amount;  // ← You write this
public decimal Amount { get => _amount; set => _amount = value; }  // ← And this
```

**New Way (C# 14)**: The compiler **generates** the backing field automatically:
```csharp
public decimal Amount { get => field; set => field = value; }  // ← Compiler creates backing field
```

**Benefits**:
- ✅ Less boilerplate (no manual `_amount` declaration)
- ✅ Cleaner code (compiler handles the field)
- ✅ Better refactoring (change auto-property to validated property without adding fields)
- ✅ Safer (can't accidentally access backing field elsewhere)

### Constructor Validation

**You might say**: "We validate in the constructor:"

```csharp
public Money(decimal amount, string currency)
{
    if (amount < 0) throw new ArgumentException();
    Amount = amount;
}
```

**Response**: Constructor validation only protects **initial creation**, not **later modifications**:

```csharp
var money = new Money(50, "USD");  // ✓ Validated in constructor
money.Amount = -50;                 // ✗ No validation! Bug introduced
```

**Best Practice**: Use **both** constructor validation and field-backed properties to protect all mutations.

### Immutable Records

**You might say**: "We use immutable records:"

```csharp
public record Money(decimal Amount, string Currency);
```

**Response**: Immutability is excellent for value objects, but not always practical:

**When Immutability Works**:
- ✅ Value objects (Money, Address, DateRange)
- ✅ DTOs and API responses

**When Mutability Is Needed**:
- ❌ EF Core entities (navigation properties, change tracking)
- ❌ Long-lived domain models (Cart, Order)
- ❌ Objects passed to legacy APIs expecting setters

**Field-backed properties let you be selectively mutable**:
```csharp
public class CartItem
{
    public string SKU { get; init; }  // Immutable
    public int Quantity 
    { 
        get => field; 
        set 
        { 
            if (value <= 0) throw new ArgumentException();
            field = value;
        }
    }  // Mutable with validation
}
```

## Key Insight

The C# 14 `field` keyword brings concise, safe, and expressive field-backed properties—blending the simplicity of auto-properties with the power of custom validation logic, without manual backing fields cluttering your codebase.

**Best of all**: You can **add it later** without breaking existing code. That's the real power.
