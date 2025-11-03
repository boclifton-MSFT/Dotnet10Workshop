#!/bin/bash
# Prerequisites Checker for .NET 8 → 10 Performance Lab Workshop (Bash version)

set -e

echo "🔍 Checking workshop prerequisites..."
echo ""

PASS_COUNT=0
ERROR_COUNT=0
WARN_COUNT=0

# Check bash version
BASH_VERSION_NUM=$(echo $BASH_VERSION | cut -d. -f1)
if [ "$BASH_VERSION_NUM" -ge 4 ]; then
    echo "✅ Bash $BASH_VERSION found"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "❌ Bash 4+ required, found $BASH_VERSION"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# Check .NET 8 SDK
if dotnet --list-sdks 2>/dev/null | grep -q "^8\.0"; then
    SDK8=$(dotnet --list-sdks | grep "^8\.0" | head -n1 | cut -d' ' -f1)
    echo "✅ .NET 8 SDK found: $SDK8"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "❌ .NET 8 SDK not found"
    echo "   Download from: https://dotnet.microsoft.com/download/dotnet/8.0"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# Check .NET 10 SDK (hypothetical)
if dotnet --list-sdks 2>/dev/null | grep -q "^10\.0"; then
    SDK10=$(dotnet --list-sdks | grep "^10\.0" | head -n1 | cut -d' ' -f1)
    echo "✅ .NET 10 SDK found: $SDK10"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "⚠️  .NET 10 SDK not found (hypothetical for workshop demo)"
    echo "   Note: For workshop purposes, we'll use .NET 9 as .NET 10 placeholder"
    WARN_COUNT=$((WARN_COUNT + 1))
fi

# Check Git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    echo "✅ Git found: $GIT_VERSION"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "⚠️  Git not found (recommended)"
    WARN_COUNT=$((WARN_COUNT + 1))
fi

# Check Docker (optional)
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    echo "✅ Docker found: $DOCKER_VERSION (Module 5 available)"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "⚠️  Docker not found (Module 5 will be skipped)"
    WARN_COUNT=$((WARN_COUNT + 1))
fi

# Check load testing tools (optional)
if command -v bombardier &> /dev/null; then
    echo "✅ bombardier found (Module 2 load testing available)"
    PASS_COUNT=$((PASS_COUNT + 1))
elif command -v wrk &> /dev/null; then
    echo "✅ wrk found (Module 2 load testing available)"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "⚠️  No load testing tool found (Module 2 will use pre-provided results)"
    echo "   Install bombardier: https://github.com/codesenberg/bombardier/releases"
    WARN_COUNT=$((WARN_COUNT + 1))
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Passed: $PASS_COUNT"
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "❌ Errors: $ERROR_COUNT"
fi
if [ "$WARN_COUNT" -gt 0 ]; then
    echo "⚠️  Warnings: $WARN_COUNT"
fi

echo ""

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "🎉 You're ready to start the workshop!"
    echo ""
    echo "Next steps:"
    echo "  1. cd modules/module0-warmup"
    echo "  2. Read the README.md to understand the workshop goals"
    exit 0
else
    echo "⚠️  Please install the missing required prerequisites before starting."
    exit 1
fi
