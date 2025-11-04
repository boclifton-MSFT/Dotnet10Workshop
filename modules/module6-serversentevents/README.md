# Module 6: Server-Sent Events (SSE)

**Duration: 15 minutes**  
**Objective**: Understand when and how to use the new Server-Sent Events API in .NET 10

## Run It

```powershell
dotnet run
# Open browser to http://localhost:5000
# Click "Start" on any demo to see live streaming
```

## The Business Problem

Meijer's Digital Experience team needs real-time features for their web and mobile apps:

- **Store Inventory Updates**: Shoppers see "2 left in stock!" but by the time they add to cart, it's sold out
- **Order Status Tracking**: Customers refresh the page constantly to see "Out for delivery" updates
- **Flash Sale Counters**: "50 items left!" requires polling the server every second, crushing the API

**The Issue**: Current polling-based approach is inefficient and expensive:
```
Scenario: Flash sale with 10,000 concurrent users
Current: 10,000 users × 1 request/second = 10,000 RPS just for updates
         Most requests return "no change" → wasted bandwidth and server CPU
         
Impact: API servers scale up 5× during flash sales
        Users see stale data (1-5 second delay)
        Mobile users burn through battery with constant polling
```

## What You'll Build

A real-time heart rate monitoring demo showing **three SSE patterns**:

| Pattern | Use Case | When to Use |
|---------|----------|-------------|
| String Stream | Simple notifications, log messages | Text-only updates |
| JSON Stream | Structured data (inventory, prices) | API responses, rich data |
| SseItem Stream | Advanced control (reconnection, IDs) | Mission-critical, resumable streams |

**Key benefits of SSE**:
- ✅ 90% fewer requests (10,000 RPS → 1,000 RPS)
- ✅ Instant updates (no polling delay)
- ✅ Automatic reconnection (browser handles it)
- ✅ Standard HTTP (works with existing infrastructure)

## The Old Approach (Polling)

Meijer's current inventory tracking uses polling:

```javascript
// Client polls every second
setInterval(async () => {
  const response = await fetch('/api/inventory/check?sku=12345');
  const data = await response.json();
  updateUI(data.quantity);
}, 1000);
```

**Problems**:
- ❌ 10,000 users = 10,000 requests/sec (most return "no change")
- ❌ 1-second delay before users see updates
- ❌ Server CPU wasted checking unchanged data
- ❌ Mobile battery drain from constant requests

## The .NET 10 Solution: Server-Sent Events

Replace polling with server push:

### 1. String Stream (`/string-item`)
```csharp
async IAsyncEnumerable<string> GetHeartRate(
    [EnumeratorCancellation] CancellationToken cancellationToken)
{
    while (!cancellationToken.IsCancellationRequested)
    {
        var heartRate = Random.Shared.Next(60, 100);
        yield return $"Heart Rate: {heartRate} bpm";
        await Task.Delay(2000, cancellationToken);
    }
}

return TypedResults.ServerSentEvents(GetHeartRate(cancellationToken),
                                     eventType: "heartRate");
```

**What it does:**
- Generates plain text messages
- Sends a new message every 2 seconds
- Uses `eventType` to label the events
- Client receives: `"Heart Rate: 75 bpm"`

### 2. JSON Stream (`/json-item`)
```csharp
async IAsyncEnumerable<HeartRateRecord> GetHeartRate(
    [EnumeratorCancellation] CancellationToken cancellationToken)
{
    while (!cancellationToken.IsCancellationRequested)
    {
        var heartRate = Random.Shared.Next(60, 100);
        yield return HeartRateRecord.Create(heartRate);
        await Task.Delay(2000, cancellationToken);
    }
}

return TypedResults.ServerSentEvents(GetHeartRate(cancellationToken),
                                     eventType: "heartRate");
```

**What it does:**
- Returns strongly-typed `HeartRateRecord` objects
- ASP.NET Core **automatically serializes to JSON**
- Client receives: `{"rate":75,"timestamp":"2025-11-04T..."}`

### 3. SseItem Stream (`/sse-item`)
```csharp
async IAsyncEnumerable<SseItem<int>> GetHeartRate(
    [EnumeratorCancellation] CancellationToken cancellationToken)
{
    while (!cancellationToken.IsCancellationRequested)
    {
        var heartRate = Random.Shared.Next(60, 100);
        yield return new SseItem<int>(heartRate, eventType: "heartRate")
        {
            ReconnectionInterval = TimeSpan.FromMinutes(1)
        };
        await Task.Delay(2000, cancellationToken);
    }
}

return TypedResults.ServerSentEvents(GetHeartRate(cancellationToken));
```

**What it does:**
- Uses `SseItem<T>` for **full control** over SSE features
- Can set event IDs, types, and reconnection intervals
- The `ReconnectionInterval` tells the browser how long to wait before reconnecting

