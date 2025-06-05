#!/usr/bin/env pwsh

Write-Host "🚀 Starting local CI/CD simulation for Flutter project..." -ForegroundColor Green

# Set error handling
$ErrorActionPreference = "Stop"

try {
    # Check if Flutter is installed
    Write-Host "📋 Checking Flutter installation..." -ForegroundColor Yellow
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Flutter is installed" -ForegroundColor Green
    Write-Host $flutterVersion

    # Get dependencies
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green

    # Run code generation
    Write-Host "🔧 Running code generation..." -ForegroundColor Yellow
    flutter packages pub run build_runner build --delete-conflicting-outputs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Code generation failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Code generation completed" -ForegroundColor Green

    # Check code formatting
    Write-Host "📝 Checking code formatting..." -ForegroundColor Yellow
    dart format --set-exit-if-changed .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Code formatting issues found. Run 'dart format .' to fix them." -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Code formatting is correct" -ForegroundColor Green

    # Run code analysis
    Write-Host "🔍 Running code analysis..." -ForegroundColor Yellow
    flutter analyze
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Code analysis found issues" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Code analysis passed" -ForegroundColor Green

    # Run unit tests
    Write-Host "🧪 Running unit tests..." -ForegroundColor Yellow
    flutter test --coverage
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Unit tests failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Unit tests passed" -ForegroundColor Green

    # Build web application
    Write-Host "🌐 Building web application..." -ForegroundColor Yellow
    flutter build web --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Web build failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Web build completed successfully" -ForegroundColor Green

    # Final success message
    Write-Host "" -ForegroundColor Green
    Write-Host "🎉 All CI/CD checks passed successfully!" -ForegroundColor Green
    Write-Host "📊 Coverage report available in coverage/lcov.info" -ForegroundColor Cyan
    Write-Host "🌐 Web build available in build/web/" -ForegroundColor Cyan

} catch {
    Write-Host "❌ CI/CD simulation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
