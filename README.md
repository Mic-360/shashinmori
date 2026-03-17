# ShashinMori API

ShashinMori API is the private backend for the Flutter web and Android clients. It accepts resumable uploads, stores originals on the Android host device, generates one retained preview per photo, writes ownership and metadata to Firestore, and serves authenticated gallery/image endpoints.

## What this service does

- accepts uploads over tus
- authenticates every private request with Firebase ID tokens
- stores originals in a Google Photos auto-backup folder on the Android device
- generates retained compressed previews outside the purge directory
- stores gallery metadata in Firestore
- serves `/preview` and `/image` routes for the Flutter app
- purges original files every 12 hours while keeping preview access working

## What this service does not do

- it does not use the Google Photos API
- it does not support delete or download
- it does not treat Google Photos cloud state as the app source of truth

## Documentation map

- Local setup: `docs/setup.md`
- API reference: `docs/api.md`
- Architecture: `docs/architecture.md`
- Termux + Cloudflare deployment: `docs/termux-cloudflare-deployment.md`
- Google Photos device backup setup: `docs/google-photos-device-backup.md`
- Third-party client integration: `openapi/README.md`

## Requirements

- Node.js 20+
- Firebase project with:
  - Authentication
  - Firestore
  - service account access for the backend
- Upstash Redis database
- Android device with:
  - Termux
  - storage permission granted to Termux
  - Google Photos installed and configured to back up `SYNC_FOLDER_PATH`

## Core environment variables

| Variable | Purpose |
| --- | --- |
| `PORT` | Fastify listen port, usually `3000`. |
| `API_BASE_URL` | Public base URL for docs and generated links. |
| `ALLOWED_ORIGINS` | Allowed browser origins for CORS. |
| `FIREBASE_PROJECT_ID` | Firebase project ID. |
| `FIREBASE_CLIENT_EMAIL` | Service account email. |
| `FIREBASE_PRIVATE_KEY` | Service account private key with escaped newlines. |
| `UPSTASH_REDIS_REST_URL` | Upstash REST URL for cache counters. |
| `UPSTASH_REDIS_REST_TOKEN` | Upstash REST token. |
| `UPSTASH_REDIS_TLS_URL` | `rediss://` URL for BullMQ. |
| `UPLOAD_TEMP_DIR` | Temporary tus upload directory. |
| `SYNC_FOLDER_PATH` | Local originals directory monitored by Google Photos. |
| `PREVIEW_DIR` | Retained preview directory. |

Full examples live in `.env.example`.

## Quick start

1. Copy `.env.example` to `.env`.
2. Fill Firebase, Upstash, and local filesystem values.
3. Run `npm install`.
4. Run `npm run build`.
5. Run the API with `npm run start`.
6. Run workers with `npm run start:workers`.

For local development and full setup, use `docs/setup.md`.
