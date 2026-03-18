import { createReadStream } from "node:fs";
import path from "node:path";
import type { FastifyInstance } from "fastify";
import { Timestamp } from "firebase-admin/firestore";
import { fileExists } from "../../services/filesystem.js";
import { photosCollection } from "../../services/firestore.js";
import { AppError, createList } from "../../types/api.js";

const errorSchema = {
  type: "object",
  properties: {
    success: { const: false },
    error: {
      type: "object",
      properties: {
        code: { type: "string" },
        message: { type: "string" },
        requestId: { type: "string" }
      },
      required: ["code", "message", "requestId"]
    }
  }
} as const;

function encodeCursor(uploadedAt: Timestamp): string {
  return Buffer.from(JSON.stringify({ uploadedAtMs: uploadedAt.toMillis() }), "utf8").toString("base64url");
}

function decodeCursor(cursor: string): Timestamp {
  const parsed = JSON.parse(Buffer.from(cursor, "base64url").toString("utf8")) as {
    uploadedAtMs?: number;
  };
  if (typeof parsed.uploadedAtMs !== "number") {
    throw new AppError("INVALID_CURSOR", "Cursor is invalid", 400);
  }

  return Timestamp.fromMillis(parsed.uploadedAtMs);
}

function toTimestamp(value: unknown, fieldName: string): Timestamp {
  if (value instanceof Timestamp) {
    return value;
  }

  if (value instanceof Date) {
    return Timestamp.fromDate(value);
  }

  if (typeof value === "string") {
    const parsed = Date.parse(value);
    if (!Number.isNaN(parsed)) {
      return Timestamp.fromMillis(parsed);
    }
  }

  if (typeof value === "number" && Number.isFinite(value)) {
    return Timestamp.fromMillis(value);
  }

  if (
    typeof value === "object"
    && value !== null
    && "seconds" in value
    && typeof (value as { seconds?: unknown }).seconds === "number"
  ) {
    const seconds = (value as { seconds: number }).seconds;
    const nanoseconds = (
      "nanoseconds" in value && typeof (value as { nanoseconds?: unknown }).nanoseconds === "number"
    )
      ? (value as { nanoseconds: number }).nanoseconds
      : 0;
    return new Timestamp(seconds, nanoseconds);
  }

  throw new AppError("INVALID_PHOTO_RECORD", `Photo field "${fieldName}" is invalid`, 500);
}

function normalizePhoto(photo: Record<string, unknown>, photoId: string) {
  const uploadedAt = toTimestamp(photo.uploadedAt, "uploadedAt");
  const purgedAt = photo.purgedAt == null ? null : toTimestamp(photo.purgedAt, "purgedAt");

  return {
    photoId: typeof photo.photoId === "string" && photo.photoId.length > 0 ? photo.photoId : photoId,
    filename: typeof photo.filename === "string" ? photo.filename : "photo",
    mimeType: typeof photo.mimeType === "string" ? photo.mimeType : "application/octet-stream",
    sizeBytes: typeof photo.sizeBytes === "number" ? photo.sizeBytes : 0,
    width: typeof photo.width === "number" ? photo.width : 0,
    height: typeof photo.height === "number" ? photo.height : 0,
    uploadedAt,
    originalAvailable: photo.originalAvailable === true,
    purgedAt,
    status: photo.status === "active" ? "active" as const : "active" as const
  };
}

function serializePhoto(photo: ReturnType<typeof normalizePhoto>) {
  return {
    photoId: photo.photoId,
    filename: photo.filename,
    mimeType: photo.mimeType,
    sizeBytes: photo.sizeBytes,
    width: photo.width,
    height: photo.height,
    uploadedAt: photo.uploadedAt.toDate().toISOString(),
    originalAvailable: photo.originalAvailable,
    purgedAt: photo.purgedAt ? photo.purgedAt.toDate().toISOString() : null,
    status: photo.status
  };
}

function sortPhotosByUploadedAtDesc(
  left: ReturnType<typeof normalizePhoto>,
  right: ReturnType<typeof normalizePhoto>,
) {
  return right.uploadedAt.toMillis() - left.uploadedAt.toMillis();
}

function applyCursor(
  photos: ReturnType<typeof normalizePhoto>[],
  cursor?: string,
) {
  if (!cursor) {
    return photos;
  }

  const cursorTimestamp = decodeCursor(cursor).toMillis();
  return photos.filter((photo) => photo.uploadedAt.toMillis() < cursorTimestamp);
}

function getPreviewContentType(filePath: string): string {
  const extension = path.extname(filePath).toLowerCase();
  if (extension === ".jpg" || extension === ".jpeg") {
    return "image/jpeg";
  }

  if (extension === ".png") {
    return "image/png";
  }

  return "application/octet-stream";
}

async function getOwnedPhoto(app: FastifyInstance, photoId: string, uid: string) {
  const snapshot = await photosCollection().doc(photoId).get();
  const photo = snapshot.data();
  if (!snapshot.exists || !photo || photo.userId !== uid) {
    throw new AppError("NOT_FOUND", "Photo not found", 404);
  }

  return { snapshot, photo };
}

