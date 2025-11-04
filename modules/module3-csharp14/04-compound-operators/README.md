# Feature 4: User-Defined Compound Operators

## Run It

```powershell
dotnet run -f net10.0
```

## The Business Problem

Meijer's checkout system applies complex discount logic thousands of times per day:

- **Percentage Discounts**: 20% off groceries
- **Fixed Amount**: $5 off total
- **BOGO Offers**: Buy one, get 50% off second
- **Tiered Discounts**: $10 off orders over $50, $25 off over $100

Every discount calculation looks like this in code:

```csharp
decimal originalPrice = 49.99m;
decimal discount = 0.20m;  // 20% off

// Calculate discounted price
decimal discountedPrice = originalPrice - (originalPrice * discount);
```

**Issues**:
- ❌ **Error-Prone Arithmetic**: Easy to write `originalPrice * discount` instead of `originalPrice - (originalPrice * discount)`
- ❌ **Hard to Read**: Business logic (apply 20% discount) obscured by math operators
- ❌ **Copy-Paste Errors**: Same formula repeated 50+ times across checkout code
- ❌ **No Type Safety**: Accidentally mix discount rates (0.20) with dollar amounts ($20.00)

When a developer makes a typo like this:
```csharp
// Bug: Should be "price - (price * discount)" but wrote "price * discount"
decimal finalPrice = price * discount;  // Customer pays $10 instead of $40!
```

This causes:
- **Revenue Loss**: Customer charged $10 instead of $40
- **Customer Complaints**: "Your sale price was wrong!"
- **Support Tickets**: Manual refunds and adjustments

## The Old Approach (C# 13)

You had limited options for making discount logic safer:

**Option 1: Repeat the formula everywhere**
```csharp
decimal finalPrice = originalPrice - (originalPrice * discount);  // Copy-paste 50 times
```
❌ Duplicated code, copy-paste errors

**Option 2: Create helper methods**
```csharp
public static decimal ApplyDiscount(decimal price, decimal discount)
{
    return price - (price * discount);
}

decimal finalPrice = CalculationHelpers.ApplyDiscount(originalPrice, discount);
```
❌ Doesn't read like business logic, extra class needed

**Option 3: Extension methods**
```csharp
public static decimal ApplyDiscount(this decimal price, decimal discount)
{
    return price - (price * discount);
}

decimal finalPrice = originalPrice.ApplyDiscount(discount);
```
❌ Better, but still verbose for common operations

**Option 4: Create custom Price type**
```csharp
public class Price
{
    public decimal Amount { get; }
    
    public Price ApplyDiscount(decimal discount)
    {
        return new Price(Amount - (Amount * discount));
    }
}

var finalPrice = originalPrice.ApplyDiscount(0.20m);
```
❌ Requires method calls instead of natural operators

## The C# 14 Solution: User-Defined Compound Operators

C# 14 lets you define operators like `-`, `*`, `/` for your domain types:

```csharp
public readonly struct Price
{
    public decimal Amount { get; }
    
    public Price(decimal amount) => Amount = amount;
    
    // Define subtraction operator: Price - Discount
    public static Price operator -(Price price, Discount discount)
    {
        return new Price(price.Amount - (price.Amount * discount.Rate));
    }
}

public readonly struct Discount
{
    public decimal Rate { get; }
    
    public Discount(decimal rate) => Rate = rate;
}

// Now discount logic reads naturally:
var originalPrice = new Price(49.99m);
var discount = new Discount(0.20m);
var finalPrice = originalPrice - discount;  // ← Reads like business logic!
```

**Why this matters**:
- ✅ **Type Safety**: Can't accidentally subtract a dollar amount where you meant a percentage
- ✅ **Self-Documenting**: `price - discount` is clearer than `price - (price * discount.Rate)`
- ✅ **Fewer Errors**: Math formula is centralized, not repeated
- ✅ **Natural Syntax**: Reads like the business rule ("apply discount to price")

## Real-World Example: Meijer's Checkout Flow

