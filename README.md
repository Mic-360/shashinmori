# ShashinMori API

A production-ready Fastify backend for private photo gallery management. ShashinMori API handles resumable photo uploads, generates optimized previews, manages storage lifecycle, and provides secure Firebase-authenticated endpoints for gallery access.

[![Fastify](https://img.shields.io/badge/Fastify-5.2-000?logo=fastify)](https://www.fastify.io/)
[![Node.js](https://img.shields.io/badge/Node.js-20+-green)](https://nodejs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.7-blue)](https://www.typescriptlang.org/)

## Overview

ShashinMori API is the backend service for the ShashinMori photo gallery system. It provides a complete solution for:

- **Secure photo uploads** via tus protocol with Firebase authentication
- **Smart preview generation** using Jimp image processing
- **Local storage management** with automatic lifecycle handling
- **Gallery metadata** stored in Firestore
- **Automated cleanup** workers for storage optimization
- **RESTful API** with OpenAPI/Swagger documentation
- **Production-ready** infrastructure for Docker, PM2, or Termux deployment

## Features

- **Resumable Uploads**: tus protocol for reliable, large file uploads with automatic retry
- **Firebase Authentication**: Secure all API endpoints with Firebase ID tokens
- **Image Processing**: Automatic preview generation and optimization
- **Smart Storage**: Original files purged after 12 hours, previews retained indefinitely
- **Local-First Architecture**: Store photos locally, sync with Google Photos automatically
- **Queue Management**: BullMQ worker system for asynchronous processing
- **Rate Limiting**: Per-user upload limits with configurable thresholds
- **Health Monitoring**: Real-time storage and queue status endpoints
- **CORS Support**: Configured origin-based cross-origin requests
- **Swagger Docs**: Interactive API documentation at `/docs`
- **OpenAPI Schema**: Machine-readable API specification
- **Production Ready**: Runs on Node.js 20+ with TypeScript

## What's Included

✅ Fastify HTTP server with plugins
✅ Firebase Admin SDK integration
✅ BullMQ job queue with workers
✅ tus upload server implementation
✅ Jimp image processing
✅ Upstash Redis client
✅ Firestore Realtime Database
✅ Rate limiting and CORS
✅ Swagger UI and OpenAPI schema
✅ TypeScript with strict type checking
✅ Docker support
✅ PM2 configuration

## What's Not Included

The current version does not include:
- Google Photos API integration (uses local device sync instead)
- Photo deletion endpoint
- Photo download/export feature
- Direct cloud backup (relies on Google Photos device backup)

These can be implemented in future versions.

## Architecture

### Local-First Design

```
Flutter Client
    ↓
Firebase Auth (ID Token)
    ↓
Fastify API Server
    ↓ (tus upload)
    ├→ Temp Upload Dir
    ├→ BullMQ Queue
    └→ Upload Worker
        ├→ Move to SYNC_FOLDER_PATH (Google Photos monitors)
        ├→ Generate preview → PREVIEW_DIR
        └→ Create Firestore record
    ↓
Gallery Endpoints
    ├→ Firestore (metadata)
    ├→ PREVIEW_DIR (retain forever)
    └→ SYNC_FOLDER_PATH (purge after 12h)
    ↓
Cleanup Worker (runs every 12 hours)
    ├→ Delete originals from SYNC_FOLDER_PATH
    ├→ Keep previews in PREVIEW_DIR
    └→ Update Firestore (originalAvailable=false)
```

## Prerequisites

Before you begin, ensure you have the following:

- **Node.js 20.0.0** or newer ([Install Node.js](https://nodejs.org/))
- **npm** 9 or newer (comes with Node.js)
- **Git**
- **Firebase Project** with:
  - Authentication enabled
  - Firestore database created
  - Service account with admin credentials
- **Upstash Redis** database:
  - REST endpoint and token
  - Redis connection string for BullMQ
- **Storage Requirements**:
  - Temporary upload directory (can be small, ~1GB)
  - Original photos directory (~50GB+ recommended)
  - Preview directory (~10GB recommended)

### Optional (for production)

- **Docker** for containerized deployment
- **PM2** for process management
- **Nginx** for reverse proxy
- **Cloudflare** for DNS and edge caching

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/mic-360/shashinmori.git -b shashinmori-api
cd shashinmori
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Setup Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your configuration. See [Configuration](#configuration) section below.

### 4. Build TypeScript

```bash
npm run build
```

### 5. Run the Server

In one terminal:

```bash
npm run start
```

In another terminal (for background workers):

```bash
npm run start:workers
```

### 6. Verify Installation

- Health check: `curl http://localhost:3000/v1/system/health`
- Swagger UI: `http://localhost:3000/docs`
- OpenAPI JSON: `http://localhost:3000/openapi.json`

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure the following:

#### Server Configuration

```env
PORT=3000
API_BASE_URL=http://localhost:3000
LOG_LEVEL=info
```

#### CORS and Origins

```env
ALLOWED_ORIGINS=http://localhost:5000,https://app.example.com
```

Separate multiple origins with commas. Include all client application origins.

#### Firebase Configuration

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n
```

To get these values:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Project Settings → Service Accounts
3. Generate new private key (JSON)
4. Copy `project_id`, `client_email`, and `private_key`

**Important**: Keep newlines escaped (`\n` not actual line breaks) in `.env`

#### Upstash Redis Configuration

```env
UPSTASH_REDIS_REST_URL=https://your-db.upstash.io
UPSTASH_REDIS_REST_TOKEN=your-access-token
UPSTASH_REDIS_TLS_URL=rediss://:password@your-db.upstash.io:6380
```

Why both REST and TLS URLs?
- REST API: Used for cache and counters
- TLS connection: Required by BullMQ job queue

Create a free Upstash database at [upstash.com](https://upstash.com)

#### Filesystem Paths

```env
UPLOAD_TEMP_DIR=/tmp/shashinmori/uploads
SYNC_FOLDER_PATH=/home/user/ShashinMori
PREVIEW_DIR=/home/user/.shashinmori/previews
```

**Important paths**:
- `UPLOAD_TEMP_DIR`: Temporary storage for tus chunks (can be cleaned periodically)
- `SYNC_FOLDER_PATH`: Where originals are stored (monitored by Google Photos)
- `PREVIEW_DIR`: Retained previews (must be outside SYNC_FOLDER_PATH)

For **Termux/Android deployment**, use:

```env
UPLOAD_TEMP_DIR=/data/data/com.termux/files/home/.shashinmori/uploads-temp
SYNC_FOLDER_PATH=/sdcard/Pictures/ShashinMori
PREVIEW_DIR=/data/data/com.termux/files/home/.shashinmori/previews
```

#### Storage and Upload Limits

```env
MAX_UPLOAD_SIZE_BYTES=2147483648
MAX_UPLOADS_PER_USER_PER_HOUR=20
STORAGE_WARN_THRESHOLD_MB=500
STORAGE_PAUSE_THRESHOLD_MB=200
```

- `MAX_UPLOAD_SIZE_BYTES`: Maximum single file size (2GB default)
- `MAX_UPLOADS_PER_USER_PER_HOUR`: Rate limit per authenticated user
- `STORAGE_WARN_THRESHOLD_MB`: Warn when space drops below this
- `STORAGE_PAUSE_THRESHOLD_MB`: Pause uploads when space drops below this

See [.env.example](.env.example) for all available configuration options.

## API Documentation

### Interactive Swagger UI

Visit `http://localhost:3000/docs` while the server is running.

### OpenAPI Schema

Download the schema at `http://localhost:3000/openapi.json`

### Endpoints

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| `POST` | `/v1/auth/profile` | Bearer | Update user profile |
| `POST` | `/v1/uploads` | Bearer | Create tus upload |
| `HEAD/PATCH` | `/v1/uploads/:id` | Bearer | Continue tus upload |
| `GET` | `/v1/uploads/:uploadId/status` | Bearer | Check upload status |
| `GET` | `/v1/photos` | Bearer | List gallery photos |
| `GET` | `/v1/photos/:photoId/preview` | Bearer/Query | Get preview image |
| `GET` | `/v1/photos/:photoId/image` | Bearer/Query | Get original or preview |
| `GET` | `/v1/system/health` | None | Health check |
| `GET` | `/v1/system/status` | Bearer | Storage and queue stats |

For detailed API reference, see [docs/api.md](docs/api.md).

### Authentication

All authenticated endpoints require Firebase ID token:

**Header method**:
```bash
curl -H "Authorization: Bearer $FIREBASE_TOKEN" \
     http://localhost:3000/v1/photos
```

**Query parameter method** (for image tags):
```html
<img src="http://localhost:3000/v1/photos/123/preview?token=$FIREBASE_TOKEN" />
```

## Development

### Run in Development Mode

Watch mode automatically rebuilds on file changes:

```bash
npm run dev
```

In another terminal:

```bash
npm run dev:workers
```

### Available Scripts

```bash
npm run build           # Compile TypeScript to JavaScript
npm run dev             # Run with hot reload
npm run dev:workers     # Run workers with hot reload
npm start               # Run compiled server
npm run start:workers   # Run compiled workers
```

### Project Structure

```
src/
├── index.ts                 # Entry point
├── server.ts                # Fastify setup
├── workers.ts               # Worker setup
├── config/
│   └── env.ts              # Environment configuration
├── middleware/
│   └── validateMime.ts      # MIME type validation
├── plugins/
│   ├── auth.ts             # Firebase authentication
│   ├── cors.ts             # CORS plugin
│   ├── errorHandler.ts     # Error handling
│   ├── rateLimit.ts        # Rate limiting
│   └── swagger.ts          # Swagger documentation
├── routes/
│   └── v1/
│       ├── index.ts         # Router setup
│       ├── auth.ts          # /v1/auth routes
│       ├── photos.ts        # /v1/photos routes
│       ├── system.ts        # /v1/system routes
│       └── uploads.ts       # /v1/uploads routes
├── services/
│   ├── cache.ts            # Redis cache layer
│   ├── filesystem.ts       # File operations
│   ├── firestore.ts        # Database operations
│   └── thumbnails.ts       # Image processing
├── queues/
│   ├── connection.ts       # Redis connection
│   ├── definitions.ts      # Job definitions
│   └── scheduler.ts        # Background scheduler
├── types/
│   ├── api.ts              # API types
│   ├── jobs.ts             # Job types
│   ├── models.ts           # Data models
│   └── jimp.d.ts           # Jimp type definitions
└── workers/
    ├── index.ts            # Worker setup
    ├── uploadWorker.ts     # Photo upload processing
    ├── cleanupWorker.ts    # Storage cleanup
    └── storageGuardWorker.ts # Storage monitoring
```

### Database Setup

#### Firestore Collections

The API uses the following Firestore structure:

```
users/{uid}
  - displayName (string)
  - photoURL (string)
  - createdAt (timestamp)

uploads/{uploadId}
  - uid (string, user owner)
  - filename (string)
  - mimeType (string)
  - fileSize (number)
  - uploadedAt (timestamp)
  - status (string: pending, processing, available, failed)
  - photoId (string, reference once available)

photos/{photoId}
  - uid (string, user owner)
  - filename (string)
  - mimeType (string)
  - originalSize (number)
  - previewSize (number)
  - uploadedAt (timestamp)
  - originalAvailable (boolean)
  - purgedAt (timestamp, if applicable)

uploads/{uid}/ (subcollection for user uploads)
```

See [docs/architecture.md](docs/architecture.md) for detailed data model.

## Building for Production

### Docker Build

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY dist ./dist

CMD ["node", "dist/index.js"]
```

Build and run:

```bash
docker build -t shashinmori-api .
docker run -p 3000:3000 --env-file .env shashinmori-api
```

### PM2 Deployment

Install PM2 globally:

```bash
npm install -g pm2
```

Use the ecosystem config:

```bash
pm2 start infrastructure/pm2/ecosystem.config.js
pm2 save
pm2 startup
```

See [infrastructure/pm2/](infrastructure/pm2/) for configuration.

### Nginx Reverse Proxy

See [infrastructure/nginx/api.conf](infrastructure/nginx/api.conf) for example configuration.

## Deployment Guides

- **Local Development**: See [docs/setup.md](docs/setup.md)
- **Architecture Details**: See [docs/architecture.md](docs/architecture.md)
- **Android/Termux**: See [docs/termux-cloudflare-deployment.md](docs/termux-cloudflare-deployment.md)
- **Google Photos Setup**: See [docs/google-photos-device-backup.md](docs/google-photos-device-backup.md)

## Testing

### Health Check

```bash
curl http://localhost:3000/v1/system/health
```

Expected response:
```json
{ "status": "ok" }
```

### Authenticated Request

```bash
curl -H "Authorization: Bearer $FIREBASE_TOKEN" \
     http://localhost:3000/v1/system/status
```

## Troubleshooting

### Firebase Connection Fails

- ✅ Verify `FIREBASE_PROJECT_ID` matches your Firebase project
- ✅ Check service account has been created
- ✅ Ensure private key has escaped newlines: `\n` not actual newlines
- ✅ Verify Firestore database exists in your project

### Redis Connection Fails

- ✅ Check Upstash database is active
- ✅ Verify REST URL and token are correct
- ✅ Ensure TLS URL uses `rediss://` protocol (not `redis://`)
- ✅ Test connection: `redis-cli -u "rediss://..." ping`

### Upload Fails

- ✅ Verify `UPLOAD_TEMP_DIR` exists and is writable
- ✅ Check disk space is above threshold
- ✅ Ensure `SYNC_FOLDER_PATH` has sufficient space
- ✅ Verify Firebase token is valid and not expired

### Workers Not Processing

- ✅ Check both server and workers are running
- ✅ Verify `START_WORKERS` is not set to `false`
- ✅ Check Redis connection is active
- ✅ Review logs: `LOG_LEVEL=debug npm run dev:workers`

### Images Not Streaming

- ✅ Verify storage paths are readable
- ✅ Check file permissions on storage directories
- ✅ Ensure CORS is configured for your origin
- ✅ Verify Firestore photo records exist

For more troubleshooting, see [docs/setup.md](docs/setup.md).

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `fastify` | ^5.2.1 | HTTP framework |
| `@fastify/cors` | ^10.0.1 | CORS support |
| `@fastify/swagger` | ^9.4.0 | API documentation |
| `firebase-admin` | ^13.0.2 | Firebase integration |
| `bullmq` | ^5.12.10 | Job queue |
| `jimp` | ^1.6.0 | Image processing |
| `@tus/server` | ^2.3.0 | Resumable uploads |
| `@upstash/redis` | ^1.35.3 | Redis client |
| `zod` | ^3.24.2 | Schema validation |
| `pino` | ^9.6.0 | Logging |

See [package.json](package.json) for complete dependency list.

## Architecture Decisions

- **Fastify over Express**: Faster performance, better TypeScript support
- **BullMQ for Jobs**: Reliable queue with good Redis support
- **Jimp for Images**: Pure JavaScript, no native dependencies
- **tus Protocol**: Industry-standard for resumable uploads
- **Firestore**: Scalable NoSQL with authentication integration
- **Local-First Storage**: Reduces cloud costs, enables offline functionality
- **Automated Cleanup**: Keeps storage lean while retaining previews

## Documentation

- [API Reference](docs/api.md) - Complete endpoint documentation
- [Architecture Guide](docs/architecture.md) - System design and data flow
- [Setup Guide](docs/setup.md) - Development environment setup
- [Termux Deployment](docs/termux-cloudflare-deployment.md) - Android deployment
- [Google Photos Setup](docs/google-photos-device-backup.md) - Photo sync configuration
- [OpenAPI Integration](openapi/README.md) - Third-party client integration

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Follow TypeScript best practices**
4. **Run type checking**: `tsc --noEmit`
5. **Write tests** for new functionality
6. **Commit with clear messages** (`git commit -m 'Feature: add photo deletion'`)
7. **Push to your fork** (`git push origin feature/amazing-feature`)
8. **Open a Pull Request** with description

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

You are free to:
- ✅ Use this software for any purpose
- ✅ Copy, modify, and distribute
- ✅ Use it commercially or privately

The only requirement is to include the license and copyright notice.

## Credits

- Built with [Fastify](https://www.fastify.io/) and [Firebase](https://firebase.google.com)
- Image processing with [Jimp](https://github.com/jimp-dev/jimp)
- Resumable uploads with [tus](https://tus.io/)
- Job queue with [BullMQ](https://docs.bullmq.io/)
- In-memory cache with [Upstash Redis](https://upstash.com/)

## Support & Feedback

- 📧 Report issues on [GitHub Issues](https://github.com/mic-360/shashinmori/issues)
- 💬 Discussions on [GitHub  -b ](httpsDiscussion://github.com/mic-360/shashinmori/discussions) -b g?
- 🐛 Found a b Please open an issue with:
  - Operating system and Node.js version
  - Steps to reproduce
  - Error logs (from console or `LOG_LEVEL=debug`)
  - Environment configuration (redacted)

## Roadmap

Future features being considered:
- [ ] Photo deletion endpoint
- [ ] Photo export/download
- [ ] Advanced image filtering
- [ ] Batch upload support
- [ ] WebSocket real-time notifications
- [ ] S3 storage backend option
- [ ] GraphQL API
- [ ] Performance metrics dashboard

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.

---

**Made with ❤️ by bhaumic**
