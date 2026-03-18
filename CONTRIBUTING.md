# Contributing to ShashinMori

Thank you for your interest in contributing to ShashinMori! We welcome contributions from everyone, regardless of experience level. This document provides guidelines and instructions for contributing.

## Code of Conduct

We are committed to providing a friendly and respectful community. Please be respectful, inclusive, and professional in all interactions.

## Ways to Contribute

- **Report Bugs**: Submit detailed bug reports with reproduction steps
- **Suggest Features**: Share ideas for new features or improvements
- **Write Code**: Submit pull requests with bug fixes or features
- **Improve Documentation**: Fix typos, clarify instructions, or add examples
- **Share Feedback**: Let us know what works and what doesn't

## Getting Started

### Setting Up Development Environment

1. **Fork the repository**

   ```bash
   git clone https://github.com/mic-360/shashinmori.git -b shashinmori-app
   cd shashinmori
   ```

2. **Create a development branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install dependencies**

   ```bash
   flutter pub get
   ```

4. **Setup environment configuration**
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase configuration
   ```

## Development Workflow

### Before You Start

- Check [existing issues](https://github.com/mic-360/shashinmori/issues) to avoid duplicate work -b discussion first to 
- For major features, open aget feedback
- Read the [README](README.md) and existing code to understand the architecture

### Making Changes

1. **Create a feature branch**

   ```bash
   git checkout -b feature/descriptive-name
   ```

2. **Follow Dart Style Guide**

   ```bash
   flutter format lib/ test/
   ```

3. **Write tests for new features**

   ```bash
   flutter test
   ```

4. **Run analysis to catch issues**

   ```bash
   flutter analyze
   ```

5. **Keep commits clean and focused**
   ```bash
   git commit -m "Fix: description of what was fixed"
   git commit -m "Feature: add new functionality"
   git commit -m "Docs: update documentation"
   ```

### Commit Message Guidelines

Use clear, descriptive commit messages:

- `Feature: add photo deletion functionality`
- `Fix: resolve upload progress bar not updating`
- `Docs: update setup instructions for Windows`
- `Tests: add unit tests for API client`
- `Refactor: improve state management in gallery`

## Code Style

### Dart/Flutter Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter format` before committing
- Use meaningful variable and function names
- Add documentation comments for public APIs

### Example

```dart
/// Uploads a photo to the ShashinMori API.
///
/// Returns the upload ID if successful.
/// Throws [UploadException] if upload fails.
Future<String> uploadPhoto(File photoFile) async {
  // Implementation
}
```

### Naming Conventions

- Constants: `const apiBaseUrl = 'https://api.example.com'`
- Variables: `final userName = 'John'`
- Classes: `class PhotoGallery`
- Functions: `void fetchPhotos()`
- Private members: `_privateVariable`

## Testing

### Writing Tests

All new features should include tests:

```dart
test('should upload photo successfully', () async {
  final file = File('test_photo.jpg');
  final result = await apiClient.uploadPhoto(file);

  expect(result, isNotNull);
  expect(result.id, isNotEmpty);
});
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/api_client_test.dart

# Run with coverage
flutter test --coverage
```

## Pull Request Process

1. **Fork and create a feature branch**

   ```bash
   git checkout -b feature/your-feature
   ```

2. **Make your changes**
   - Keep changes focused and manageable
   - Update documentation if needed
   - Add tests for new functionality

3. **Format and analyze your code**

   ```bash
   flutter format lib/ test/
   flutter analyze
   ```

4. **Push to your fork**

   ```bash
   git push origin feature/your-feature
   ```

5. **Create a Pull Request**
   - Use a clear, descriptive title
   - Reference related issues (#123)
   - Describe what changes were made and why
   - Include screenshots if UI changes
   - List any breaking changes

### PR Title Format

- `Feature: add photo deletion`
- `Fix: resolve login issue on Android`
- `Docs: update setup guide`
- `Refactor: improve error handling`
- `Tests: add upload tests`

### PR Description Template

```markdown
## Description

Brief summary of changes

## Related Issues

Fixes #123

## Changes Made

- Change 1
- Change 2
- Change 3

## Testing Done

- Test 1
- Test 2

## Screenshots (if applicable)

[Add screenshots here]

## Breaking Changes

None / Description of breaking changes

## Checklist

- [ ] Code formatted with `flutter format`
- [ ] Ran `flutter analyze` with no issues
- [ ] Added tests for new functionality
- [ ] Updated documentation
- [ ] Tested on web and Android (if applicable)
```

## Reporting Issues

### Before Reporting

- Search [existing issues](https://github.com/mic-360/shashinmori/issues) first -b troubleshooting guide]
- Check (README.md#troubleshooting) in README

### Issue Template

```markdown
### Environment

- Flutter version: 3.22.0
- Device: Chrome / Android
- OS: Windows / macOS / Linux

### Steps to Reproduce

1. Step 1
2. Step 2
3. Step 3

### Expected Behavior

What should happen

### Actual Behavior

What actually happens

### Error Logs
```

[Paste error logs here]

```

### Screenshots
[Attach relevant screenshots]
```

## Feature Requests

Feature requests are welcome! Please provide:

- **Clear title**: What feature do you want?
- **Motivation**: Why is this feature needed?
- **Use case**: How would this improve the app?
- **Alternatives**: Are there other solutions?

## Documentation

Documentation improvements are always welcome:

- Fix typos or unclear explanations
- Add examples or screenshots
- Improve API documentation
- Add troubleshooting guides

## Development Tips

### Useful Commands

```bash
# Clean build
flutter clean

# Get latest dependencies
flutter pub get
flutter pub upgrade

# Run with verbose output
flutter run -v

# Build production APK
flutter build apk --release

# Build web production
flutter build web --release

# Check for dependency updates
flutter pub outdated
```

### Debugging

```bash
# Enable skia rendering for better debugging
flutter run --enable-software-rendering

# Enable impeller rendering
flutter run --enable-impeller

# Print debug info
debugPrint('message: $variable');
```

### Performance Testing

```bash
# Run with profile mode
flutter run --profile

# Check app size
flutter build apk --analyze-size --release
```

## Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/mic-360/shashinmori/discussions) -b [troubleshooting]
- **Issues**: Check(README.md#troubleshooting)
- **Documentation**: See [docs/](docs/) folder
- **Community**: Join our Discord (if available)

## Recognition

Contributors will be:

- Listed in the project README
- Credited in version CHANGELOG
- Thanked in pull request discussions

## Code Review Process

All submissions require review by project maintainers. We review for:

- Code quality and style consistency
- Test coverage
- Documentation
- Performance considerations
- Security implications
- Alignment with project goals

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to ShashinMori! Your efforts help make this project better for everyone.
