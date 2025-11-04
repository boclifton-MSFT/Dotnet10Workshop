# Feature 5: Expanded Span<T> Conversions

## Run It

```powershell
dotnet run -f net10.0
```

## The Business Problem

Meijer's API gateway parses thousands of SKU strings per second during peak hours:

```
Input: "GROC-12345-A"
Parse to: Category="GROC", ItemID=12345, Variant="A"
```

**The Issue**: Traditional string parsing allocates memory on every request:

```csharp
// Old way: Allocates 4 strings (split result + 3 parts)
string[] parts = sku.Split('-');  // ← Heap allocation!
string category = parts[0];        // ← Another allocation
string itemId = parts[1];          // ← Another allocation
string variant = parts[2];         // ← Another allocation
```

**At Scale**:
- 10,000 requests/sec × 4 allocations = 40,000 heap allocations/sec
- Each allocation triggers garbage collection pressure
- GC pauses slow down API response times
- Memory bandwidth becomes bottleneck

## The Old Approach (C# 13)

**Option 1: String.Split() everywhere**
```csharp
string[] parts = sku.Split('-');  // Allocates array + strings
```
❌ High allocation rate

**Option 2: Manual parsing with IndexOf**
```csharp
int firstDash = sku.IndexOf('-');
int secondDash = sku.IndexOf('-', firstDash + 1);
string category = sku.Substring(0, firstDash);  // Still allocates
```
❌ Still allocates substrings

**Option 3: Span<char> with manual slicing**
```csharp
ReadOnlySpan<char> span = sku.AsSpan();
int firstDash = span.IndexOf('-');
ReadOnlySpan<char> category = span.Slice(0, firstDash);  // ← Zero allocation!
```
✅ No allocations, but verbose and error-prone

## The C# 14 Solution: Expanded Span Conversions

C# 14 makes `Span<T>` parsing concise with `stackalloc` and `Range` support:

```csharp
ReadOnlySpan<char> sku = "GROC-12345-A";
Span<Range> ranges = stackalloc Range[3];  // ← Stack allocation (fast!)
int count = sku.Split(ranges, '-');        // ← Zero heap allocations

var category = sku[ranges[0]];  // "GROC"
var itemId = sku[ranges[1]];    // "12345"
var variant = sku[ranges[2]];   // "A"
```

**Why this matters**:
- ✅ **Zero heap allocations**: Everything on stack
- ✅ **Concise syntax**: Reads like String.Split()
- ✅ **Fast**: 3-5× faster than string allocations
- ✅ **GC-friendly**: No pressure on garbage collector

## Real-World Impact: Customer API

**Before** (String.Split):
- 40,000 allocations/sec
- GC pauses every 2-3 seconds
- p95 latency: 85ms

**After** (Span with stackalloc):
- 0 allocations for SKU parsing
- GC pauses reduced 70%
- p95 latency: 52ms (38% improvement)

**ROI**: Better response times during peak hours (Black Friday, holiday rushes)

---

## "But We Already Do This!" - Addressing Common Pushback

### Pushback #1: "String.Split() is fine for our scale"

**You might say**: "We only parse a few hundred SKUs per second. Allocations aren't a problem."

**Response**: True for low throughput, but consider:

- **Scale Changes**: Traffic spikes during promotions (3-10× normal load)
- **Mobile Constraints**: Cloud functions have memory limits - allocations matter
- **Cost**: Higher GC pressure = more CPU = higher cloud costs

**When String.Split() is fine**:
- <1,000 operations/sec
- Not in request hot-path
- Code clarity more important than performance

**When Span matters**:
- 10,000+ operations/sec
- In request critical path
- Cloud cost optimization needed

### Pushback #2: "Span<T> code is hard to read"

**You might say**: "Span code is harder to understand than strings:"

```csharp
// Clear
string[] parts = sku.Split('-');

// vs Cryptic?
Span<Range> ranges = stackalloc Range[3];
sku.AsSpan().Split(ranges, '-');
```

**Response**: C# 14 makes it cleaner:

**Old Span code (C# 10-13)** - verbose:
```csharp
ReadOnlySpan<char> span = sku.AsSpan();
int firstDash = span.IndexOf('-');
int secondDash = span.IndexOf('-', firstDash + 1);
var category = span.Slice(0, firstDash);
var itemId = span.Slice(firstDash + 1, secondDash - firstDash - 1);
```

**New Span code (C# 14)** - concise:
```csharp
Span<Range> ranges = stackalloc Range[3];
sku.AsSpan().Split(ranges, '-');
var category = sku[ranges[0]];
```

**Best Practice**: Encapsulate in a method:
```csharp
public static (string category, int itemId, string variant) ParseSKU(string sku)
{
    Span<Range> ranges = stackalloc Range[3];
    sku.AsSpan().Split(ranges, '-');
    return (
        sku[ranges[0]].ToString(),
        int.Parse(sku[ranges[1]]),
        sku[ranges[2]].ToString()
    );
}

// Callers don't see Span complexity:
var (category, itemId, variant) = ParseSKU("GROC-12345-A");
```

### Pushback #3: "We use Regex for parsing"

**You might say**: "We use compiled Regex for complex parsing:"

```csharp
[GeneratedRegex(@"^(?<category>\w+)-(?<itemId>\d+)-(?<variant>\w+)$")]
private static partial Regex SkuPattern();

var match = SkuPattern().Match(sku);
string category = match.Groups["category"].Value;
```

**Response**: Regex is powerful but allocates:

**Regex**: Flexible, allocates `Match` object + group strings  
**Span**: Fast, zero allocations, but only for simple patterns

**When to use each**:
- **Regex**: Complex patterns, validation, capture groups
- **Span**: Simple splits, hot-path code, performance-critical

**Hybrid approach**:
```csharp
// Validate with Regex (once)
if (!SkuPattern().IsMatch(sku)) throw new ArgumentException();

// Parse with Span (zero allocations)
Span<Range> ranges = stackalloc Range[3];
sku.AsSpan().Split(ranges, '-');
```

### Pushback #4: "ToString() allocates anyway"

**You might say**: "You call ToString() eventually, so you still allocate:"

```csharp
ReadOnlySpan<char> category = sku[ranges[0]];
string result = category.ToString();  // ← Allocates!
```

**Response**: Only allocate when you actually need strings:

**Defer allocation**:
```csharp
// Parse once with Span (no allocation)
Span<Range> ranges = stackalloc Range[3];
sku.AsSpan().Split(ranges, '-');

// Only allocate strings you actually use:
if (sku[ranges[0]].SequenceEqual("GROC"))  // ← No allocation
{
    int itemId = int.Parse(sku[ranges[1]]);  // ← Parses from span, no string
    // Only allocate variant if needed:
    string variant = sku[ranges[2]].ToString();
}
```

**Real example**: 1,000 SKUs parsed, only 100 need strings allocated = 90% reduction

---

## Summary: When to Use Span<T>

**Use Span when**:
- ✅ Hot-path code (>10K ops/sec)
- ✅ Simple parsing (splits, substrings)
- ✅ Memory/GC pressure is measurable problem

**Stick with strings when**:
- ✅ Low throughput (<1K ops/sec)
- ✅ Complex parsing (Regex, validation)
- ✅ Code clarity more important than performance

**C# 14 improvement**: Makes Span code nearly as readable as string code, removing the main barrier to adoption.
