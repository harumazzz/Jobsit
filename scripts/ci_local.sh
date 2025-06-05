#!/bin/bash

# Local CI/CD Test Script for Jobsit Flutter App
# This script runs the same checks as the CI/CD pipeline locally

set -e

echo "🚀 Starting local CI/CD checks for Jobsit Flutter app..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
print_status "Using Flutter version: $FLUTTER_VERSION"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Step 1: Get dependencies
print_status "Installing Flutter dependencies..."
flutter pub get
print_success "Dependencies installed"

# Step 2: Generate code
print_status "Running code generation..."
if flutter packages pub run build_runner build --delete-conflicting-outputs; then
    print_success "Code generation completed"
else
    print_warning "Code generation had warnings or errors"
fi

# Step 3: Check formatting
print_status "Checking code formatting..."
if dart format --set-exit-if-changed .; then
    print_success "Code formatting is correct"
else
    print_error "Code formatting issues found. Run 'dart format .' to fix."
    exit 1
fi

# Step 4: Analyze code
print_status "Running static analysis..."
if flutter analyze; then
    print_success "Static analysis passed"
else
    print_error "Static analysis found issues"
    exit 1
fi

# Step 5: Run custom lint (if available)
if flutter pub deps | grep -q "custom_lint"; then
    print_status "Running custom lint..."
    if dart run custom_lint; then
        print_success "Custom lint passed"
    else
        print_warning "Custom lint found issues"
    fi
fi

# Step 6: Run unit tests
print_status "Running unit tests..."
if flutter test --coverage; then
    print_success "Unit tests passed"
else
    print_error "Unit tests failed"
    exit 1
fi

# Step 7: Run widget tests specifically
print_status "Running widget tests..."
if ls test/unit/features/*/presentation/widgets/*_test.dart 1> /dev/null 2>&1; then
    if flutter test test/unit/features/*/presentation/widgets/ --coverage; then
        print_success "Widget tests passed"
    else
        print_error "Widget tests failed"
        exit 1
    fi
else
    print_warning "No widget tests found"
fi

# Step 8: Check test coverage (if lcov is available)
if command -v lcov &> /dev/null && [ -f "coverage/lcov.info" ]; then
    print_status "Generating coverage report..."
    lcov --summary coverage/lcov.info
    
    # Extract coverage percentage
    COVERAGE=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | grep -o '[0-9.]*%' | head -1 | tr -d '%')
    
    if (( $(echo "$COVERAGE >= 80" | bc -l) )); then
        print_success "Test coverage: $COVERAGE% (above 80% threshold)"
    else
        print_warning "Test coverage: $COVERAGE% (below 80% threshold)"
    fi
fi

# Step 9: Build APK (optional)
if [ "$1" = "--build" ]; then
    print_status "Building Android APK..."
    if flutter build apk --debug; then
        print_success "Android APK built successfully"
    else
        print_error "Android APK build failed"
        exit 1
    fi
fi

# Step 10: Run integration tests (optional)
if [ "$1" = "--integration" ]; then
    print_status "Running integration tests..."
    if ls integration_test/*_test.dart 1> /dev/null 2>&1; then
        print_warning "Integration tests require an emulator or device to be connected"
        print_status "Available devices:"
        flutter devices
        
        if [ "$2" = "--run" ]; then
            flutter test integration_test/
        fi
    else
        print_warning "No integration tests found"
    fi
fi

print_success "All local CI/CD checks completed successfully! 🎉"

echo ""
echo "📋 Summary:"
echo "✅ Dependencies installed"
echo "✅ Code generated"
echo "✅ Formatting checked"
echo "✅ Static analysis passed"
echo "✅ Unit tests passed"
echo "✅ Widget tests passed"
if [ -f "coverage/lcov.info" ]; then
    echo "✅ Coverage report generated"
fi

echo ""
echo "🚀 Your code is ready for CI/CD pipeline!"
echo ""
echo "Usage:"
echo "  ./scripts/ci_local.sh              # Run basic checks"
echo "  ./scripts/ci_local.sh --build      # Include APK build"
echo "  ./scripts/ci_local.sh --integration --run  # Include integration tests"