## Running the Demo

### Prerequisites
- .NET 10 SDK installed
- A web browser (Chrome, Edge, Firefox, Safari)

### Steps

1. **Navigate to the module directory:**
   ```bash
   cd modules/module7-serversentevents
   ```

2. **Run the application:**
   ```bash
   dotnet run
   ```

3. **Open your browser** and navigate to:
   ```
   http://localhost:5000
   ```
   (Check the console output for the actual port)

4. **Interact with the demo:**
   - Click "Start" on any section to begin receiving events
   - Watch the heart rate values update every 2 seconds
   - View the event log to see each message received
   - Click "Stop" to close the connection
   - Notice how the connection status changes

## Key Features Demonstrated

### 1. IAsyncEnumerable Integration
```csharp
async IAsyncEnumerable<T> GetData([EnumeratorCancellation] CancellationToken ct)
{
    while (!ct.IsCancellationRequested)
    {
        yield return await FetchNextItem();
    }
}
```
- Uses C# async streams
- `yield return` sends one item at a time
- Automatic cancellation support

### 2. Automatic JSON Serialization
- Return any .NET object
- ASP.NET Core serializes to JSON automatically
- Works with System.Text.Json options

### 3. Event Types
```csharp
TypedResults.ServerSentEvents(stream, eventType: "heartRate")
```
- Client can filter by event type
- Multiple event types can share one connection

### 4. Cancellation Handling
- Automatically stops when client disconnects
- `CancellationToken` propagates through the pipeline
- Clean resource cleanup

## Real-World Use Cases

SSE is perfect for:
- **Live dashboards** - Stock prices, system metrics, analytics
- **Notifications** - Real-time alerts, messages, updates
- **Progress tracking** - Long-running operations, file uploads
- **Live feeds** - News, social media, activity streams
- **IoT data** - Sensor readings, telemetry, monitoring
- **Collaborative features** - Document updates, presence indicators

## Browser Client Code

The HTML demo uses the standard `EventSource` API:

```javascript
const eventSource = new EventSource('/string-item');

// Listen for specific event types
eventSource.addEventListener('heartRate', (e) => {
    console.log('Received:', e.data);
});

// Handle connection events
eventSource.onopen = () => console.log('Connected');
eventSource.onerror = () => console.log('Error or disconnected');

// Close when done
eventSource.close();
```

## SSE Message Format

SSE messages follow this format:
```
event: heartRate
data: Heart Rate: 75 bpm

event: heartRate
data: Heart Rate: 82 bpm
```

For JSON:
```
event: heartRate
data: {"rate":75,"timestamp":"2025-11-04T12:34:56Z"}
```

With IDs:
```
event: heartRate
id: 123
retry: 60000
data: 75
```

## Advanced Features

### Reconnection Control
```csharp
new SseItem<T>(data, eventType: "update")
{
    ReconnectionInterval = TimeSpan.FromSeconds(30)
}
```

### Event IDs
```csharp
new SseItem<T>(data)
{
    Id = "123",  // Client can resume from this ID
    EventType = "update"
}
```

### Multiple Streams
You can have multiple SSE connections to different endpoints simultaneously.

## Performance Considerations

- SSE uses **long-lived connections** - plan your server capacity
- Each connection holds server resources
- Consider using SignalR for bidirectional scenarios
- SSE works well for up to thousands of concurrent connections
- Use proper cancellation tokens to free resources

## Comparison with Other Technologies

### When to use SSE:
- ✅ Simple server → client updates
- ✅ Browser-based clients
- ✅ Automatic reconnection needed
- ✅ Standard HTTP/HTTPS infrastructure

### When to use WebSockets:
- ✅ Bidirectional communication needed
- ✅ Low-latency requirements
- ✅ Binary data transfer
- ✅ Gaming or real-time collaboration

### When to use SignalR:
- ✅ Need automatic fallback (WebSockets → SSE → Long Polling)
- ✅ Want hub-based programming model
- ✅ Cross-platform clients (.NET, JavaScript, Java, Swift)

## Resources

- [MDN: Server-Sent Events](https://developer.mozilla.org/docs/Web/API/Server-sent_events)
- [What's New in ASP.NET Core 10](https://learn.microsoft.com/en-us/aspnet/core/release-notes/aspnetcore-10.0)
- [Official Sample App](https://github.com/dotnet/AspNetCore.Docs/blob/main/aspnetcore/fundamentals/minimal-apis/10.0-samples/MinimalServerSentEvents/Program.cs)

## Next Steps

Try modifying the code to:
1. Stream different types of data (weather, stock prices, logs)
2. Add multiple event types to a single endpoint
3. Implement filtering based on query parameters
4. Add authentication to secure your SSE endpoints
5. Connect to real data sources (databases, external APIs)
