# Jobsit

A comprehensive job search Flutter application that enables users to search, browse, and apply for jobs with a modern, intuitive interface. The app features user authentication, profile management, job tracking, and personalized job recommendations.

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [How to Run](#how-to-run)
- [Build & Release](#build--release)
- [Testing](#testing)
- [CI/CD](#cicd)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Author](#author)

## Features

- **User Authentication**
  - Login and registration with email
  - OTP verification system
  - Password reset functionality
  - Secure session management

- **Job Search & Browsing**
  - Advanced job search with filters
  - Job category browsing
  - Job details and requirements view
  - Company information display

- **Profile Management**
  - Personal information management
  - Job preferences settings
  - CV/Resume upload and management
  - Profile completion tracking

- **Job Tracking**
  - Applied jobs history
  - Saved jobs collection
  - Application status tracking
  - Job recommendations

- **Notifications & Settings**
  - Email notification preferences
  - Job alert configurations
  - Search visibility settings
  - Account privacy controls

- **Multi-language Support**
  - English and Vietnamese localization
  - Dynamic language switching

## Screenshots

[Figma](https://www.figma.com/design/a00WRcFWV0wn3hzz0lBdmp/JobsIT---Project?node-id=3590-4485&t=CxefdFnxR1uHhDc0-0)

## Getting Started

### Prerequisites

- **Flutter SDK**: ^3.32.0 ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Compatible with Dart 3.8.0+
- **Development Environment**: 
  - Visual Studio Code
  - Justfile
- **Backend**: Java Runtime Environment and Docker

### Setup

```bash
# Clone the repository
git clone https://github.com/harumazzz/Jobsit
cd Jobsit

# Install dependencies
flutter pub get

# Generate code (for freezed, json_annotation, etc.)
dart run build_runner build

# Start the backend server (optional for local development)
java -jar backend/jobsit.jar
```

## Project Structure

```
/lib
  /core              # Core utilities, constants, and base classes
    /constants       # App constants, colors, strings
    /errors          # Error handling and exceptions
    /network         # HTTP client and API configurations
    /utils           # Utility functions and helpers
  /features          # Feature-first architecture
    /auth            # Authentication feature
    /jobs            # Job search and management
    /profile         # User profile management
    /notifications   # Notification handling
  /shared            # Shared widgets and components
    /widgets         # Reusable UI components
    /providers       # Global state providers
  /i18n              # Internationalization files
/assets
  /images            # App images and icons
/test
  /unit              # Unit tests
  /widget            # Widget tests
/integration_test    # Integration tests
/documentation       # Architecture and development docs
```

**Architecture**: Clean Architecture with MVVM pattern
- **State Management**: Riverpod for dependency injection and state management
- **Navigation**: Go Router for declarative routing
- **HTTP Client**: Dio for API communication
- **Local Storage**: Flutter Secure Storage for sensitive data
- **Code Generation**: Freezed for immutable data classes and JSON serialization

## Configuration

### Environment Setup

The app uses environment-specific configurations. For local development:

1. **API Configuration**: Update API endpoints in `lib/core/network/`
2. **Backend Server**: Start the local Java backend server:
   ```bash
   java -jar backend/jobsit.jar
   ```

### Dependencies

Key dependencies include:
- `riverpod` - State management and dependency injection
- `go_router` - Navigation and routing
- `dio` - HTTP client for API calls
- `flutter_secure_storage` - Secure local storage
- `freezed` - Code generation for data classes
- `flutter_localizations` - Internationalization support

## How to Run

### Development Mode

```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d chrome          # Web
flutter run -d android         # Android emulator
flutter run -d ios            # iOS simulator (macOS only)

# Run with flavor (if configured)
flutter run --flavor dev
```

### Local CI Scripts

```powershell
# Windows PowerShell
.\scripts\ci_local.ps1

# Or bash
./scripts/ci_local.sh
```

## Build & Release

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# iOS build (macOS only)
flutter build ios --release
```

### Web

```bash
# Web build (Development only - not included in CI/CD)
flutter build web --release
```

**Note**: The CI/CD pipeline focuses on Android APK builds. Web builds are available for local development but not automated in the deployment pipeline.

## Testing

### Run Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget

# Integration tests
flutter test integration_test

# Run specific test file
flutter test test/unit/auth_test.dart
```

### Test Coverage

```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Integration Tests

The project includes comprehensive integration tests:

```bash
# Run integration tests
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

# Or use PowerShell script
.\run_integration_tests.ps1
```

## CI/CD

The project uses **GitHub Actions** for continuous integration and deployment:

### Workflows

- **Main CI/CD Pipeline** (`.github/workflows/flutter_ci.yml`)
  - Automated testing on push and PR
  - Android APK build and deployment
  - Multi-platform testing

- **Pull Request Checks** (`.github/workflows/pr_checks.yml`)
  - Code quality checks
  - Test execution
  - Android APK build verification

- **Nightly Builds** (`.github/workflows/nightly.yml`)
  - Daily automated Android APK builds
  - Dependency updates check
  - Comprehensive testing

- **Dependency Updates** (`.github/workflows/dependency_updates.yml`)
  - Weekly automated dependency updates (Mondays at 6 AM UTC)
  - Android build compatibility verification
  - Automatic PR creation for dependency updates

### Build Artifacts

The CI/CD pipeline produces the following artifacts:

- **Android APK**: Released APK files for distribution and testing
- **Test Coverage Reports**: Code coverage analysis uploaded to Codecov
- **Nightly Reports**: Daily build status and performance metrics

### Deployment Strategy

- **Staging**: APK builds from `develop` branch are deployed to staging environment
- **Production**: APK builds from `main` branch create GitHub releases with attached APK files
- **Testing**: All PR builds generate APK artifacts for testing (retained for 30 days)
- **Nightly**: Daily builds create APK artifacts (retained for 7 days)

### Platform Focus

This project is **Android-focused** with the following considerations:

- ✅ **Android APK**: Full CI/CD pipeline with automated builds and releases
- ⚠️ **Web**: Available for local development only (`flutter build web`)
- ⚠️ **iOS**: Manual builds only (`flutter build ios` on macOS)
- ⚠️ **Desktop**: Manual builds only (Windows/Linux/macOS)

### Local CI Scripts

- `scripts/ci_local.ps1` - Windows PowerShell CI script
- `scripts/ci_local.sh` - Bash CI script
- `scripts/ci_local_clean.ps1` - Clean build script

## Contributing

### Code Style

- Follow [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- Use `flutter format` for code formatting
- Run `flutter analyze` for static analysis
- Use `custom_lint` for additional code quality checks

### Commit Guidelines

- Use conventional commits format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Example: `feat(auth): add OTP verification`

### Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and add tests
4. Run tests and ensure they pass
5. Commit your changes with conventional commit format
6. Push to your fork and submit a pull request

## Troubleshooting

### Common Issues

**Flutter Version Issues**
```bash
# Check Flutter version
flutter --version

# Upgrade Flutter
flutter upgrade

# Clean and rebuild
flutter clean && flutter pub get
```

**Build Issues**
```bash
# Clean build cache
flutter clean
cd android && ./gradlew clean && cd ..

# Rebuild
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Android Build Issues**
- Ensure Android SDK is properly installed
- Check `android/local.properties` for correct SDK path
- Verify Gradle version compatibility

**iOS Build Issues** (macOS only)
- Run `sudo xcode-select --install`
- Accept Xcode license: `sudo xcodebuild -license accept`
- Update CocoaPods: `sudo gem install cocoapods`

**Integration Test Issues**
- Ensure emulator/simulator is running
- Check device connectivity: `flutter devices`
- Verify test configurations in `integration_test/`

### Getting Help

- Check [Flutter Documentation](https://docs.flutter.dev/)
- Review project documentation in `/documentation`
- Create an issue for bugs or feature requests

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Haruma**
- Email: harumatsx@gmail.com
- GitHub: [Haruma](https://github.com/harumazzz)

---

For more detailed documentation, please refer to the `/documentation` folder in the project root.
