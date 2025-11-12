// C# 14 Overload Resolution with Span Parameters Demo
Console.WriteLine("=== C# 14: Overload Resolution with Span Parameters ===\n");

// Example 1: Implicit Array-to-Span Conversion in Method Calls
Console.WriteLine("Example 1: Implicit Array-to-Span Conversion");
Console.WriteLine("---------------------------------------------");

int[] numbers = { 1, 2, 3, 4, 5 };

// C# 14 FEATURE: Array automatically converts to ReadOnlySpan<int>
// The compiler chooses the span overload without needing .AsSpan()
// 
// What's happening under the hood:
// 1. You call a method with an array
// 2. Compiler sees MemoryExtensions.Contains(ReadOnlySpan<int>, int)
// 3. In C# 14, compiler knows: int[] can implicitly convert to ReadOnlySpan<int>
// 4. Compiler chooses the span overload automatically!
bool containsThree = MemoryExtensions.Contains(numbers, 3);
Console.WriteLine($"Array contains 3: {containsThree}");
Console.WriteLine("✓ Compiler chose MemoryExtensions.Contains(ReadOnlySpan<int>) automatically");
Console.WriteLine("✓ No need to call numbers.AsSpan() explicitly!\n");

// Example 2: Extension Methods on Arrays Now Prefer Span Overloads
Console.WriteLine("Example 2: Extension Methods Prefer Span Overloads");
Console.WriteLine("---------------------------------------------------");

// C# 14 FEATURE: Extension methods with span receivers now work directly on arrays
// The compiler prefers span-based extension methods over IEnumerable<T> methods
//
// In C# 13: searchArray.IndexOf(30) wouldn't find MemoryExtensions.IndexOf
//           because the array wouldn't match the ReadOnlySpan<int> parameter
// In C# 14: Compiler knows arrays can convert to spans, so it finds the span overload!
int[] searchArray = { 10, 20, 30, 40, 50 };
int index = searchArray.IndexOf(30);  // Resolves to MemoryExtensions.IndexOf (span-based)
Console.WriteLine($"Index of 30: {index}");
Console.WriteLine("✓ Resolved to MemoryExtensions.IndexOf(ReadOnlySpan<int>, int)");
Console.WriteLine("✓ Not Enumerable.IndexOf or List.IndexOf - span version is preferred!\n");

// Example 3: Real-World Benefit - String Processing
Console.WriteLine("Example 3: High-Performance String Operations");
Console.WriteLine("----------------------------------------------");

string sku = "PROD-12345-XL";

// C# 14 FEATURE: String (which can convert to ReadOnlySpan<char>) works with span methods
// Note: We still use .AsSpan() here for string-to-span conversion
// (The main C# 14 improvement is array-to-span, not string-to-span)
int dashIndex = sku.AsSpan().IndexOf('-');
Console.WriteLine($"First dash at index: {dashIndex}");

// Split using span-based approach (zero allocations)
// This demonstrates the PERFORMANCE benefit that C# 14's feature enables
Span<Range> ranges = stackalloc Range[3];
int count = sku.AsSpan().Split(ranges, '-');
Console.WriteLine($"Split into {count} parts:");
for (int i = 0; i < count; i++)
{
    ReadOnlySpan<char> part = sku.AsSpan(ranges[i]);
    Console.WriteLine($"  Part {i + 1}: {part}");
}
Console.WriteLine("✓ Zero heap allocations - all stack-based!\n");

// Example 4: Method Overload Selection - The Core Benefit
Console.WriteLine("Example 4: Overload Resolution in Action");
Console.WriteLine("-----------------------------------------");

// Demonstrate that span overloads are now preferred for arrays
byte[] data = { 65, 66, 67, 68, 69 };  // ASCII: A, B, C, D, E

// C# 14: This resolves to span-based Contains
// Previously would resolve to Enumerable.Contains or require data.AsSpan().Contains()
// 
// The Beauty: Code looks the same as LINQ, but performs like span code!
bool hasB = data.Contains((byte)66);
Console.WriteLine($"Data contains 'B' (66): {hasB}");
Console.WriteLine("✓ Span overload selected - better performance!");
Console.WriteLine("✓ No .AsSpan() needed - compiler did it for us!\n");

Console.WriteLine("=================================================");
Console.WriteLine("Key Takeaway: C# 14 makes span-based code natural");
Console.WriteLine("- No manual .AsSpan() calls needed for arrays");
Console.WriteLine("- Compiler automatically chooses efficient overloads");
Console.WriteLine("- Better performance with cleaner syntax");
Console.WriteLine("- Write code like LINQ, get performance like Span!");
Console.WriteLine("=================================================");
