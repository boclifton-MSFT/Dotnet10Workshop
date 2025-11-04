// DEMO
var product1 = new ProductBefore { Name = "Milk", Price = 3.99m };
var tax1 = product1.CalculateTax();

var order1 = new OrderBefore { OrderId = "ORD-001", Subtotal = 99.99m };
var tax2 = order1.CalculateTax();

var product2 = new ProductAfter { Name = "Milk", Price = 3.99m };
var tax3 = product2.CalculateTax();

var order2 = new OrderAfter { OrderId = "ORD-001", Subtotal = 99.99m };
var tax4 = order2.CalculateTax();

Console.WriteLine("=== Extension Members Demo ===\n");
Console.WriteLine("BEFORE (C# 13 way - methods in each class):");
Console.WriteLine($"  Product tax: ${tax1:F2}");
Console.WriteLine($"  Order tax: ${tax2:F2}");
Console.WriteLine("\nAFTER (C# 14 way - extension members):");
Console.WriteLine($"  Product tax: ${tax3:F2}");
Console.WriteLine($"  Order tax: ${tax4:F2}");
Console.WriteLine("\n✓ Both approaches produce identical results!");
Console.WriteLine("\nWhy After is better:");
Console.WriteLine("  • Tax logic in ONE place (TaxExtensions)");
Console.WriteLine("  • Change once, all types benefit");
Console.WriteLine("  • Original classes stay clean");
Console.WriteLine("  • Easy to add to more types");

// BEFORE: Tax calculation duplicated
class ProductBefore
{
    public string Name { get; set; } = "";
    public decimal Price { get; set; }
    public decimal CalculateTax(decimal taxRate = 0.085m) => Price * taxRate;
}

class OrderBefore
{
    public string OrderId { get; set; } = "";
    public decimal Subtotal { get; set; }
    public decimal CalculateTax(decimal taxRate = 0.085m) => Subtotal * taxRate;
}

// AFTER: Tax calculation consolidated with Extension Members
class ProductAfter : IProduct
{
    public string Name { get; set; } = "";
    public decimal Price { get; set; }
}

internal interface IProduct
{
    public decimal Price { get; set; }
}

class OrderAfter : IOrder
{
    public string OrderId { get; set; } = "";
    public decimal Subtotal { get; set; }
}

internal interface IOrder
{
    public decimal Subtotal { get; set; }
}

static class TaxExtensions
{
    public static decimal CalculateTax(this IProduct p, decimal taxRate = 0.085m)
        => p.Price * taxRate;

    public static decimal CalculateTax(this IOrder o, decimal taxRate = 0.085m)
        => o.Subtotal * taxRate;
}
