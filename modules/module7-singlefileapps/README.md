# Module 7: Single File Apps

## Overview

.NET 10 introduces **Single File Apps** (also called file-based apps), a feature that allows you to write, build, and run complete C# applications from a single `.cs` file without needing a project file (`.csproj`). This dramatically simplifies creating small utilities, scripts, and prototypes.

## Key Features

### 1. No Project File Required
Run C# code directly with `dotnet run Program.cs` - no need to create a solution or project structure.

### 2. Special Preprocessor Directives
Single file apps use `#:` directives to configure the build:

```csharp
#!/usr/bin/env dotnet                                    // Shebang for Unix execution
#:sdk Microsoft.NET.Sdk.Web                              // Specify SDK type
#:property PublishAot=false                              // Set project properties
#:package Microsoft.EntityFrameworkCore.Sqlite@10.0.0    // Add NuGet packages
```

### 3. Native AOT by Default
File-based apps target Native AOT by default for faster startup and smaller deployment size. Use `#:property PublishAot=false` if your dependencies (like EF Core) aren't AOT-compatible.

### 4. Publishing Support
Single file apps can be published to native executables:
```bash
dotnet publish SingleFileApi.cs -o ./publish
```

### 5. Direct Execution (Unix/macOS)
With proper shebang and execute permissions:
```bash
chmod +x SingleFileApi.cs
./SingleFileApi.cs
```

## What's in This Module

This module demonstrates a complete **ASP.NET Core Minimal API** with:
- ✅ SQLite database using EF Core 10
- ✅ Full CRUD operations (Create, Read, Update, Delete)
- ✅ OpenAPI document generation
- ✅ Dependency injection
- ✅ No `.csproj` file needed

## Files

- **`SingleFileApi.cs`** - Complete minimal API with database in a single file
- **`SingleFileApi.http`** - HTTP request collection for testing all endpoints
- **`todos.db`** - SQLite database (created automatically on first run)

## Running the Application

### Start the API
```powershell
dotnet run SingleFileApi.cs
```

The API will start on `http://localhost:5000`

### Test the Endpoints
Open `SingleFileApi.http` in VS Code and click "Send Request" above any test, or use curl:

```bash
# Get all todos
curl http://localhost:5000/todos

# Create a todo
curl -X POST http://localhost:5000/todos -H "Content-Type: application/json" -d '{"title":"Learn .NET 10","isComplete":false}'

# Get todo by ID
curl http://localhost:5000/todos/1

# Update a todo
curl -X PUT http://localhost:5000/todos/1 -H "Content-Type: application/json" -d '{"title":"Learn .NET 10","isComplete":true}'

# Delete a todo
curl -X DELETE http://localhost:5000/todos/1
```

### View OpenAPI Documentation
Navigate to `http://localhost:5000/openapi/v1.json` (development environment only)

## Publishing

Create a standalone executable:
```powershell
dotnet publish SingleFileApi.cs -c Release -o ./publish
```

The published executable will be in the `publish` folder and can run independently.

## When to Use Single File Apps

**✅ Good for:**
- Quick prototypes and demos
- Small utility APIs
- Learning and experimentation
- Command-line tools
- Scripts and automation

**❌ Not ideal for:**
- Large, complex applications
- Projects requiring multiple files and organization
- Team projects with many contributors
- Applications needing extensive configuration

## Key Concepts Demonstrated

1. **Top-level statements** - No `Program` class or `Main` method needed
2. **Minimal APIs** - Lightweight HTTP APIs without controllers
3. **EF Core integration** - Database access with Entity Framework
4. **Dependency injection** - Built-in DI container usage
5. **File-based configuration** - Using preprocessor directives instead of project files

## Comparison with Traditional Projects

### Traditional Project
```
MyApi/
├── MyApi.csproj
├── Program.cs
├── Models/
│   └── Todo.cs
├── Data/
│   └── TodoDb.cs
└── appsettings.json
```

### Single File App
```
SingleFileApi.cs  ← Everything in one file!
```

## Additional Resources

- [File-based apps documentation](https://learn.microsoft.com/en-us/dotnet/csharp/tour-of-csharp/overview#file-based-apps)
- [What's new in .NET 10 SDK](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-10/sdk#file-based-apps-enhancements)
- [ASP.NET Core Minimal APIs](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/minimal-apis)
- [EF Core with SQLite](https://learn.microsoft.com/en-us/ef/core/providers/sqlite/)
