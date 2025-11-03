# Participant Guide

**Workshop**: .NET 8 → 10 Performance Lab  
**Duration**: 2 hours  
**Your Goal**: Measure real performance improvements and learn when to migrate

## What to Expect

This is a **hands-on workshop**. You'll:
- ✅ Run code on your machine
- ✅ Measure performance metrics
- ✅ See real numbers, not marketing claims
- ✅ Learn when .NET 10 matters for your projects

## Learning Objectives

By the end of this workshop, you will be able to:

1. **Measure Runtime Performance**
   - Compare cold-start times between .NET 8 and .NET 10
   - Understand Native AOT trade-offs
   - Quantify 20%+ improvement

2. **Evaluate API Improvements**
   - Demonstrate 15%+ RPS gains in ASP.NET Core 10
   - Configure output caching and rate limiting
   - Measure p95 latency reductions

3. **Apply Language Features**
   - Identify C# 14 features that reduce boilerplate
   - Map features to maintainability wins
   - Recognize when to use each feature

4. **Optimize Data Access**
   - Use EF Core 10 ExecuteUpdate with JSON paths
   - Measure 30%+ query time reduction
   - Avoid unnecessary round-trips

5. **Compare Container Deployments**
   - Measure 10%+ image size reduction
   - Demonstrate faster container startup
   - Understand deployment velocity impact

6. **Plan Your Migration**
   - Prioritize services using decision matrix
   - Calculate expected ROI
   - Create risk-managed rollout strategy

## Note-Taking Template

Use this template to capture key learnings during each module:

### Module 1: Runtime Performance
- **My cold-start baseline (.NET 8)**: _______ ms
- **My cold-start with .NET 10**: _______ ms
- **Improvement**: _______ %
- **Why this matters for my project**: _______________________________________

### Module 2: ASP.NET Core
- **My API baseline RPS (.NET 8)**: _______ req/sec
- **My API with .NET 10**: _______ req/sec
- **New feature I'll use**: _______________________________________

### Module 3: C# 14 Features
- **Feature 1 I'll apply**: _______________________________________
- **Feature 2 I'll apply**: _______________________________________
- **Expected benefit**: _______________________________________

### Module 4: EF Core
- **My query time baseline (.NET 8)**: _______ ms
- **My query time with .NET 10**: _______ ms
- **Where I'll use JSON path updates**: _______________________________________

### Module 5: Containers
- **My image size baseline (.NET 8)**: _______ MB
- **My image size with .NET 10**: _______ MB
- **Deployment velocity impact**: _______________________________________

### Module 6: Migration Planning
- **My top 3 services to migrate**:
  1. _______________________________________
  2. _______________________________________
  3. _______________________________________
- **Expected ROI**: _______________________________________

## Completion Checklist

Track your progress through the workshop:

- [ ] **Prerequisites Verified** - All SDKs installed
- [ ] **Module 0 Complete** - Understand performance bar
- [ ] **Module 1 Complete** - Measured cold-start improvements
- [ ] **Module 2 Complete** - Measured API throughput gains
- [ ] **Module 3 Complete** - Identified 2+ C# 14 features to use
- [ ] **Module 4 Complete** - Measured EF Core query improvements
- [ ] **Module 5 Complete** - Compared container sizes (or reviewed results)
- [ ] **Module 6 Complete** - Created migration priority list

## Tips for Success

### Before the Workshop
- ✅ Install prerequisites 1 day early (not day-of!)
- ✅ Run `.\shared\Scripts\check-prerequisites.ps1`
- ✅ Test that your PowerShell scripts can execute
- ✅ Have Visual Studio Code or Visual Studio ready

### During the Workshop
- ✅ Follow along at your own pace (modules are independent)
- ✅ Don't panic if something doesn't work (ask for help!)
- ✅ Focus on patterns, not perfect execution
- ✅ Take notes on what applies to your work

### After the Workshop
- ✅ Review your notes within 24 hours
- ✅ Try one C# 14 feature in your codebase this week
- ✅ Benchmark one of your APIs to establish baseline
- ✅ Share learnings with your team

## Common Questions

### Q: What if I fall behind?
**A**: Modules are independent! Skip ahead or focus on what's relevant to you.

### Q: What if my numbers are different?
**A**: Hardware variance is expected (±10%). Focus on *relative* improvements (8 vs 10).

### Q: What if I don't have Docker?
**A**: Module 5 is optional. Review the pre-provided measurements instead.

### Q: What if my scripts don't run?
**A**: Check execution policy: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Q: Can I run modules in different order?
**A**: Yes! Except Module 0 (start here) and Module 6 (needs results from others).

### Q: What if .NET 10 isn't released yet?
**A**: We use .NET 9 Preview as a placeholder to demonstrate patterns.

## After Workshop: Next Steps

1. **Assess Your Services** (1 hour)
   - List your APIs and their traffic levels
   - Use Module 6 decision matrix
   - Identify top 3 migration candidates

2. **Benchmark Baseline** (2 hours)
   - Run Module 1 scripts against your API
   - Document cold-start times
   - Measure current RPS and latency

3. **Pilot Migration** (1 week)
   - Pick one non-critical API
   - Upgrade to .NET 10
   - Measure improvements
   - Document lessons learned

4. **Apply Language Features** (ongoing)
   - Review Module 3 examples
   - Identify boilerplate in your code
   - Refactor with C# 14 features
   - Track maintainability wins

5. **Plan Rollout** (1 week)
   - Present findings to team
   - Get buy-in for migration strategy
   - Create phased rollout plan
   - Define success metrics

## Resources

### Official Documentation
- .NET 8: https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-8
- .NET 10: https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-10 (hypothetical)
- C# 14: https://learn.microsoft.com/en-us/dotnet/csharp/whats-new/csharp-14

### Workshop Materials
- GitHub Repository: [Link provided by facilitator]
- Facilitator Contact: [Provided by facilitator]
- Feedback Survey: [Link provided at end]

## Feedback

Your feedback helps improve this workshop!

**What worked well?**


**What was confusing?**


**What would you add/remove?**


**Would you recommend this to a colleague?** [ ] Yes [ ] No


---

**Have fun and happy coding!** 🚀
