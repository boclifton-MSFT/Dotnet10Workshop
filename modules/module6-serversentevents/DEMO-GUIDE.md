# Server-Sent Events (SSE) Demo - Quick Reference

## What You're Seeing

Your browser now shows an interactive demo with **3 different endpoints** streaming real-time heart rate data using the new .NET 10 Server-Sent Events feature.

## How to Use the Demo

1. **Click "Start"** on any of the three sections
2. **Watch the heart rate update** every 2 seconds with random values between 60-100 bpm
3. **View the event log** to see each message as it arrives
4. **Click "Stop"** to close the connection
5. **Try all three endpoints** to see the differences

## The Three Endpoints Explained

### 1. String Stream (`/string-item`)
- **What it sends:** Plain text strings like `"Heart Rate: 75 bpm"`
- **How it works:** The server yields simple strings
- **Use case:** Simple notifications, status updates, log messages

**Server Code:**
```csharp
async IAsyncEnumerable<string> GetHeartRate(CancellationToken ct)
{
    while (!ct.IsCancellationRequested)
    {
        var heartRate = Random.Shared.Next(60, 100);
        yield return $"Heart Rate: {heartRate} bpm";
        await Task.Delay(2000, ct);
    }
}

return TypedResults.ServerSentEvents(GetHeartRate(ct), eventType: "heartRate");
```

**Client receives:**
```
event: heartRate
data: Heart Rate: 75 bpm
```

### 2. JSON Stream (`/json-item`)
- **What it sends:** JSON objects `{"rate":75,"timestamp":"2025-11-04T..."}`
- **How it works:** Returns `HeartRateRecord` objects, ASP.NET Core auto-serializes to JSON
- **Use case:** Structured data, API responses, complex objects

**Server Code:**
```csharp
async IAsyncEnumerable<HeartRateRecord> GetHeartRate(CancellationToken ct)
{
    while (!ct.IsCancellationRequested)
    {
        var heartRate = Random.Shared.Next(60, 100);
        yield return HeartRateRecord.Create(heartRate);
        await Task.Delay(2000, ct);
    }
}

return TypedResults.ServerSentEvents(GetHeartRate(ct), eventType: "heartRate");
```

**Client receives:**
```
event: heartRate
data: {"rate":75,"timestamp":"2025-11-04T12:34:56Z"}
```

### 3. SseItem Stream (`/sse-item`)
- **What it sends:** Raw integers with SSE metadata
- **How it works:** Uses `SseItem<int>` for full control over SSE features
- **Use case:** When you need event IDs, reconnection control, or multiple event types

**Server Code:**
```csharp
async IAsyncEnumerable<SseItem<int>> GetHeartRate(CancellationToken ct)
{
    while (!ct.IsCancellationRequested)
    {
        var heartRate = Random.Shared.Next(60, 100);
        yield return new SseItem<int>(heartRate, eventType: "heartRate")
        {
            ReconnectionInterval = TimeSpan.FromMinutes(1)
        };
        await Task.Delay(2000, ct);
    }
}

return TypedResults.ServerSentEvents(GetHeartRate(ct));
```

**Client receives:**
```
event: heartRate
retry: 60000
data: 75
```

## Key Concepts

### What is Server-Sent Events?

SSE is a **standard protocol** for servers to push data to browsers over HTTP:

