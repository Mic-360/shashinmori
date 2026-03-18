# ShashinMori App

A modern Flutter application for a private, family-focused photo gallery. ShashinMori (写真森 - Photo Forest) enables secure photo uploads and browsing through Google authentication, with a beautiful responsive interface supporting both web and Android platforms.

[![Flutter](https://img.shields.io/badge/Flutter-3.22-blue.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-3.3-blue.svg)](https://dart.dev)

## Features

- **Google Authentication**: Secure sign-in via Firebase Auth with Google
- **Image Upload**: Upload photos from web and Android with tus protocol for reliable transfers
- **Private Gallery**: View only your own photos with a responsive, beautiful gallery interface
- **Real-time Status**: Polls upload status until backend marks photos as available
- **Smart Caching**: Cached network images with shimmer loading states for better UX
- **Multi-platform**: Runs on web (Chrome, Firefox, Safari) and Android
- **Dark Mode Support**: Automatic theme switching based on system preferences
- **Responsive Design**: Adapts seamlessly from mobile to desktop screens

## What's Included

- ✅ Google Sign-In authentication
- ✅ Photo upload with progress tracking
- ✅ Gallery listing with image caching
- ✅ Dark/Light theme system
- ✅ State management with Riverpod
- ✅ Navigation with GoRouter
- ✅ API client with Dio
- ✅ Material Design UI with custom theming

## What's Not Included

The current version does not include:

- Direct Google Photos integration
- Photo deletion functionality
- Photo download feature

These can be implemented in future versions.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter 3.22.0** or newer ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart 3.3.0** or newer (comes with Flutter)
- **Android SDK** (API level 21 or higher) for Android builds
- **Git**
- A **Firebase project** with authentication enabled
- The **ShashinMori API** backend running locally or deployed

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/mic-360/shashinmori.git -b shashinmori-app
cd shashinmori
```

### 2. Setup Environment Variables

```bash
cp .env.example .env
```

Edit `.env` and fill in your Firebase web configuration:

```env
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_APP_ID=your-firebase-app-id
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project-id.firebasestorage.app
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run on Web (Development)

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

### 5. (Optional) Run on Android

First, add your Firebase configuration file:

```bash
# Place the downloaded google-services.json file
cp path/to/google-services.json android/app/
```

Then run:

```bash
flutter run -d android --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

## Firebase Setup

### Required Firebase Configuration

1. **Create a Firebase Project** at [Firebase Console](https://console.firebase.google.com)

2. **Enable Authentication**
   - Go to Authentication > Sign-in method
   - Enable Google Sign-In
   - Add web and Android app URLs to authorized domains

3. **Create Web App**
   - In Project Settings, add a Web app
   - Copy the Firebase configuration
   - Paste the values into `.env`

4. **Create Android App** (if building for Android)
   - Add an Android app in Firebase
   - Download `google-services.json`
   - Place at `android/app/google-services.json`

### Firebase Configuration in Code

The app uses `flutter_dotenv` to load Firebase config from `.env` at runtime. This approach:

- ✅ Keeps sensitive config out of version control
- ✅ Allows different configs per environment

## Project Structure

```
shashinmori-app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── firebase_options.dart     # Firebase configuration loader
│   ├── core/
│   │   ├── api_client.dart       # HTTP client with Dio
│   │   ├── config.dart           # App configuration
│   │   ├── error_handler.dart    # Error handling & logging
│   │   ├── router.dart           # GoRouter navigation setup
│   │   └── theme.dart            # Material theme (light/dark)
│   ├── features/
│   │   ├── auth/
│   │   │   └── ...               # Authentication screens & logic
│   │   ├── gallery/
│   │   │   └── ...               # Photo gallery display
│   │   ├── landing/
│   │   │   └── ...               # Landing/home screen
│   │   └── upload/
│   │       └── ...               # Photo upload feature
│   └── shared/
│       ├── models/               # Data models & types
│       └── widgets/              # Reusable UI components
├── android/                      # Android-specific code
├── web/                          # Web-specific assets
├── assets/                       # App assets (icons, fonts, etc.)
├── test/                         # Unit and widget tests
├── pubspec.yaml                  # Project dependencies
└── analysis_options.yaml         # Lint rules
```

## Configuration

### API Base URL

The app communicates with the ShashinMori API backend. Pass the base URL at runtime:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

### Supported Platforms

- **Web**: Chrome, Firefox, Safari (tested on latest)
- **Android**: API 21 and above
- **iOS**: Not currently configured, contributions welcome
- **Desktop**: Not currently configured, but possible with Flutter

## Building for Production

### Web Build

```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

Output will be in `build/web/`

### Android Build

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

For App Bundle (recommended for Play Store):

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

For detailed deployment instructions, see [docs/deployment.md](docs/deployment.md).

## Dependencies

Key packages used in this project:

| Package                       | Version | Purpose                 |
| ----------------------------- | ------- | ----------------------- |
| `firebase_core`               | ^4.1.1  | Firebase initialization |
| `firebase_auth`               | ^6.1.1  | Authentication          |
| `google_sign_in`              | ^7.2.0  | Google login            |
| `go_router`                   | ^16.2.4 | Navigation & routing    |
| `flutter_riverpod`            | ^3.0.3  | State management        |
| `dio`                         | ^5.9.0  | HTTP client             |
| `tus_client_dart`             | ^2.5.0  | Upload protocol client  |
| `flutter_staggered_grid_view` | ^0.7.0  | Gallery grid layout     |
| `cached_network_image`        | ^3.4.1  | Image caching           |
| `google_fonts`                | ^6.3.1  | Custom fonts            |
| `image_picker`                | ^1.2.0  | Image selection         |

See [pubspec.yaml](pubspec.yaml) for the complete dependency list.

## Usage

### Signing In

1. Launch the app
2. Tap "Sign in with Google"
3. Complete the Google authentication flow
4. You'll be redirected to the gallery

### Uploading Photos

1. Navigate to the upload section
2. Select photos from your device
3. Monitor upload progress
4. Wait for backend processing
5. Photos appear in gallery when marked as "available"

### Viewing Gallery

- Scroll through your photos in a beautiful staggered grid
- Images are cached for faster loading on subsequent views
- Dark mode adapts to your system preferences

## API Integration

The app integrates with the ShashinMori API backend for:

- Authentication token verification
- Photo upload endpoints
- Photo listing and metadata
- Upload status polling

For API documentation, see the [ShashinMori API README](../shashinmori-api/README.md).

## Development

### Running Tests

```bash
flutter test
```

### Analyzing Code

```bash
flutter analyze
```

### Formatting Code

```bash
flutter format lib/ test/
```

### Running with Verbose Output

```bash
flutter run -v
```

## Architecture Decisions

- **Riverpod for State Management**: Chosen for compile-time safety and minimal boilerplate
- **GoRouter for Navigation**: Type-safe routing with deep linking support
- **Dio for HTTP**: Interceptors for auth tokens and error handling
- **tus Protocol**: Reliable file uploads with resumable capability

## Troubleshooting

### Firebase Configuration Not Loading

- ✅ Ensure `.env` file exists in project root
- ✅ Check that all required Firebase keys are present
- ✅ Run `flutter clean && flutter pub get`

### Upload Fails

- ✅ Verify API_BASE_URL is correct
- ✅ Check backend is running
- ✅ Ensure file permissions are granted
- ✅ Check tus server configuration

### Google Sign-In Not Working

- ✅ Verify Firebase project has Google Sign-In enabled
- ✅ Check authorized domains in Firebase Console
- ✅ On web, ensure domain matches Firebase configuration
- ✅ Clear browser cache/cookies

### Images Not Loading

- ✅ Check API is returning valid image URLs
- ✅ Verify CORS is properly configured on backend
- ✅ Check network connectivity

For more detailed setup guidance, see [docs/setup.md](docs/setup.md).

## Documentation

- [Setup Guide](docs/setup.md) - Complete local development setup
- [Deployment Guide](docs/deployment.md) - Production deployment instructions
- [API Documentation](../shashinmori-api/docs/api.md) - Backend API reference

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Follow Dart style guide**: `flutter format lib/ test/`
4. **Run analysis**: `flutter analyze`
5. **Write tests** for new features
6. **Commit with clear messages** (`git commit -m 'Add amazing feature'`)
7. **Push to your fork** (`git push origin feature/amazing-feature`)
8. **Open a Pull Request** with a clear description

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter format` before committing
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

You are free to:

- ✅ Use this software for any purpose
- ✅ Copy, modify, and distribute
- ✅ Use it commercially or privately

The only requirement is to include the license and copyright notice.

## Credits

- Built with [Flutter](https://flutter.dev) and [Firebase](https://firebase.google.com)
- Uses [Material Design 3](https://m3.material.io/) for UI
- Icons and design inspiration from the Flutter community

## Support & Feedback

- 📧 Report issues on [GitHub Issues](https://github.com/mic-360/shashinmori/issues)
- 💬 Discussions on [GitHub Discussions](https://github.com/mic-360/shashinmori/discussions)
- 🐛 Found a bug? Please open an issue with:
  - Device/browser information
  - Steps to reproduce
  - Expected vs actual behavior
  - Error logs (if applicable)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.

---

**Made with ❤️ by bhaumic**
