// DEMO: C# 14 User-Defined Compound Assignment Operators
Console.WriteLine("=== C# 14 Compound Operators Demo ===\n");

// BEFORE: Traditional operator overloading creates new instances
var price1 = new TraditionalPrice { Amount = 100 };
var discount1 = new Discount { Percentage = 0.10m };
var tax1 = new TaxRate { Rate = 0.06m };

Console.WriteLine("BEFORE (Traditional operators - creates new objects):");
Console.WriteLine($"  Initial price: ${price1.Amount:F2}");
price1 = price1 - discount1;  // Creates a new TraditionalPrice instance
Console.WriteLine($"  After 10% discount: ${price1.Amount:F2}");
price1 = price1 * tax1;  // Creates another new TraditionalPrice instance
Console.WriteLine($"  After 6% tax: ${price1.Amount:F2}");

// AFTER: C# 14 compound assignment operators mutate in place
var price2 = new ModernPrice { Amount = 100 };
var discount2 = new Discount { Percentage = 0.10m };
var tax2 = new TaxRate { Rate = 0.06m };

Console.WriteLine("\nAFTER (C# 14 compound operators - mutates in place):");
Console.WriteLine($"  Initial price: ${price2.Amount:F2}");
price2 -= discount2;  // Mutates the existing ModernPrice instance (no allocation!)
Console.WriteLine($"  After 10% discount: ${price2.Amount:F2}");
price2 *= tax2;  // Mutates the existing ModernPrice instance (no allocation!)
Console.WriteLine($"  After 6% tax: ${price2.Amount:F2}");

Console.WriteLine("\n✓ Same result with better performance!");
Console.WriteLine("  Traditional: 2 new objects created");
Console.WriteLine("  C# 14: 0 new objects created (in-place mutation)");

// Domain types
class Discount
{
    public decimal Percentage { get; set; }
}

class TaxRate
{
    public decimal Rate { get; set; }
}

// BEFORE: Traditional operator overloading (C# 13 and earlier)
class TraditionalPrice
{
    public decimal Amount { get; set; }

    // Traditional binary operators create new instances
    public static TraditionalPrice operator -(TraditionalPrice price, Discount discount)
    {
        return new TraditionalPrice { Amount = price.Amount - (price.Amount * discount.Percentage) };
    }

    public static TraditionalPrice operator *(TraditionalPrice price, TaxRate tax)
    {
        return new TraditionalPrice { Amount = price.Amount * (1 + tax.Rate) };
    }
}

// AFTER: C# 14 compound assignment operators (instance methods)
class ModernPrice
{
    public decimal Amount { get; set; }

    // C# 14: User-defined compound assignment operator (mutates in place)
    public void operator -=(Discount discount)
    {
        Amount -= Amount * discount.Percentage;
    }

    // C# 14: User-defined compound assignment operator (mutates in place)
    public void operator *=(TaxRate tax)
    {
        Amount *= 1 + tax.Rate;
    }
}