- **Unidirectional:** Server → Client only (client can't send back)
- **Persistent Connection:** Uses one long-lived HTTP connection
- **Automatic Reconnection:** Browser reconnects automatically if disconnected
- **Event-Based:** Messages have types (like "heartRate") that clients can filter
- **Text-Based:** Uses simple text format (easier to debug than WebSockets)

### SSE vs WebSockets

| Feature | SSE | WebSockets |
|---------|-----|------------|
| **Direction** | Server → Client | Bidirectional |
| **Protocol** | HTTP/HTTPS | WebSocket (ws://, wss://) |
| **Reconnection** | Automatic | Manual |
| **Data Format** | Text only | Text + Binary |
| **Complexity** | Simple | More complex |
| **Best For** | Feeds, updates, notifications | Chat, gaming, collaboration |

### The Client Side (Browser JavaScript)

```javascript
// Create connection
const eventSource = new EventSource('/string-item');

// Listen for specific event types
eventSource.addEventListener('heartRate', (event) => {
    console.log('Received:', event.data);
    console.log('Event ID:', event.lastEventId);
});

// Connection opened
eventSource.onopen = () => {
    console.log('Connected!');
};

// Connection error/closed
eventSource.onerror = (error) => {
    console.log('Error or disconnected');
};

// Close when done
eventSource.close();
```

### The Server Side (.NET 10)

```csharp
// New TypedResults.ServerSentEvents method!
app.MapGet("/events", (CancellationToken ct) =>
{
    async IAsyncEnumerable<T> GenerateEvents([EnumeratorCancellation] CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            yield return await GetNextEvent();
            await Task.Delay(1000, ct);
        }
    }
    
    return TypedResults.ServerSentEvents(GenerateEvents(ct), eventType: "update");
});
```

## Real-World Use Cases

### Perfect for SSE:
- 📊 **Live Dashboards** - Stock prices, metrics, analytics
- 🔔 **Notifications** - Alerts, messages, updates
- 📈 **Progress Tracking** - Upload status, job completion
- 📰 **Live Feeds** - News, social media, activity streams
- 🌡️ **IoT/Sensors** - Temperature, humidity, sensor data
- 🤝 **Presence** - Online/offline status, typing indicators

### NOT ideal for SSE:
- 💬 **Chat Applications** - Use WebSockets (bidirectional)
- 🎮 **Gaming** - Use WebSockets (low latency needed)
- 📤 **File Upload** - Use regular HTTP POST
- 🔐 **Request/Response** - Use regular HTTP

## Technical Details

### SSE Message Format

```
event: heartRate
id: 123
retry: 10000
data: {"rate":75}

event: heartRate
id: 124
data: {"rate":82}
```

**Fields:**
- `event:` - Event type (optional, default is "message")
- `id:` - Event ID for resuming (optional)
- `retry:` - Reconnection delay in milliseconds (optional)
- `data:` - The actual data (required)

### How Cancellation Works

When the client disconnects (closes browser tab, clicks "Stop", etc.):
1. Browser closes the HTTP connection
2. Server detects the disconnect
3. `CancellationToken` is triggered
4. `while (!ct.IsCancellationRequested)` loop exits
5. Server stops generating events
6. Resources are cleaned up

### JSON Serialization

ASP.NET Core automatically serializes objects to JSON using `System.Text.Json`:

```csharp
// This record...
public record HeartRateRecord(int Rate, DateTime Timestamp);

// Becomes this JSON...
{"rate":75,"timestamp":"2025-11-04T12:34:56Z"}
```

### Event Types

You can send multiple event types on one connection:

```csharp
yield return new SseItem<string>("data", eventType: "update");
yield return new SseItem<string>("warning", eventType: "alert");
```

Client can listen to specific types:
```javascript
eventSource.addEventListener('update', (e) => console.log('Update:', e.data));
eventSource.addEventListener('alert', (e) => console.log('Alert:', e.data));
```

## Performance Considerations

### Connection Limits
- Each SSE connection uses server resources (memory, thread)
- Modern servers can handle thousands of concurrent SSE connections
- Plan capacity based on expected concurrent users

### Scaling
- SSE connections are sticky to one server instance
- Use load balancer session affinity for multi-server deployments
- Consider Redis or message queue for pub/sub across servers

### Memory
- Use `IAsyncEnumerable` to avoid loading all data into memory
- `yield return` generates one item at a time
- Cancellation tokens prevent memory leaks

## Try These Experiments

1. **Open Multiple Tabs** - Each tab gets its own connection
2. **Network Tab** - Open F12, see the long-running request
3. **Disconnect Wi-Fi** - Watch automatic reconnection
4. **Close Tab** - Check server logs (connection closed)
5. **Modify Delays** - Change `Task.Delay(2000)` to see faster/slower updates

## Next Steps

### Modify the Code

Try changing:
- The delay between events
- The data being sent
- Add more event types
- Add query parameters to filter data
- Connect to a real data source (database, API)

### Add Authentication

```csharp
app.MapGet("/secure-events", (CancellationToken ct) => {
    // Your SSE code
}).RequireAuthorization();
```

### Production Considerations

1. **Add timeouts** - Don't let connections hang forever
2. **Rate limiting** - Prevent abuse
3. **Monitoring** - Track active connections
4. **Error handling** - Graceful degradation
5. **CORS** - Configure for cross-origin requests if needed

## Resources

- 📖 [MDN: Server-Sent Events](https://developer.mozilla.org/docs/Web/API/Server-sent_events)
- 📖 [What's New in ASP.NET Core 10](https://learn.microsoft.com/en-us/aspnet/core/release-notes/aspnetcore-10.0)
- 💻 [Official Sample](https://github.com/dotnet/AspNetCore.Docs/blob/main/aspnetcore/fundamentals/minimal-apis/10.0-samples/MinimalServerSentEvents/Program.cs)
- 📜 [SSE Specification](https://html.spec.whatwg.org/multipage/server-sent-events.html)

## Summary

**Server-Sent Events in .NET 10** makes it trivially easy to stream real-time data from server to client:

1. Use `IAsyncEnumerable<T>` with `yield return`
2. Call `TypedResults.ServerSentEvents(stream)`
3. Client uses standard `EventSource` API
4. Automatic JSON serialization
5. Built-in cancellation support
6. Perfect for live updates, notifications, and feeds

**That's it!** You now have a production-ready SSE endpoint with just a few lines of code.
