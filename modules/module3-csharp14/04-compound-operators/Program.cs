// DEMO
Console.WriteLine("=== Operators Demo ===\n");

var price1 = new DecimalPrice { Amount = 100 };
var discount = new SimpleDiscount { Percentage = 0.10m };

Console.WriteLine("BEFORE (Manual arithmetic):");
var result1 = price1.Amount * (1 - discount.Percentage);
Console.WriteLine($"  Price after 10% discount: ${result1:F2}");

var price2 = new OperatorPrice { Amount = 100 };
Console.WriteLine("\nAFTER (User-defined operators):");
var discountedPrice = price2 - discount;
Console.WriteLine($"  Price after 10% discount: ${discountedPrice.Amount:F2}");

var incrementedPrice = price2.Amount + 1;
Console.WriteLine($"  Price after incrementing by 1 with standard operator: ${incrementedPrice:F2}");
Console.WriteLine($"  Price after incrementing by 1 with ++ operator: ${(++price2).Amount:F2}");

Console.WriteLine("\n✓ Same result, clearer intent with operators!");

class DecimalPrice
{
    public decimal Amount { get; set; }
}

class SimpleDiscount
{
    public decimal Percentage { get; set; }
}

class OperatorPrice
{
    public decimal Amount { get; set; }

    // C# 14: User-defined operator
    public static OperatorPrice operator -(OperatorPrice price, SimpleDiscount discount)
    {
        var result = new OperatorPrice { Amount = price.Amount };
        result.Amount -= price.Amount * discount.Percentage;
        return result;
    }

    public static OperatorPrice operator ++(OperatorPrice price)
    {
        var result = new OperatorPrice { Amount = price.Amount + 1 };
        return result;
    }
}
