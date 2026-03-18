# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-03-19

### Added

- Initial public release of ShashinMori API
- Fastify HTTP server with plugin architecture
- Firebase Admin SDK authentication
- Resumable photo uploads via tus protocol
- Automatic preview generation with Jimp
- BullMQ worker system for background jobs
- Storage lifecycle management with automatic cleanup
- Firestore integration for metadata storage
- Rate limiting per authenticated user
- CORS support with configurable origins
- Swagger UI interactive documentation
- OpenAPI schema generation
- Health monitoring endpoints
- Storage status tracking
- Upload status polling
- Image optimization and caching

### Features

- Create and resume tus uploads
- Process uploaded photos asynchronously
- Generate optimized preview images
- Store photo metadata in Firestore
- Retrieve and stream preview/original images
- Track storage capacity and wake up users
- Schedule cleanup jobs
- Authenticate all requests with Firebase tokens

### Architecture

- Local-first storage design
- Automatic Google Photos sync integration
- Separated upload and cleanup workers
- Queue-based architecture with BullMQ
- TypeScript for type safety
- Modular plugin system

### Deployment

- Docker support with Dockerfile
- PM2 ecosystem configuration
- Nginx reverse proxy example
- Support for Termux/Android deployment
- Environment-based configuration

## [Unreleased]

### Planned

- Photo deletion endpoint
- Photo export/download functionality
- Advanced image metadata extraction
- WebSocket real-time upload notifications
- S3/cloud storage backend option
- GraphQL API layer
- Performance metrics/monitoring dashboard
- Batch upload support
- Photo sharing functionality

### Under Discussion

- iOS/macOS support
- End-to-end encryption
- Photo tagging and search
- Machine learning-based organization
- Multi-user sharing with permissions