**Before** (C# 13 - manual arithmetic):
```csharp
// Cart total calculation
decimal subtotal = 149.99m;
decimal memberDiscount = 0.10m;      // 10% member discount
decimal promotionDiscount = 0.05m;   // 5% promotion

// Apply discounts (error-prone!)
decimal afterMember = subtotal - (subtotal * memberDiscount);
decimal afterPromo = afterMember - (afterPromo * promotionDiscount);  // ← BUG! Should be "afterMember"
decimal taxAmount = afterPromo * 0.06m;  // 6% tax
decimal total = afterPromo + taxAmount;
```
❌ Copy-paste error in line 8 (`afterPromo` instead of `afterMember`)

**After** (C# 14 - compound operators):
```csharp
// Cart total calculation
var subtotal = new Price(149.99m);
var memberDiscount = new Discount(0.10m);
var promotionDiscount = new Discount(0.05m);
var taxRate = new TaxRate(0.06m);

// Apply discounts (type-safe!)
var afterMember = subtotal - memberDiscount;
var afterPromo = afterMember - promotionDiscount;  // ✓ Type system prevents errors
var taxAmount = afterPromo * taxRate;
var total = afterPromo + taxAmount;
```
✅ Compiler enforces correct types, prevents copy-paste errors

This means:
- **Fewer Bugs**: Type system catches mismatched operations at compile time
- **Easier Code Review**: Business logic is explicit, not hidden in math
- **Faster Onboarding**: New developers understand `price - discount` immediately
- **Better Testing**: Can test operator logic once instead of testing every calculation

## Why This Matters for Customers

1. **Correct Pricing**: Type safety prevents arithmetic errors that cost money
2. **Readable Code**: Business rules are explicit in the code structure
3. **Centralized Logic**: Discount formula lives in one place, not scattered across 50 files
4. **Compile-Time Safety**: Can't accidentally mix incompatible units (percentage vs. dollar amount)

**Real ROI**:
- **Before**: 3 pricing bugs per month × 2 hours debugging each = 6 hours/month wasted
- **After**: Compiler catches type mismatches, pricing bugs drop to <1 per quarter
- **Savings**: ~70 hours/year of developer time + reduced revenue loss from pricing errors

---

## "But We Already Do This!" - Addressing Common Pushback

### Pushback #1: "We use extension methods for domain operations"

**You might say**: "We already have extension methods for common operations:"

```csharp
public static class PriceExtensions
{
    public static decimal ApplyDiscount(this decimal price, decimal discount)
    {
        return price - (price * discount);
    }
    
    public static decimal ApplyTax(this decimal price, decimal taxRate)
    {
        return price * (1 + taxRate);
    }
}

// Usage:
decimal total = subtotal
    .ApplyDiscount(0.20m)
    .ApplyTax(0.06m);
```

**Response**: Extension methods work, but lack type safety and discoverability:

**Problems with Extension Methods**:
- ❌ **No Type Safety**: Nothing prevents `subtotal.ApplyDiscount(0.06m).ApplyTax(0.20m)` (swapped arguments)
- ❌ **Primitive Obsession**: Everything is `decimal`, no semantic meaning
- ❌ **Hard to Discover**: Extension methods hidden in IDE autocomplete
- ❌ **Verbose Chaining**: Multiple method calls instead of natural operators

**Compound operators are clearer**:
```csharp
// Type-safe domain types
var total = (subtotal - discount) * taxRate;  // ← Natural math notation
// vs
var total = subtotal.ApplyDiscount(discount).ApplyTax(taxRate);  // ← Verbose method calls
```

**When to use each**:
- **Extension Methods**: Complex operations with multiple parameters, conditional logic
- **Compound Operators**: Simple binary operations that read like math (add, subtract, multiply)

### Pushback #2: "We use methods on domain objects"

**You might say**: "We have domain objects with methods:"

```csharp
public class Price
{
    public decimal Amount { get; }
    
    public Price ApplyDiscount(Discount discount)
    {
        return new Price(Amount - (Amount * discount.Rate));
    }
    
    public Price AddTax(TaxRate taxRate)
    {
        return new Price(Amount * (1 + taxRate.Rate));
    }
}

// Usage:
var total = subtotal
    .ApplyDiscount(memberDiscount)
    .ApplyDiscount(promoDiscount)
    .AddTax(salesTax);
```

**Response**: This is good domain modeling, but operators make it even better:

**Problems with Method-Only Approach**:
- ❌ **Verbose**: `price.ApplyDiscount(discount)` vs. `price - discount`
- ❌ **Method Naming**: Is it `ApplyDiscount`, `WithDiscount`, `SubtractDiscount`? Teams debate naming
- ❌ **Not Composable**: Can't write `(price1 + price2) - discount` naturally
- ❌ **Doesn't Match Mental Model**: Business thinks "subtract discount", code says "apply discount"

**Operators complement methods**:
```csharp
public readonly struct Price
{
    public decimal Amount { get; }
    
    // Operators for simple binary operations
    public static Price operator -(Price price, Discount discount) => /* ... */;
    public static Price operator +(Price left, Price right) => /* ... */;
    public static Price operator *(Price price, TaxRate rate) => /* ... */;
    
    // Methods for complex operations
    public Price ApplyBulkDiscount(int quantity) 
    {
        // Complex tiered discount logic
        return quantity >= 10 ? this * new Discount(0.15m) :
               quantity >= 5  ? this * new Discount(0.10m) :
               this;
    }
}

// Use operators for simple math:
var subtotal = itemPrice * quantity;

// Use methods for complex business logic:
var discountedPrice = itemPrice.ApplyBulkDiscount(quantity);
```

**Best Practice**: 
- Use **operators** for simple arithmetic (`+`, `-`, `*`, `/`)
- Use **methods** for complex operations with business rules

### Pushback #3: "We use value objects with explicit methods"

**You might say**: "We follow DDD principles with value objects:"

```csharp
public class Money
{
    public decimal Amount { get; }
    public string Currency { get; }
    
    private Money(decimal amount, string currency)
    {
        Amount = amount;
        Currency = currency;
    }
    
    public Money Add(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException("Cannot add different currencies");
        return new Money(Amount + other.Amount, Currency);
    }
    
    public Money Subtract(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException("Cannot subtract different currencies");
        return new Money(Amount - other.Amount, Currency);
    }
}

// Usage:
var total = price1.Add(price2).Subtract(discount);
```

**Response**: Excellent DDD! Operators make value objects even more expressive:

**You can have both**:
```csharp
public class Money
{
    public decimal Amount { get; }
    public string Currency { get; }
    
    // Keep your validation in one place
    private void ValidateSameCurrency(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException($"Cannot operate on {Currency} and {other.Currency}");
    }
    
    // Operators call validated methods
    public static Money operator +(Money left, Money right)
    {
        left.ValidateSameCurrency(right);
        return new Money(left.Amount + right.Amount, left.Currency);
    }
    
    public static Money operator -(Money left, Money right)
    {
        left.ValidateSameCurrency(right);
        return new Money(left.Amount - right.Amount, left.Currency);
    }
    
    // Explicit methods for non-obvious operations
    public Money ConvertTo(string targetCurrency, decimal exchangeRate)
    {
        return new Money(Amount * exchangeRate, targetCurrency);
    }
}

// Now both work:
var total = price1 + price2 - discount;  // ← Natural for simple math
var converted = price1.ConvertTo("EUR", 0.85m);  // ← Explicit for complex operations
```

**Why operators are better for value objects**:
- ✅ Value objects represent **values** (like numbers) - should behave like numbers
- ✅ Operators match mathematical notation: `a + b - c` reads better than `a.Add(b).Subtract(c)`
- ✅ Immutability still enforced (operators return new instances)
- ✅ Validation still happens (inside operator implementation)

**When to use methods instead**:
- Operations that aren't obvious: `money.ConvertTo(currency)` not `money * currency`
- Operations with side effects: `order.Submit()` not `order++`
- Operations with multiple parameters: `price.ApplyTieredDiscount(quantity, tier)` not `price * quantity * tier`

### Pushback #4: "We use implicit/explicit conversion operators"

**You might say**: "We already use operator overloading for conversions:"

```csharp
public readonly struct Price
{
    public decimal Amount { get; }
    
    // Implicit conversion from decimal
    public static implicit operator Price(decimal amount) => new Price(amount);
    
    // Explicit conversion to decimal
    public static explicit operator decimal(Price price) => price.Amount;
}

// Usage:
Price price = 49.99m;  // Implicit conversion
decimal amount = (decimal)price;  // Explicit conversion
```

**Response**: Great! Now you can add arithmetic operators too:

**Conversions vs. Arithmetic**:
- **Conversion operators** (`implicit`, `explicit`): Change types
- **Arithmetic operators** (`+`, `-`, `*`, `/`): Perform operations

**They work together**:
```csharp
public readonly struct Price
{
    public decimal Amount { get; }
    
    // Conversion operators (existing)
    public static implicit operator Price(decimal amount) => new Price(amount);
    public static explicit operator decimal(Price price) => price.Amount;
    
    // Arithmetic operators (NEW in C# 14)
    public static Price operator +(Price left, Price right) 
        => new Price(left.Amount + right.Amount);
    
    public static Price operator -(Price price, Discount discount)
        => new Price(price.Amount - (price.Amount * discount.Rate));
    
    public static Price operator *(Price price, int quantity)
        => new Price(price.Amount * quantity);
}

// Now you get best of both:
Price itemPrice = 24.99m;                        // ← Implicit conversion
var lineTotal = itemPrice * 3;                   // ← Arithmetic operator
var discounted = lineTotal - new Discount(0.1m); // ← Domain operator
decimal finalAmount = (decimal)discounted;       // ← Explicit conversion
```

**Best Practice**: 
- Use **conversion operators** to bridge between domain types and primitives
- Use **arithmetic operators** to express domain operations

### Pushback #5: "Operator overloading makes code harder to understand"

**You might say**: "Operators hide implementation details - explicit methods are clearer:"

```csharp
// Explicit method - clear what's happening
var discountedPrice = originalPrice.ApplyPercentageDiscount(0.20m);

// vs

// Operator - what does subtraction mean for Price?
var discountedPrice = originalPrice - discount;  // ← What does this do?
```

**Response**: Valid concern! Operators should only be used when the operation is **obvious**:

**When Operators Are Clear** ✅:
- **Price + Price**: Obviously adds amounts
- **Price - Discount**: Clearly applies discount
- **Price * Quantity**: Intuitively multiplies
- **Money + Money**: Obviously combines amounts

**When Operators Are Confusing** ❌:
- **Order + Order**: What does this mean? Merge? Combine?
- **Customer - Customer**: Nonsensical operation
- **Discount * Discount**: Unclear semantics
- **Product / Product**: No intuitive meaning

**Guidelines for Workshop Attendees**:

1. **Only overload operators that match real-world math**:
   ```csharp
   // ✅ Good: Matches intuition
   var total = price * quantity;
   var discounted = total - discount;
   
   // ❌ Bad: Confusing semantics
   var merged = order1 + order2;  // What does "add orders" mean?
   ```

2. **Document non-obvious operators**:
   ```csharp
   /// <summary>
   /// Applies percentage discount to price.
   /// Example: $100 - 20% discount = $80
   /// </summary>
   public static Price operator -(Price price, Discount discount) { /* ... */ }
   ```

3. **Provide explicit methods as alternatives**:
   ```csharp
   public readonly struct Price
   {
       // Operator for concise code
       public static Price operator -(Price price, Discount discount) 
           => price.ApplyDiscount(discount);
       
       // Explicit method for clarity
       public Price ApplyDiscount(Discount discount)
           => new Price(Amount - (Amount * discount.Rate));
   }
   
   // Both work:
   var option1 = price - discount;              // Concise
   var option2 = price.ApplyDiscount(discount); // Explicit
   ```

4. **Don't overload operators with surprising behavior**:
   ```csharp
   // ❌ BAD: Surprising side effect
   public static Order operator +(Order order, Item item)
   {
       order.Items.Add(item);  // ← Mutates state! Surprising!
       EmailService.SendNotification();  // ← Side effect! Very bad!
       return order;
   }
   
   // ✅ GOOD: Pure, predictable
   public static Price operator +(Price left, Price right)
   {
       return new Price(left.Amount + right.Amount);  // ← Pure function
   }
   ```

**Real Example from Meijer - Clear vs. Unclear**:
```csharp
// ✅ CLEAR: Obvious operations
var itemPrice = new Price(24.99m);
var lineTotal = itemPrice * 3;              // Obviously: 3 items
var discounted = lineTotal - memberDiscount; // Obviously: apply discount
var withTax = discounted + salesTax;        // Obviously: add tax

// ❌ UNCLEAR: Use methods instead
var merged = cart1 + cart2;                 // Merge carts? Add totals? Use cart1.MergeWith(cart2)
var updated = inventory - order;            // Subtract? Deplete? Use inventory.Deplete(order)
```

---

## Summary: Why C# 14 Compound Operators Matter

**What enterprises do today**:
1. Repeat arithmetic formulas (error-prone, duplication)
2. Extension methods (verbose, no type safety)
3. Domain methods (good, but verbose for simple operations)
4. Value objects with explicit methods (excellent DDD, but not math-like)
5. Avoid operators entirely (miss opportunity for expressiveness)

**What C# 14 compound operators provide**:
- ✅ **Type Safety**: Compiler prevents mismatched operations
- ✅ **Natural Syntax**: Reads like mathematical notation
- ✅ **Centralized Logic**: Formula lives in one place
- ✅ **Better Errors**: Compile-time errors instead of runtime bugs
- ✅ **Domain Clarity**: `price - discount` is self-documenting

**Best Practices**:
- ✅ Overload operators when operation matches intuition (math-like)
- ✅ Provide explicit methods as alternatives for clarity
- ✅ Document non-obvious operator semantics
- ✅ Keep operators pure (no side effects)
- ❌ Don't overload operators with surprising behavior

**Perfect for**:
- Financial calculations (prices, discounts, taxes)
- Measurements (weight, distance, time)
- Value objects that represent numeric concepts
- Domain models with clear arithmetic operations
