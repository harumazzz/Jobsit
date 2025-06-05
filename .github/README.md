# CI/CD Pipeline for Jobsit Flutter App

This repository contains a streamlined CI/CD pipeline for the Jobsit Flutter application using GitHub Actions, optimized for web builds only.

## 🚀 Workflows Overview

### 1. Main CI/CD Pipeline (`flutter_ci.yml`)
Triggered on push/PR to `main` and `develop` branches.

**Jobs:**
- **Test**: Runs widget tests with coverage reporting
- **Build Web**: Creates web build only (Ubuntu runner)
- **Deploy**: Deploys to staging (develop branch)
- **Release**: Creates GitHub releases (main branch)

### 2. Pull Request Checks (`pr_checks.yml`)
Triggered on pull requests to ensure code quality.

**Features:**
- Code formatting validation (dart format)
- Static analysis with Flutter analyzer
- Widget tests from `test/` folder
- TODO/FIXME comment detection
- pubspec.yaml validation
- Web build size analysis
- Automated PR comments with build info

### 3. Nightly Builds (`nightly.yml`)
Scheduled daily builds and quality checks.

**Features:**
- Comprehensive testing
- Web build generation
- Coverage reporting
- Build artifact retention (7 days)
- Nightly build reports

### 4. Dependency Updates (`dependency_updates.yml`)
Weekly automated dependency updates.

**Features:**
- Automatic Flutter dependency updates
- Creates pull requests with changes
- Runs tests to ensure compatibility
- Auto-creates PRs when updates available

## 📋 Prerequisites

### Required Secrets
Add these secrets to your GitHub repository:

```bash
# For coverage reporting (optional)
CODECOV_TOKEN=your_codecov_token

# For deployment (if using Firebase, AWS, etc.)
FIREBASE_SERVICE_ACCOUNT=your_service_account_json
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
```

### Repository Settings
1. Enable GitHub Actions in repository settings
2. Allow write permissions for GitHub token in Actions settings
3. Configure branch protection rules for `main` and `develop`

## 🧪 Test Structure

The pipeline runs widget tests from the `test/` folder:

```
test/
├── unit/
├── widget/
├── integration/
└── [all test files ending in _test.dart]
```

**Note**: Integration tests are excluded as they require Android emulator setup which conflicts with JAR file dependencies.

## 🔧 Configuration

### Flutter Version
Currently configured for Flutter 3.32.2. Update in workflow files if needed:

```yaml
flutter-version: '3.32.2'
```

### Platform Support
- ✅ Web builds only
- ❌ Android builds (removed due to JAR file conflicts)
- ❌ iOS builds (removed, requires macOS runners)
- ⚙️ Ubuntu runners only

### Key Changes Made
- **Removed**: Java 11 setup and Android SDK configuration
- **Removed**: Android APK builds and iOS builds
- **Removed**: Integration test setup with Android emulator
- **Added**: Web-only build configuration
- **Simplified**: Ubuntu runner only for all jobs

## 🚀 Deployment

### Staging Deployment
Automatically deploys web builds to staging when code is pushed to `develop` branch.

### Production Release
Creates GitHub releases when code is pushed to `main` branch.

**Release artifacts include:**
- Web build only
- Release notes with version from pubspec.yaml

## 📊 Monitoring & Reporting

### Coverage Reports
- Uploaded to Codecov
- Widget tests coverage only
- Non-blocking if upload fails

### Build Analysis
- Web build size analysis
- PR comments with build information
- Build artifact retention (30 days for releases, 7 days for nightly)

## 🛠️ Local Development

To run the same checks locally:

```bash
# Install dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test --coverage

# Run widget tests specifically
flutter test test/unit/features/*/presentation/widgets/

# Run integration tests (requires emulator)
flutter test integration_test/

# Check formatting
dart format --set-exit-if-changed .

# Analyze code
```bash
# Use provided scripts for local testing
./scripts/ci_local.sh        # Bash script
./scripts/ci_local.ps1       # PowerShell script  
./scripts/ci_local_bash.sh   # Alternative bash script

# Manual testing commands
flutter pub get
flutter analyze --fatal-infos
flutter test --coverage test/
dart format --set-exit-if-changed lib/ test/
flutter config --enable-web
flutter build web --release --web-renderer html
```

## 🔍 Troubleshooting

### Common Issues

1. **Build failures**: Check Flutter version compatibility (3.32.2)
2. **Test failures**: Ensure widget tests in test/ folder are properly configured
3. **Web build failures**: Verify Flutter web configuration
4. **Coverage upload**: Check CODECOV_TOKEN if coverage reporting needed

### Debugging Tips

1. Check GitHub Actions logs for detailed error messages
2. Run tests locally using provided scripts
3. Verify all required secrets are configured
4. Ensure branch protection rules allow workflow execution
5. Use manual workflow dispatch for testing

## 📈 Workflow Benefits

### Optimizations Made
- ✅ Ubuntu-only runners for cost efficiency
- ✅ Web builds only for simplicity
- ✅ No Java/Android dependencies
- ✅ Fast widget test execution
- ✅ Streamlined artifact management
- ✅ JAR file compatibility

### Performance Features
- Flutter action caching enabled
- Build artifact retention policies
- Efficient dependency management
- Automated dependency updates

## 🤝 Contributing

When working with this CI/CD setup:
1. Include widget tests for new features
2. Use `flutter test test/` for local validation
3. Update workflows if new web-specific dependencies are added
4. Test locally using provided scripts
5. Focus on web compatibility only

## 📝 Migration Notes

### Changes from Previous Setup
- **Removed**: Android/iOS builds and platform-specific dependencies
- **Removed**: Integration tests requiring Android emulator
- **Removed**: Java 11 setup and Android SDK configuration
- **Added**: Simplified web-only build pipeline
- **Improved**: Ubuntu runner efficiency and JAR file compatibility

---

For questions or issues with the streamlined CI/CD pipeline, please open an issue or contact the development team.
