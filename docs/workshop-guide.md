# Workshop Facilitator Guide

**Workshop**: .NET 8 → 10 Performance Lab  
**Duration**: 2 hours (110 min + 10 min buffer)  
**Level**: Intermediate developers with basic .NET knowledge

## Pre-Workshop Checklist

### 1 Week Before
- [ ] Send prerequisites email to participants:
  - Windows 10/11 with PowerShell 5.1+
  - .NET 8 SDK: https://dotnet.microsoft.com/download/dotnet/8.0
  - .NET 10 SDK (or .NET 9 as placeholder for workshop)
  - Optional: Docker Desktop, bombardier/wrk
- [ ] Test all modules on clean Windows VM
- [ ] Verify all scripts run without errors
- [ ] Prepare presentation slides for Module 0

### 1 Day Before
- [ ] Clone repository to demo machine
- [ ] Run `.\shared\Scripts\check-prerequisites.ps1`
- [ ] Test screen sharing and audio
- [ ] Prepare backup plans for common issues

### Day Of
- [ ] Start 15 minutes early for tech check
- [ ] Have troubleshooting guide open
- [ ] Monitor chat/questions during hands-on time

## Timing Guide

| Time | Module | Activity | Facilitator Notes |
|------|--------|----------|-------------------|
| 0:00 | Intro | Welcome & setup check | Help stragglers install SDKs |
| 0:05 | Module 0 | Context setting | Present performance bar slides |
| 0:10 | Module 1 | Runtime demo | Watch for build failures |
| 0:30 | Module 2 | ASP.NET Core | Check load testing tools |
| 0:55 | Module 3 | C# 14 features | Most time-flexible module |
| 1:25 | Module 4 | EF Core | Database connection issues? |
| 1:40 | Module 5 | Containers | Skip if Docker not available |
| 1:50 | Module 6 | Migration planning | Q&A and wrap-up |
| 2:00 | End | Completion | Share feedback survey |

## Common Issues & Solutions

### Issue: PowerShell Execution Policy Blocks Scripts

**Symptom**: `cannot be loaded because running scripts is disabled`

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: .NET 10 SDK Not Available

**Symptom**: Participants ask where to download .NET 10

**Solution**: 
- Explain .NET 10 is hypothetical for workshop purposes
- Use .NET 9 Preview as placeholder for demonstrations
- Emphasize the *patterns* matter more than exact version

### Issue: Port Already in Use (Module 1 & 2)

**Symptom**: `Unable to bind to http://localhost:5000`

**Solution**:
```powershell
# Find process using port
netstat -ano | findstr :5000

# Kill process (replace <PID>)
taskkill /PID <PID> /F
```

### Issue: Load Testing Tool Not Found (Module 2)

**Symptom**: Scripts can't find bombardier or wrk

**Solution**:
- Show pre-provided results in Module 2 README
- Demonstrate with facilitator machine if time allows
- Skip load testing, focus on code explanations

### Issue: Docker Not Running (Module 5)

**Symptom**: `Cannot connect to the Docker daemon`

**Solution**:
- Mark Module 5 as optional
- Show pre-provided measurements
- Continue with other modules

### Issue: Database Connection Failure (Module 4)

**Symptom**: EF Core can't connect to LocalDB/PostgreSQL

**Solution**:
- Fall back to SQLite (no installation needed)
- Scripts auto-detect and create in-memory database
- Focus on ExecuteUpdate syntax, not database choice

### Issue: Varying Performance Results

**Symptom**: Participants see different numbers than expected

**Solution**:
- Explain hardware variance is expected (±10%)
- Emphasize *relative* improvements (8 vs 10) matter
- Document baseline hardware in results

## Teaching Tips

### Module 0 (5 min)
- **Goal**: Set context, not overwhelm with details
- **Key Message**: "We'll measure real numbers, not marketing claims"
- **Skip**: Deep technical details (save for relevant modules)

### Module 1 (20 min)
- **Goal**: Show cold-start differences tangibly
- **Hands-On**: Let participants run scripts themselves
- **Watch For**: Build failures (missing SDKs, network issues)
- **Time Saver**: Use pre-built artifacts if builds are slow

### Module 2 (25 min)
- **Goal**: Demonstrate ASP.NET Core 10 features
- **Hands-On**: Load testing is optional, code reading is key
- **Watch For**: Load testing tool availability
- **Time Saver**: Show pre-provided results, focus on code patterns

### Module 3 (30 min)
- **Goal**: Show maintainability wins for large codebases
- **Hands-On**: Participants read code, not write from scratch
- **Watch For**: Participants getting lost in 6 examples
- **Time Saver**: Focus on 2-3 most relevant examples if time is tight

### Module 4 (15 min)
- **Goal**: EF Core 10 query improvements
- **Hands-On**: Run queries, see timing differences
- **Watch For**: Database connection issues
- **Time Saver**: Use SQLite fallback, pre-seeded data

### Module 5 (10 min)
- **Goal**: Container size/startup comparison
- **Hands-On**: Optional if Docker unavailable
- **Watch For**: Docker not running, image build slowness
- **Time Saver**: Show pre-provided measurements, skip builds

### Module 6 (5 min)
- **Goal**: Migration decision framework
- **Hands-On**: Read decision matrix, discuss priorities
- **Watch For**: Running over time (this is the buffer)
- **Time Saver**: Assign as homework if time is tight

## Pacing Strategies

### Running Ahead of Schedule
- Dive deeper into C# 14 features (Module 3)
- Show additional EF Core 10 patterns (Module 4)
- Discuss real-world migration stories
- Take questions and facilitate discussion

### Running Behind Schedule
- Skip Module 5 (Containers) - show pre-provided results
- Shorten Module 3 to 3 examples instead of 6
- Assign Module 6 (Migration Planning) as homework
- Focus on Modules 1-2 (highest priority)

## Post-Workshop

### Feedback Collection
- Share feedback survey (Google Forms, etc.)
- Ask: "Which module was most valuable?"
- Ask: "What was confusing or needs improvement?"

### Follow-Up Resources
- Share GitHub repository link
- Provide contact for questions
- Share additional reading on .NET 10 features
- Offer office hours for migration planning

## Troubleshooting Quick Reference

| Problem | Quick Fix |
|---------|-----------|
| Script won't run | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Port in use | `taskkill /PID <PID> /F` |
| SDK not found | Install from dotnet.microsoft.com |
| Docker not running | Start Docker Desktop or skip Module 5 |
| Load test tool missing | Use pre-provided results |
| Database connection fails | Fall back to SQLite |
| Slow builds | Use pre-built artifacts in artifacts/ folder |

## Success Metrics

By end of workshop, participants should be able to:
- ✅ Run measurement scripts independently
- ✅ Explain 20%+ cold-start improvement
- ✅ Identify 2-3 C# 14 features for their codebase
- ✅ Prioritize services for migration using decision matrix

---

**Questions during workshop?** Check this guide first, then improvise with context.
