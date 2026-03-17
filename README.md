# ShashinMori App

ShashinMori App is the Flutter client for the ShashinMori workflow. It runs on web and Android, signs users in with Firebase Auth, uploads images with tus, and shows a private gallery backed by the ShashinMori API.

## What the app does

- signs users in with Google through Firebase Auth
- uploads images from web and Android
- polls upload status until the backend marks the photo `available`
- lists only the current user's photos
- displays a retained preview after the backend purges the local original

## What the app does not do

- it does not talk to Google Photos directly
- it does not support delete
- it does not support download

## Documentation map

- Local setup: `docs/setup.md`
- Deployment guide: `docs/deployment.md`

## Runtime configuration

The app needs:

- `API_BASE_URL` from `--dart-define`
- Firebase web config in `.env`
- `android/app/google-services.json` for Android builds

`lib/firebase_options.dart` reads Firebase values from `.env` via `flutter_dotenv`, so Firebase config is not hardcoded in source.

## Quick start

1. Copy `.env.example` to `.env`.
2. Fill in the Firebase web values.
3. Add `android/app/google-services.json`.
4. Run `flutter pub get`.
5. Run `flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000` or build for Android/web.

For the complete setup flow, use `docs/setup.md`.
