// DEMO: Comparing traditional extension methods (C# 13) vs. C# 14 extension members

// === BEFORE: Using traditional extension methods (C# 13 and earlier) ===
var product1 = new ProductBefore { Name = "Milk", Price = 3.99m };
var tax1 = product1.CalculateTax();

var order1 = new OrderBefore { OrderId = "ORD-001", Subtotal = 99.99m };
var tax2 = order1.CalculateTax();

// === AFTER: Using C# 14 extension members with 'extension' keyword ===
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
Console.WriteLine("\nWhy C# 14 extension members are better:");
Console.WriteLine("  • Cleaner syntax without 'this' parameter");
Console.WriteLine("  • Extension members grouped by type in blocks");
Console.WriteLine("  • Enables extension properties and indexers (not shown here)");
Console.WriteLine("  • Tax logic in ONE place (TaxExtensions)");
Console.WriteLine("  • Change once, all types benefit");
Console.WriteLine("  • Original classes stay clean");

// BEFORE: Tax calculation duplicated in each class (traditional C# approach)
// Problem: Every time you need to fix a tax calculation bug, you must fix it in multiple places
class ProductBefore
{
    public string Name { get; set; } = "";
    public decimal Price { get; set; }
    // Tax logic duplicated here
    public decimal CalculateTax(decimal taxRate = 0.085m) => Price * taxRate;
}

class OrderBefore
{
    public string OrderId { get; set; } = "";
    public decimal Subtotal { get; set; }
    // Tax logic duplicated here (same calculation, different property)
    public decimal CalculateTax(decimal taxRate = 0.085m) => Subtotal * taxRate;
}

// AFTER: Tax calculation consolidated with C# 14 Extension Members
// Note: Classes implement interfaces to enable extension members
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

// C# 14: Extension members using the new 'extension' keyword
// This groups all extension members for a type in one block for better organization
static class TaxExtensions
{
    // Extension members for IProduct
    // Syntax: extension(TypeName receiverName) { ... extension members ... }
    extension(IProduct product)
    {
        // Extension method - calculates tax based on product price
        // Can be called as: product.CalculateTax() or product.CalculateTax(0.10m)
        public decimal CalculateTax(decimal taxRate = 0.085m)
            => product.Price * taxRate;
    }

    // Extension members for IOrder
    // Each extension block is specific to one type
    extension(IOrder order)
    {
        // Extension method - calculates tax based on order subtotal
        // The 'extension' keyword eliminates the need for 'this' parameter
        public decimal CalculateTax(decimal taxRate = 0.085m)
            => order.Subtotal * taxRate;
    }
}
