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

function serializePhoto(photo: {
  photoId: string;
  filename: string;
  mimeType: string;
  sizeBytes: number;
  width: number;
  height: number;
  uploadedAt: Timestamp;
  originalAvailable: boolean;
  purgedAt: Timestamp | null;
  status: "active";
}) {
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
      contentType: "image/webp",
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
    let firestoreQuery = photosCollection()
      .where("userId", "==", request.user!.uid)
      .where("status", "==", "active")
      .orderBy("uploadedAt", "desc")
      .limit(limit + 1);

    if (query.cursor) {
      firestoreQuery = firestoreQuery.startAfter(decodeCursor(query.cursor));
    }

    const snapshot = await firestoreQuery.get();
    const docs = snapshot.docs.map((doc) => doc.data());
    const hasMore = docs.length > limit;
    const pageData = hasMore ? docs.slice(0, limit) : docs;
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
