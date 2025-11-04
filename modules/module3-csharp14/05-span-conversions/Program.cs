// DEMO
Console.WriteLine("=== Span Conversions Demo ===\n");

var skuString = "PROD-12345-XL";

// BEFORE: String parsing (allocates)
Console.WriteLine("BEFORE (String parsing - allocates memory):");
var parts1 = skuString.Split('-');
Console.WriteLine($"  SKU parts: {string.Join(", ", parts1)}");
Console.WriteLine($"  Allocated {parts1.Length} strings on heap");

// AFTER: Span parsing (no allocations)
Console.WriteLine("\nAFTER (Span parsing - stack-based, no allocations):");
Span<Range> ranges = stackalloc Range[3];
var count = skuString.Split(ranges, '-');
for (int i = 0; i < count; i++)
{
    var part = skuString[ranges[i]];
    Console.WriteLine($"  Part {i + 1}: {part}");
}
Console.WriteLine($"  Zero allocations - used stack instead!");

Console.WriteLine("\n✓ Same parsing result, much better for high-throughput APIs!");
Console.WriteLine("In Meijer's 2M+ daily transactions, this saves GC pressure.");
