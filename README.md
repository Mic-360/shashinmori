# ShashinMori (写真森 - Photo Forest)

A complete, production-ready solution for private photo gallery management on a self-hosted Android device (typically an old Pixel phone, or any phone running a Pixel Experience-compatible ROM). ShashinMori enables secure photo uploads and browsing through Google authentication. It consists of a Fastify backend (`shashinmori-api`) for processing and storage, and a Flutter multi-platform client (`shashinmori-web`) for the user interface.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/Mic-360/shashinmori/blob/shashinmori-api/LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.22-blue.svg)](https://flutter.dev)
[![Fastify](https://img.shields.io/badge/Fastify-5.2-000?logo=fastify)](https://www.fastify.io/)
[![Node.js](https://img.shields.io/badge/Node.js-20+-green)](https://nodejs.org/)

---

## 📖 Table of Contents

- [Overview](#overview)
- [Architecture & Design](#architecture--design)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [System Requirements](#system-requirements)
- [Installation & Setup](#installation--setup)
  - [1. Clone Repository](#1-clone-repository)
  - [2. Firebase Configuration](#2-firebase-configuration)
  - [3. Backend Setup (API)](#3-backend-setup-api)
  - [4. Frontend Setup (App)](#4-frontend-setup-app)
- [Configuration Guides](#configuration-guides)
  - [API Environment Variables](#api-environment-variables)
  - [App Environment Variables](#app-environment-variables)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Important Product Constraints](#important-product-constraints)
- [Contributing](#contributing)
- [License](#license)

---

## 🌟 Overview

ShashinMori has two main components:

1. **`shashinmori-api`**: A Fastify backend that handles resumable photo uploads (via tus), securely stores originals (e.g., on an Android host), generates and retains optimized previews using Jimp, manages gallery metadata in Firestore, and serves authenticated endpoints.
2. **`shashinmori-web`**: A modern Flutter web + Android client that signs users in with Firebase Auth (Google Sign-In), uploads photos reliably, and displays the private gallery securely from the API.

This project is designed around Google Photos' unlimited backup behavior on supported Pixel/Pixel Experience devices: originals are uploaded to the backend host device, backed up by Google Photos on-device, then purged locally after backup while lightweight previews remain available in ShashinMori.

---

## 🏛 Architecture & Design

### Local-First Architecture

ShashinMori uses a unique, local-first architecture built around device-level synchronization (such as Google Photos backup on an Android host):

1. **Upload**: The Flutter app uploads a photo to the API using Firebase authentication and the tus protocol.
2. **Processing**: The backend worker:
   - Moves the original photo to a sync folder (`/sdcard/ShashinMori/<uid>/...` on the host).
   - Generates an optimized preview and stores it in a separate `PREVIEW_DIR`.
   - Creates a metadata record in Firestore.
3. **Backup**: The host device's Google Photos app automatically backs up the local sync folder.
4. **Lifecycle**: A 12-hour cleanup worker purges original files from the sync folder to save space but retains the previews indefinitely.
5. **Viewing**: The app shows the original image while it exists locally, then gracefully falls back to the retained preview.

```text
Flutter Client
    ↓
Firebase Auth (ID Token)
    ↓
Fastify API Server (tus upload)
    ├→ BullMQ Queue → Upload Worker
        ├→ Original → SYNC_FOLDER_PATH (Google Photos monitors)
        ├→ Preview → PREVIEW_DIR
        └→ Metadata → Firestore
    ↓
Gallery Endpoints
    ├→ Firestore (metadata)
    ├→ PREVIEW_DIR (retained indefinitely)
    └→ SYNC_FOLDER_PATH (purged after 12h)
```

---

## ✨ Features

- **Secure Authentication**: Firebase Auth with Google Sign-In secures the entire application.
- **Resumable Uploads**: The tus protocol ensures reliable, large file uploads with automatic retry from both Web and Android.
- **Smart Image Processing**: Automatic generation of compressed previews to save bandwidth and ensure fast loading.
- **Storage Lifecycle Management**: Automated background workers purge original files after 12 hours while keeping previews forever.
- **Private Gallery**: Users only see their own photos.
- **Responsive & Native UI**: Flutter provides a beautiful staggered grid gallery with Dark Mode support and shimmer loading states.
- **Rate Limiting**: Configurable per-user upload limits on the backend.
- **OpenAPI / Swagger**: Interactive backend API documentation at `/docs`.

---

## 🛠 Tech Stack

### Backend (`shashinmori-api`)
- **Framework**: Node.js 20+, Fastify, TypeScript
- **Uploads**: tus server (`@tus/server`)
- **Image Processing**: Jimp
- **Queue System**: BullMQ with Upstash Redis
- **Database**: Firebase Admin SDK (Firestore)
- **Deployment**: Docker, PM2, Termux compatible

### Frontend (`shashinmori-web`)
- **Framework**: Flutter 3.22.0+, Dart 3.3.0+
- **Platforms**: Web (Chrome, Firefox, Safari) and Android
- **State Management**: Riverpod
- **Routing**: GoRouter
- **HTTP Client**: Dio
- **Uploads**: tus_client_dart
- **UI/UX**: Material Design 3, cached_network_image, flutter_staggered_grid_view

---

## 📋 System Requirements

### Backend Requirements
- Node.js 20.0.0+ and npm 9+
- Upstash Redis database (REST endpoint and Token required for cache/counters, TLS URL for BullMQ)
- Firebase Project with:
  - Authentication enabled
  - Firestore database
  - Service Account with admin credentials
- Storage directories (Upload Temp, Original Sync, Preview)

### Frontend Requirements
- Flutter SDK (3.22.0+) and Dart
- Android SDK (API 21+) for Android builds
- Firebase Project (Web App & Android App configurations)

---

## 🚀 Installation & Setup

### 1. Clone Repository

ShashinMori is **branch-split**, not a monorepo with `shashinmori-api/` and `shashinmori-web/` folders on `main`.
- `main`: documentation only
- `shashinmori-api`: backend code at repository root
- `shashinmori-web`: Flutter client code at repository root

Depending on what you are working on, checkout the specific branch:

```bash
# Clone the repository
git clone https://github.com/mic-360/shashinmori.git

# For Backend work:
git checkout origin/shashinmori-api -b shashinmori-api

# For Frontend work:
git checkout origin/shashinmori-web -b shashinmori-web
```

### 2. Firebase Configuration

You need a unified Firebase project for both frontend and backend.
1. Go to [Firebase Console](https://console.firebase.google.com).
2. Enable Authentication (Google Sign-In).
3. Create a Firestore Database.
4. Go to Project Settings -> Service Accounts, generate a new private key (JSON) for the **Backend**.
5. Add a Web App and an Android App to get configurations for the **Frontend**.

### 3. Backend Setup (API)

```bash
# Ensure you are on the API branch (if developing) or working from the API folder
git checkout shashinmori-api

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your Firebase Service Account, Redis, and paths (see Configuration section)

# Build TypeScript
npm run build

# Start the server (Terminal 1)
npm run start

# Start background workers (Terminal 2)
npm run start:workers
```
*Health Check*: `curl http://localhost:3000/v1/system/health`
*Swagger UI*: `http://localhost:3000/docs`

### 4. Frontend Setup (App)

```bash
# Ensure you are on the Web/App branch (if developing) or working from the App folder
git checkout shashinmori-web

# Setup environment variables
cp .env.example .env
# Edit .env with your Firebase Web App credentials (see Configuration section)

# Get dependencies
flutter pub get

# For Web Development:
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000

# For Android Development:
# 1. Place google-services.json at android/app/google-services.json
# 2. Run:
flutter run -d android --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

---

## ⚙️ Configuration Guides

### API Environment Variables (`.env` in `shashinmori-api` branch root)

```env
PORT=3000
API_BASE_URL=http://localhost:3000
ALLOWED_ORIGINS=http://localhost:5000,https://app.example.com

# Firebase Service Account
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@...
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"

# Upstash Redis
UPSTASH_REDIS_REST_URL=https://your-db.upstash.io
UPSTASH_REDIS_REST_TOKEN=your-access-token
UPSTASH_REDIS_TLS_URL=rediss://:password@your-db.upstash.io:6380

# Storage Paths (Important!)
UPLOAD_TEMP_DIR=/tmp/shashinmori/uploads
SYNC_FOLDER_PATH=/home/user/ShashinMori         # Monitored by Google Photos
PREVIEW_DIR=/home/user/.shashinmori/previews    # Must be outside SYNC_FOLDER_PATH

# Limits
MAX_UPLOAD_SIZE_BYTES=2147483648
MAX_UPLOADS_PER_USER_PER_HOUR=20
```

*Note for Termux/Android API host deployment:*
```env
UPLOAD_TEMP_DIR=/data/data/com.termux/files/home/.shashinmori/uploads-temp
SYNC_FOLDER_PATH=/sdcard/Pictures/ShashinMori
PREVIEW_DIR=/data/data/com.termux/files/home/.shashinmori/previews
```

### App Environment Variables (`.env` in `shashinmori-web` branch root)

```env
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_APP_ID=your-firebase-app-id
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project-id.firebasestorage.app
```

---

## 🌍 Deployment

### Backend Deployment

Run the following commands from the **repository root while on the `shashinmori-api` branch**.  
The PM2 command expects `infrastructure/pm2/ecosystem.config.js`; the Docker command requires a `Dockerfile` in that branch.

**Docker:**
```bash
docker build -t shashinmori-api .
docker run -p 3000:3000 --env-file .env shashinmori-api
```

**PM2:**
```bash
npm install -g pm2
pm2 start infrastructure/pm2/ecosystem.config.js
pm2 save && pm2 startup
```

### Frontend Deployment

Run the following commands from the **repository root while on the `shashinmori-web` branch**:

**Web:**
```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

**Android (APK):**
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

---

## ⚠️ Important Product Constraints

- **Google Photos is Backup Only**: Google Photos is treated strictly as a device-side backup on the host device.
- **Primary Host Target**: Backend is intended to run on an old Pixel device or another Pixel Experience ROM-supported phone.
- **Lifecycle Behavior**: Originals are sent to the backend host device, backed up by Google Photos, then purged locally after backup; previews are retained for gallery tracking.
- **Multi-User Isolation**: Firestore records are user-scoped so users can only access their own photo metadata and previews.
- **No Direct Cloud Integration**: The app does not use the Google Photos API for gallery listing, deletion, or downloading.
- **Delete and Download Unavailable**: Deletion and downloading of photos are intentionally unsupported in both the backend and Flutter app to maintain a strict append-only archive system.

---

## 🔧 Troubleshooting

**Backend Redis/Upload Issues:**
- Ensure `UPSTASH_REDIS_TLS_URL` uses the `rediss://` protocol.
- Check that `UPLOAD_TEMP_DIR`, `SYNC_FOLDER_PATH`, and `PREVIEW_DIR` exist and are writable.
- Verify both the main API server and the background workers are running (`npm run start:workers`).

**Frontend Firebase/Auth Issues:**
- Ensure `.env` exists in the frontend root and contains all valid Web App keys.
- If Google Sign-In fails on Web, verify your domain (or `localhost`) is added to the Authorized Domains in the Firebase Console.
- Ensure CORS (`ALLOWED_ORIGINS`) on the backend includes the frontend's URL.

---

## 🤝 Contributing

Contributions are welcome! If you want to improve the system:
1. Fork the repository.
2. Checkout the correct branch (`shashinmori-api` for backend, `shashinmori-web` for frontend).
3. Create a feature branch (`git checkout -b feature/amazing-feature`).
4. Commit your changes and open a Pull Request against the respective branch.

---

## 📄 License

This project is licensed under the **MIT License**. License files are currently present in the component branches:
- [Backend license (`shashinmori-api`)](https://github.com/Mic-360/shashinmori/blob/shashinmori-api/LICENSE)
- [Frontend license (`shashinmori-web`)](https://github.com/Mic-360/shashinmori/blob/shashinmori-web/LICENSE)

---
*Made with ❤️ by bhaumic*
