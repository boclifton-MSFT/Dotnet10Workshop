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

Without proper validation hooks, you had limited options:

```csharp
// Option 1: Add validation, but breaking change for all callers
public decimal Amount 
{ 
    get; 
    set; 
}  // No validation - bugs slip through
```

```csharp
// Option 2: Create a new validated property
public decimal ValidatedAmount 
{ 
    get; 
    set; 
}  // But now you have two properties - confusing
```

```csharp
// Option 3: Use a method instead of a property
public void SetAmount(decimal value) { /* validate */ }
// But this breaks existing code using property syntax
```

None of these solve the problem cleanly.

## The C# 14 Solution: Field-Backed Properties

Field-backed properties let you add validation **without breaking the public API**:

```csharp
private decimal _amount;

public decimal Amount 
{ 
    get => _amount;
    set 
    { 
        if (value < 0 || value > 1000000)
            throw new ArgumentException("Invalid price");
        _amount = value;
    }
}
```

**Why this matters**:
- ✅ **Same API**: Existing code using `money.Amount = 50` still works
- ✅ **Validation Added**: New invalid values are rejected immediately
- ✅ **Backward Compatible**: No breaking changes for customers
- ✅ **Observable**: You can log, monitor, or audit every price change
- ✅ **Zero Performance Cost**: Compiles to identical IL as before

## Real-World Example: Meijer's Pricing Service