async function resolveImagePath(photo: {
  originalPath: string;
  previewPath: string;
  originalAvailable: boolean;
  mimeType: string;
  purgedAt: Timestamp | null;
}, photoRef: FirebaseFirestore.DocumentReference, preferOriginal: boolean) {
  if (preferOriginal && photo.originalAvailable && await fileExists(photo.originalPath)) {
    return {
      filePath: photo.originalPath,
      contentType: photo.mimeType,
      contentDisposition: "inline"
    };
  }

  if (preferOriginal && photo.originalAvailable && !await fileExists(photo.originalPath)) {
    await photoRef.set({
      originalAvailable: false,
      purgedAt: photo.purgedAt ?? Timestamp.now()
    }, { merge: true });
  }

  if (await fileExists(photo.previewPath)) {
    return {
      filePath: photo.previewPath,
      contentType: getPreviewContentType(photo.previewPath),
      contentDisposition: "inline"
    };
  }

  throw new AppError("NOT_FOUND", "Image asset not found", 404);
}

export async function registerPhotoRoutes(app: FastifyInstance): Promise<void> {
  app.get("/photos", {
    preHandler: app.requireAuth,
    schema: {
      tags: ["Photos"],
      summary: "List photos",
      description: "Returns the authenticated user's Firestore-backed photo gallery with cursor pagination.",
      security: [{ bearerAuth: [] }],
      querystring: {
        type: "object",
        properties: {
          cursor: { type: "string" },
          limit: { type: "integer", minimum: 1, maximum: 50, default: 20 }
        }
      },
      response: {
        200: {
          type: "object",
          properties: {
            success: { const: true },
            data: {
              type: "array",
              items: { type: "object", additionalProperties: true }
            },
            nextCursor: { anyOf: [{ type: "string" }, { type: "null" }] },
            hasMore: { type: "boolean" }
          },
          required: ["success", "data", "nextCursor", "hasMore"]
        },
        401: errorSchema
      }
    }
  }, async (request) => {
    const query = request.query as { cursor?: string; limit?: number };
    const limit = Math.min(query.limit ?? 20, 50);
    const snapshot = await photosCollection()
      .where("userId", "==", request.user!.uid)
      .get();

    const normalizedPhotos = snapshot.docs
      .map((doc) => normalizePhoto(doc.data() as unknown as Record<string, unknown>, doc.id))
      .filter((photo) => photo.status === "active")
      .sort(sortPhotosByUploadedAtDesc);

    const cursorFilteredPhotos = applyCursor(normalizedPhotos, query.cursor);
    const hasMore = cursorFilteredPhotos.length > limit;
    const pageData = hasMore ? cursorFilteredPhotos.slice(0, limit) : cursorFilteredPhotos;
    const lastItem = pageData.at(-1);

    return createList(
      pageData.map(serializePhoto),
      hasMore && lastItem ? encodeCursor(lastItem.uploadedAt) : null,
      hasMore,
    );
  });

  app.get("/photos/:photoId/preview", {
    preHandler: app.requireAuth,
    schema: {
      tags: ["Photos"],
      summary: "Preview image",
      description: "Streams the authenticated user's retained preview image.",
      security: [{ bearerAuth: [] }],
      params: {
        type: "object",
        required: ["photoId"],
        properties: {
          photoId: { type: "string", minLength: 1 }
        }
      },
      querystring: {
        type: "object",
        properties: {
          token: { type: "string" }
        }
      },
      response: {
        200: { type: "string", format: "binary" },
        401: errorSchema,
        404: errorSchema
      }
    }
  }, async (request, reply) => {
    const { photoId } = request.params as { photoId: string };
    const { snapshot, photo } = await getOwnedPhoto(app, photoId, request.user!.uid);
    const image = await resolveImagePath(photo, snapshot.ref, false);

    reply.header("Cache-Control", "private, max-age=300");
    reply.header("Content-Disposition", `${image.contentDisposition}; filename="${path.basename(image.filePath)}"`);
    return reply.type(image.contentType).send(createReadStream(image.filePath));
  });

  app.get("/photos/:photoId/image", {
    preHandler: app.requireAuth,
    schema: {
      tags: ["Photos"],
      summary: "Photo image",
      description: "Streams the original image when still present locally, otherwise falls back to the retained preview.",
      security: [{ bearerAuth: [] }],
      params: {
        type: "object",
        required: ["photoId"],
        properties: {
          photoId: { type: "string", minLength: 1 }
        }
      },
      querystring: {
        type: "object",
        properties: {
          token: { type: "string" }
        }
      },
      response: {
        200: { type: "string", format: "binary" },
        401: errorSchema,
        404: errorSchema
      }
    }
  }, async (request, reply) => {
    const { photoId } = request.params as { photoId: string };
    const { snapshot, photo } = await getOwnedPhoto(app, photoId, request.user!.uid);
    const image = await resolveImagePath(photo, snapshot.ref, true);

    reply.header("Cache-Control", "private, max-age=300");
    reply.header("Content-Disposition", `${image.contentDisposition}; filename="${path.basename(image.filePath)}"`);
    return reply.type(image.contentType).send(createReadStream(image.filePath));
  });
}
