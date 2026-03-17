# ShashinMori

ShashinMori has two projects:

- `shashinmori-api`: Fastify backend that receives uploads, stores originals on the Android host, generates retained previews, writes gallery metadata to Firestore, and serves authenticated gallery/image endpoints.
- `shashinmori-app`: Flutter web + Android client that signs users in with Firebase Auth, uploads photos with tus, and reads the private gallery from the API.

## Project docs

- Backend overview: `shashinmori-api/README.md`
- Backend local setup: `shashinmori-api/docs/setup.md`
- Backend Termux + Cloudflare deployment: `shashinmori-api/docs/termux-cloudflare-deployment.md`
- Backend Google Photos device backup setup: `shashinmori-api/docs/google-photos-device-backup.md`
- Flutter app overview: `shashinmori-app/README.md`
- Flutter app local setup: `shashinmori-app/docs/setup.md`
- Flutter app deployment: `shashinmori-app/docs/deployment.md`

## Current architecture

1. The Flutter app uploads a photo to the API with Firebase authentication.
2. The backend stores the original inside `/sdcard/ShashinMori/<uid>/...`.
3. The Google Photos Android app backs up that local folder on the Pixel device.
4. The backend stores one retained compressed preview outside the purge directory.
5. Firestore stores ownership, upload metadata, dimensions, and local availability state.
6. The app shows the original while it still exists locally, then falls back to the retained preview after purge.

## Important product constraints

- Google Photos is treated as device-side backup only.
- The app does not use the Google Photos API for gallery listing, delete, or download.
- Delete and download are intentionally unsupported in both backend and Flutter.