**Before** (C# 13 - no validation):
```
Customer sets price: $50.00 ✓ Works
Customer sets price: -$50.00 ✗ Accepted! Bug not caught until later
```

**After** (C# 14 - field-backed property with validation):
```
Customer sets price: $50.00 ✓ Works
Customer sets price: -$50.00 ✗ Rejected immediately with clear error
```

This means:
- **Faster Bug Detection**: Issues caught at the boundary, not in reports
- **Reduced Support Tickets**: Validation errors are immediate and clear
- **Better Data Quality**: No invalid data enters the system
- **Zero Migration Cost**: Existing code keeps working

## Why This Matters for Customers

1. **Safety Without Breaking Changes**: Add guardrails to your APIs without requiring all consumers to update
2. **Improved Data Quality**: Invalid data caught at the source, not discovered in data exports
3. **Better Troubleshooting**: When customers report issues, validation errors point directly to the problem
4. **Auditing Capability**: You can add logging or metrics to the setter:
   ```csharp
   set 
   { 
       if (value != _amount)
           _logger.LogPriceChange(_amount, value);  // Track all price changes
       _amount = value;
   }
   ```

## When to Use Field-Backed Properties

Use this pattern when you need to:
- ✅ Add validation to an existing property
- ✅ Track changes to important business data
- ✅ Maintain backward compatibility while improving safety
- ✅ Add logging or auditing without API changes
- ✅ Enforce business rules (e.g., "price must be positive")

## Key Insight

Field-backed properties are C# 14's way of saying: **"Fix bugs in production without breaking your customers' code."** It's a safety net that catches problems early while keeping backward compatibility.

---

## "But We Already Do This!" - Addressing Common Pushback

### Pushback #1: "We already have private fields with getters/setters"

**You might say**: "We've been doing this for years in C# 13:"

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

**Response**: You're right! But here's what C# 14 improves:

**Old Way (C# 13)**: You had to **manually create** the backing field:
```csharp
private decimal _amount;  // ← You write this
public decimal Amount { get => _amount; set => _amount = value; }  // ← And this
```

**New Way (C# 14)**: The compiler **generates** the backing field automatically:
```csharp
public decimal Amount { get; set; }  // ← Compiler creates _amount for you
// Add validation later by switching to: get => field; set { if (valid) field = value; }
```

**Why this matters**:
- ✅ Less boilerplate (no manual `_amount` declaration)
- ✅ Cleaner code (compiler handles the field)
- ✅ Better refactoring (change auto-property to validated property without renaming fields)
- ✅ Consistent naming (compiler always uses `field` keyword)

### Pushback #2: "We use NotifyPropertyChanged for validation"

**You might say**: "We implement `INotifyPropertyChanged` in our domain models:"

```csharp
public class Money : INotifyPropertyChanged
{
    private decimal _amount;
    public decimal Amount 
    { 
        get => _amount;
        set 
        { 
            if (_amount != value)
            {
                _amount = value;
                OnPropertyChanged(nameof(Amount));
            }
        }
    }
    
    public event PropertyChangedEventHandler PropertyChanged;
    protected void OnPropertyChanged(string name) => 
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
}
```

**Response**: That works, but it's heavyweight for server-side code:

**Problems with INotifyPropertyChanged**:
- ❌ Designed for UI frameworks (WPF, MAUI)
- ❌ Event overhead on every property change
- ❌ Requires 15+ lines of boilerplate per class
- ❌ Not suitable for high-throughput APIs (too many allocations)

**Field-backed properties are simpler**:
```csharp
public class Money
{
    public decimal Amount 
    { 
        get; 
        set 
        { 
            if (value < 0) throw new ArgumentException();
            field = value;  // ← Direct field access, no events
        }
    }
}
```

**When to use each**:
- **INotifyPropertyChanged**: UI-bound models (desktop/mobile apps)
- **Field-backed properties**: Server APIs, domain models, high-throughput services

### Pushback #3: "We use FluentValidation or DataAnnotations"

**You might say**: "We validate using attributes or libraries:"

```csharp
public class Money
{
    [Range(0.01, 1000000)]
    public decimal Amount { get; set; }
}

// Validation happens later:
var validator = new MoneyValidator();
var result = validator.Validate(money);
if (!result.IsValid) { /* handle errors */ }
```

**Response**: External validation is great for complex scenarios, but it's **async** validation:

**FluentValidation/DataAnnotations (Async Validation)**:
```
1. Create object: var money = new Money();
2. Set invalid value: money.Amount = -50;  ← Object is now corrupted
3. Run validation: validator.Validate(money);  ← Discover issue later
4. Handle error: if (!result.IsValid) { ... }
```

**Field-Backed Properties (Sync Validation)**:
```
1. Create object: var money = new Money();
2. Set invalid value: money.Amount = -50;  ← Exception thrown immediately
3. No validation needed: Object never enters invalid state
```

**When to use each**:
- **FluentValidation/DataAnnotations**: 
  - Cross-field validation (e.g., "EndDate > StartDate")
  - Complex business rules
  - User input from forms
  - Validation messages for UI
- **Field-Backed Properties**:
  - Single-field validation (e.g., "price > 0")
  - Invariants that must always hold
  - Performance-critical paths
  - Domain model integrity

**Best Practice**: Use **both**:
```csharp
public class Money
{
    // Field-backed property: Catch obvious errors immediately
    public decimal Amount 
    { 
        get; 
        set 
        { 
            if (value < 0) throw new ArgumentException("Amount cannot be negative");
            field = value;
        }
    }
    
    public string Currency { get; set; }
}

// FluentValidation: Complex cross-field rules
public class MoneyValidator : AbstractValidator<Money>
{
    public MoneyValidator()
    {
        RuleFor(x => x.Currency).Must(BeValidCurrency);
        // Amount validation already handled by property setter
    }
}
```

### Pushback #4: "We use constructor validation"

**You might say**: "We validate in the constructor:"

```csharp
public class Money
{
    public decimal Amount { get; set; }
    public string Currency { get; set; }
    
    public Money(decimal amount, string currency)
    {
        if (amount < 0) throw new ArgumentException();
        Amount = amount;
        Currency = currency;
    }
}
```

**Response**: Constructor validation only protects **initial creation**, not **later modifications**:

**The Problem**:
```csharp
var money = new Money(50, "USD");  // ✓ Validated in constructor
money.Amount = -50;                 // ✗ No validation! Bug introduced
```

**The Solution**: Field-backed properties protect **every mutation**:
```csharp
public class Money
{
    public decimal Amount 
    { 
        get; 
        set 
        { 
            if (value < 0) throw new ArgumentException();
            field = value;
        }
    }
    
    public Money(decimal amount, string currency)
    {
        Amount = amount;  // ← Validation runs here too
        Currency = currency;
    }
}

var money = new Money(50, "USD");   // ✓ Validated
money.Amount = 100;                 // ✓ Validated
money.Amount = -50;                 // ✗ Exception thrown
```

**Best Practice**: Use **both**:
- Constructor validation: Business rules at object creation
- Property validation: Invariants that must always hold

### Pushback #5: "We use immutable records"

**You might say**: "We use records with init-only properties:"

```csharp
public record Money(decimal Amount, string Currency);

// Usage:
var money = new Money(50, "USD");
// Can't change Amount after creation - validation only needed once
```

**Response**: Immutability is excellent, but not always practical:

**When Immutability Works**:
- ✅ Value objects (Money, Address, DateRange)
- ✅ DTOs and API responses
- ✅ Configuration objects

**When Mutability Is Needed**:
- ❌ EF Core entities (navigation properties, change tracking)
- ❌ Long-lived domain models (Cart, Order)
- ❌ Objects passed to legacy APIs expecting setters

**Real Example from Meijer**:
```csharp
// This looks great in theory:
public record CartItem(string SKU, int Quantity, decimal Price);

// But breaks in practice:
var cart = new Cart();
cart.Items.Add(new CartItem("SKU123", 2, 10.00m));

// Customer wants to update quantity:
var item = cart.Items.First();
// Can't do: item.Quantity = 5;  ← Immutable!
// Must do: cart.Items.Remove(item); cart.Items.Add(item with { Quantity = 5 });
// ← This breaks EF Core change tracking and triggers unnecessary database queries
```

**Field-backed properties let you be selectively mutable**:
```csharp
public class CartItem
{
    public string SKU { get; init; }  // Immutable
    public int Quantity 
    { 
        get; 
        set 
        { 
            if (value <= 0) throw new ArgumentException();
            field = value;
        }
    }  // Mutable with validation
    public decimal Price { get; init; }  // Immutable
}

// Now updates work naturally:
item.Quantity = 5;  // ✓ Validated and EF Core tracks the change
```

---

## Summary: Why C# 14 Field-Backed Properties Matter

**What enterprises do today**:
1. Manual backing fields (verbose)
2. INotifyPropertyChanged (UI-focused, overhead)
3. FluentValidation (async, complex setup)
4. Constructor-only validation (doesn't protect mutations)
5. Full immutability (doesn't work with ORMs)

**What C# 14 field-backed properties provide**:
- ✅ **Less boilerplate**: Compiler generates backing field
- ✅ **Synchronous validation**: Errors caught immediately
- ✅ **Performance**: Zero overhead vs. auto-properties
- ✅ **Flexibility**: Add validation without API changes
- ✅ **Simplicity**: No frameworks, no events, just code

**Best of all**: You can **add it later** without breaking existing code. That's the real power.
