#!/bin/bash

echo "🚀 Starting local CI/CD simulation for Flutter project..."

# Set error handling
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if Flutter is installed
echo -e "${YELLOW}📋 Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Flutter is installed${NC}"
flutter --version

# Get dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
if flutter pub get; then
    echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
else
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

# Run code generation
echo -e "${YELLOW}🔧 Running code generation...${NC}"
if flutter packages pub run build_runner build --delete-conflicting-outputs; then
    echo -e "${GREEN}✅ Code generation completed${NC}"
else
    echo -e "${RED}❌ Code generation failed${NC}"
    exit 1
fi

# Check code formatting
echo -e "${YELLOW}📝 Checking code formatting...${NC}"
if dart format --set-exit-if-changed .; then
    echo -e "${GREEN}✅ Code formatting is correct${NC}"
else
    echo -e "${RED}❌ Code formatting issues found. Run 'dart format .' to fix them.${NC}"
    exit 1
fi

# Run code analysis
echo -e "${YELLOW}🔍 Running code analysis...${NC}"
if flutter analyze; then
    echo -e "${GREEN}✅ Code analysis passed${NC}"
else
    echo -e "${RED}❌ Code analysis found issues${NC}"
    exit 1
fi

# Run unit tests
echo -e "${YELLOW}🧪 Running unit tests...${NC}"
if flutter test --coverage; then
    echo -e "${GREEN}✅ Unit tests passed${NC}"
else
    echo -e "${RED}❌ Unit tests failed${NC}"
    exit 1
fi

# Build web application
echo -e "${YELLOW}🌐 Building web application...${NC}"
if flutter build web --release; then
    echo -e "${GREEN}✅ Web build completed successfully${NC}"
else
    echo -e "${RED}❌ Web build failed${NC}"
    exit 1
fi

# Final success message
echo ""
echo -e "${GREEN}🎉 All CI/CD checks passed successfully!${NC}"
echo -e "${CYAN}📊 Coverage report available in coverage/lcov.info${NC}"
echo -e "${CYAN}🌐 Web build available in build/web/${NC}"
