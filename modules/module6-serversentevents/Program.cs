using System.Net.ServerSentEvents;
using System.Runtime.CompilerServices;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Serve static HTML demo page
app.MapGet("/", () => Results.Content("""
<!DOCTYPE html>
<html>
<head>
    <title>Server-Sent Events Demo - .NET 10</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 1200px; margin: 50px auto; padding: 20px; }
        h1 { color: #0066cc; }
        .demo-section { background: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 8px; }
        .heart-rate { font-size: 48px; font-weight: bold; color: #cc0000; margin: 10px 0; }
        button { background: #0066cc; color: white; border: none; padding: 10px 20px; 
                 border-radius: 4px; cursor: pointer; margin: 5px; }
        button:hover { background: #0052a3; }
        button:disabled { background: #999; cursor: not-allowed; }
        .status { padding: 5px 10px; border-radius: 4px; display: inline-block; margin: 10px 0; }
        .status.connected { background: #00cc66; color: white; }
        .status.disconnected { background: #cc0000; color: white; }
        .log { background: white; padding: 10px; max-height: 200px; overflow-y: auto; 
               border: 1px solid #ddd; font-family: monospace; font-size: 12px; }
        .log-entry { padding: 2px 0; border-bottom: 1px solid #eee; }
        .endpoint-path { color: #666; font-family: monospace; }
    </style>
</head>
<body>
    <h1>🚀 .NET 10 Server-Sent Events Demo</h1>
    <p>This demonstrates the new <code>TypedResults.ServerSentEvents</code> feature in ASP.NET Core 10.</p>
    
    <!-- String Endpoint Demo -->
    <div class="demo-section">
        <h2>1. String Stream <span class="endpoint-path">(/string-item)</span></h2>
        <p>Streams plain text messages with heart rate data every 2 seconds.</p>
        <div id="status1" class="status disconnected">Disconnected</div>
        <div class="heart-rate" id="heartRate1">-- bpm</div>
        <button id="btn1-start">Start</button>
        <button id="btn1-stop" disabled>Stop</button>
        <h4>Event Log:</h4>
        <div class="log" id="log1"></div>
    </div>

    <!-- JSON Endpoint Demo -->
    <div class="demo-section">
        <h2>2. JSON Stream <span class="endpoint-path">(/json-item)</span></h2>
        <p>Streams JSON objects automatically serialized by ASP.NET Core.</p>
        <div id="status2" class="status disconnected">Disconnected</div>
        <div class="heart-rate" id="heartRate2">-- bpm</div>
        <button id="btn2-start">Start</button>
        <button id="btn2-stop" disabled>Stop</button>
        <h4>Event Log:</h4>
        <div class="log" id="log2"></div>
    </div>

    <!-- SseItem Endpoint Demo -->
    <div class="demo-section">
        <h2>3. SseItem Stream <span class="endpoint-path">(/sse-item)</span></h2>
        <p>Streams SseItem objects with event types and reconnection configuration.</p>
        <div id="status3" class="status disconnected">Disconnected</div>
        <div class="heart-rate" id="heartRate3">-- bpm</div>
        <button id="btn3-start">Start</button>
        <button id="btn3-stop" disabled>Stop</button>
        <h4>Event Log:</h4>
        <div class="log" id="log3"></div>
    </div>

    <script>
        // Demo 1: String Stream
        let eventSource1;
        document.getElementById('btn1-start').onclick = () => {
            eventSource1 = new EventSource('/string-item');
            
            eventSource1.addEventListener('heartRate', (e) => {
                document.getElementById('heartRate1').textContent = e.data;
                addLog('log1', `Event: ${e.data}`);
            });

            eventSource1.onopen = () => {
                document.getElementById('status1').className = 'status connected';
                document.getElementById('status1').textContent = 'Connected';
                document.getElementById('btn1-start').disabled = true;
                document.getElementById('btn1-stop').disabled = false;
                addLog('log1', 'Connection opened');
            };

            eventSource1.onerror = () => {
                document.getElementById('status1').className = 'status disconnected';
                document.getElementById('status1').textContent = 'Disconnected';
                addLog('log1', 'Connection error');
            };
        };

        document.getElementById('btn1-stop').onclick = () => {
            if (eventSource1) eventSource1.close();
            document.getElementById('status1').className = 'status disconnected';
            document.getElementById('status1').textContent = 'Disconnected';
            document.getElementById('btn1-start').disabled = false;
            document.getElementById('btn1-stop').disabled = true;
            addLog('log1', 'Connection closed');
        };

        // Demo 2: JSON Stream
        let eventSource2;
        document.getElementById('btn2-start').onclick = () => {
            eventSource2 = new EventSource('/json-item');
            
            eventSource2.addEventListener('heartRate', (e) => {
                const data = JSON.parse(e.data);
                document.getElementById('heartRate2').textContent = `${data.heartRate} bpm`;
                addLog('log2', `Event: ${JSON.stringify(data)}`);
            });

            eventSource2.onopen = () => {
                document.getElementById('status2').className = 'status connected';
                document.getElementById('status2').textContent = 'Connected';
                document.getElementById('btn2-start').disabled = true;
                document.getElementById('btn2-stop').disabled = false;
                addLog('log2', 'Connection opened');
            };

            eventSource2.onerror = () => {
                document.getElementById('status2').className = 'status disconnected';
                document.getElementById('status2').textContent = 'Disconnected';
                addLog('log2', 'Connection error');
            };
        };

        document.getElementById('btn2-stop').onclick = () => {
            if (eventSource2) eventSource2.close();
            document.getElementById('status2').className = 'status disconnected';
            document.getElementById('status2').textContent = 'Disconnected';
            document.getElementById('btn2-start').disabled = false;
            document.getElementById('btn2-stop').disabled = true;
            addLog('log2', 'Connection closed');
        };

        // Demo 3: SseItem Stream
        let eventSource3;
        document.getElementById('btn3-start').onclick = () => {
            eventSource3 = new EventSource('/sse-item');
            
            eventSource3.addEventListener('heartRate', (e) => {
                document.getElementById('heartRate3').textContent = `${e.data} bpm`;
                addLog('log3', `Event ID: ${e.lastEventId || 'none'}, Data: ${e.data}`);
            });

            eventSource3.onopen = () => {
                document.getElementById('status3').className = 'status connected';
                document.getElementById('status3').textContent = 'Connected';
                document.getElementById('btn3-start').disabled = true;
                document.getElementById('btn3-stop').disabled = false;
                addLog('log3', 'Connection opened');
            };

            eventSource3.onerror = () => {
                document.getElementById('status3').className = 'status disconnected';
                document.getElementById('status3').textContent = 'Disconnected';
                addLog('log3', 'Connection error');
            };
        };

        document.getElementById('btn3-stop').onclick = () => {
            if (eventSource3) eventSource3.close();
            document.getElementById('status3').className = 'status disconnected';
            document.getElementById('status3').textContent = 'Disconnected';
            document.getElementById('btn3-start').disabled = false;
            document.getElementById('btn3-stop').disabled = true;
            addLog('log3', 'Connection closed');
        };

        function addLog(logId, message) {
            const log = document.getElementById(logId);
            const entry = document.createElement('div');
            entry.className = 'log-entry';
            entry.textContent = `${new Date().toLocaleTimeString()}: ${message}`;
            log.insertBefore(entry, log.firstChild);
            
            // Keep only last 10 entries
            while (log.children.length > 10) {
                log.removeChild(log.lastChild);
            }
        }
    </script>
</body>
</html>
""", "text/html"));

app.MapGet("/string-item", (CancellationToken cancellationToken) =>
{
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
});

app.MapGet("/json-item", (CancellationToken cancellationToken) =>
{
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
});

app.MapGet("sse-item", (CancellationToken cancellationToken) =>
{
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
});

app.Run();
