# ShashinMori API for Client Integrations

ShashinMori exposes a Firebase-authenticated REST API. Clients upload photos with tus, list photo metadata from Firestore-backed routes, and load private images through authenticated `/preview` and `/image` endpoints.

## Base URL and docs

- Swagger UI: `/docs`
- OpenAPI JSON: `/openapi.json`
- Example base URL: `https://shashinmori-api.bhaumicsingh.tech`

## Authentication

1. Sign the user in with Firebase Auth.
2. Get the Firebase ID token.
3. Send `Authorization: Bearer <token>` on protected JSON requests.

For browser image tags, use:

```text
?token=<firebase-id-token>
```

## Routes

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/v1/auth/profile` | Upsert current user profile. |
| `POST` | `/v1/uploads` | Create a tus upload. |
| `HEAD/PATCH` | `/v1/uploads/:id` | Continue tus upload. |
| `GET` | `/v1/uploads/:uploadId/status` | Poll upload processing status. |
| `GET` | `/v1/photos` | List gallery metadata. |
| `GET` | `/v1/photos/:photoId/preview` | Stream retained preview image. |
| `GET` | `/v1/photos/:photoId/image` | Stream original if available, else preview. |
| `GET` | `/v1/system/health` | Unauthenticated health check. |
| `GET` | `/v1/system/status` | Authenticated storage/queue status. |

## Upload lifecycle

1. Create a tus upload.
2. Send chunks until the upload is complete.
3. Poll `/v1/uploads/:uploadId/status`.
4. Treat `available` as the success state.
5. Read the returned `photoId` for gallery usage.

## Product behavior

- delete is unsupported
- download is unsupported
- Google Photos cloud content is not queried
- after original purge, `/image` falls back to the retained preview

## CORS

Browser frontends must be listed in `ALLOWED_ORIGINS` on the backend.
