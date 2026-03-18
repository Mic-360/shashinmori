import path from "node:path";
import type { IncomingMessage } from "node:http";
import type { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import { FileStore } from "@tus/file-store";
import { Server as TusServer } from "@tus/server";
import type { Upload } from "@tus/utils";
import { Timestamp } from "firebase-admin/firestore";
import { config } from "../../config/env.js";
import { uploadQueue } from "../../queues/definitions.js";
import { photosCollection, uploadsCollection } from "../../services/firestore.js";
import type { AuthenticatedUser } from "../../types/api.js";
import { AppError, createSuccess } from "../../types/api.js";

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

function parseTusMetadata(headerValue: string | undefined): Record<string, string> {
  if (!headerValue) {
    return {};
  }

  return headerValue.split(",").reduce<Record<string, string>>((result, entry) => {
    const [rawKey, rawValue] = entry.trim().split(" ");
    if (!rawKey || !rawValue) {
      return result;
    }

    result[rawKey] = Buffer.from(rawValue, "base64").toString("utf8");
    return result;
  }, {});
}

interface TusIncomingMessage extends IncomingMessage {
  authenticatedUser?: AuthenticatedUser;
}

function getUploadMetadata(upload: Upload): Record<string, string | null> {
  return upload.metadata ?? {};
}

function setTusCorsHeaders(reply: FastifyReply, origin?: string) {
  if (origin) {
    reply.header("Access-Control-Allow-Origin", origin);
    reply.header("Access-Control-Allow-Credentials", "true");
  }

  reply.header(
    "Access-Control-Expose-Headers",
    "Location, Upload-Offset, Upload-Length, Tus-Resumable, Tus-Version, Tus-Extension, Tus-Max-Size, X-Upload-Id"
  );
  reply.header(
    "Access-Control-Allow-Headers",
    "Authorization, Content-Type, Upload-Offset, Upload-Length, Upload-Metadata, Tus-Resumable"
  );
  reply.header("Access-Control-Allow-Methods", "POST, HEAD, PATCH, OPTIONS");
  reply.header("Tus-Resumable", "1.0.0");
  reply.header("Tus-Version", "1.0.0");
  reply.header("Tus-Max-Size", String(config.maxUploadSizeBytes));
  reply.header("Tus-Extension", "creation,creation-with-upload,expiration");
}

export async function registerUploadRoutes(app: FastifyInstance): Promise<void> {
  const tusServer = new TusServer({
    path: "/v1/uploads",
    datastore: new FileStore({
      directory: config.uploadTempDir
    }),
    maxSize: config.maxUploadSizeBytes,
    async onUploadCreate(request, upload) {
      const metadata = getUploadMetadata(upload);
      const authUser = (request as unknown as TusIncomingMessage).authenticatedUser;
      if (!authUser) {
        throw new AppError("UNAUTHORIZED", "Authentication required", 401);
      }

      if (!metadata.userId || metadata.userId !== authUser.uid) {
        throw new AppError("UNAUTHORIZED", "Upload metadata userId must match authenticated user", 401);
      }

      const filename = metadata.filename?.trim();
      const mimeType = metadata.mimeType?.trim();
      if (!filename || !mimeType) {
        throw new AppError("VALIDATION_ERROR", "Tus metadata must include filename and mimeType", 400);
      }

      const uploadId = upload.id;
      await uploadsCollection().doc(uploadId).set({
        uploadId,
        photoId: uploadId,
        userId: authUser.uid,
        filename,
        tempPath: path.join(config.uploadTempDir, uploadId),
        originalPath: null,
        previewPath: null,
        status: "pending",
        retryCount: 0,
        failureReason: null,
        createdAt: Timestamp.now(),
        availableAt: null
      }, { merge: true });

      return {
        metadata
      };
    },
    async onUploadFinish(request, upload) {
      const metadata = getUploadMetadata(upload);
      const authUser = (request as unknown as TusIncomingMessage).authenticatedUser;
      if (!authUser) {
        throw new AppError("UNAUTHORIZED", "Authentication required", 401);
      }

      const uploadId = upload.id;
      await uploadQueue.add("photo-upload", {
        uploadId,
        photoId: uploadId,
        userId: authUser.uid,
        filename: metadata.filename ?? uploadId,
        localPath: path.join(config.uploadTempDir, uploadId),
        mimeType: metadata.mimeType ?? "application/octet-stream"
      });

      return {
        headers: {
          "X-Upload-Id": uploadId
        }
      };
    }
  });

  const tusHandler = async (request: FastifyRequest, reply: FastifyReply) => {
    const origin = request.headers.origin;
    app.log.info({
      requestId: request.id,
      method: request.method,
      url: request.url,
      origin,
      hasAuthorization: typeof request.headers.authorization === "string",
      uploadLength: request.headers["upload-length"],
      tusResumable: request.headers["tus-resumable"],
      uploadMetadata: request.headers["upload-metadata"]
    }, "tus request received");

    if (request.method === "OPTIONS") {
      setTusCorsHeaders(reply, origin);
      await reply.code(204).send();
      return;
    }

    await app.requireAuth(request, reply);
    (request.raw as TusIncomingMessage).authenticatedUser = request.user;

    if (request.method === "POST") {
      await app.enforceUploadRateLimit(request, reply);
      const metadata = parseTusMetadata(request.headers["upload-metadata"] as string | undefined);
      if (!metadata.userId || metadata.userId !== request.user!.uid) {
        throw new AppError("UNAUTHORIZED", "Upload metadata userId must match authenticated user", 401);
      }
    }

    setTusCorsHeaders(reply, origin);

    reply.hijack();
    await tusServer.handle(request.raw, reply.raw);
  };

  app.route({
    method: ["POST", "HEAD", "PATCH", "OPTIONS"],
    url: "/uploads",
    schema: {
      tags: ["Uploads"],
      summary: "Tus resumable upload endpoint",
      description: "Handles tus protocol creation, chunk uploads, and resumable upload state.",
      security: [{ bearerAuth: [] }],
      response: {
        200: { type: "null" },
        201: { type: "null" },
        204: { type: "null" },
        400: errorSchema,
        401: errorSchema,
        429: errorSchema
      }
    },
    handler: tusHandler
  });

  app.route({
    method: ["HEAD", "PATCH", "OPTIONS"],
    url: "/uploads/:id",
    schema: {
      tags: ["Uploads"],
      summary: "Tus upload chunk endpoint",
      description: "Handles tus chunk patching and status lookups for an individual upload.",
      security: [{ bearerAuth: [] }],
      response: {
        200: { type: "null" },
        204: { type: "null" },
        400: errorSchema,
        401: errorSchema,
        429: errorSchema
      }
    },
    handler: tusHandler
  });

  app.get("/uploads/:uploadId/status", {
    preHandler: app.requireAuth,
    schema: {
      tags: ["Uploads"],
      summary: "Upload status",
      description: "Returns the authenticated user's upload processing state.",
      security: [{ bearerAuth: [] }],
      params: {
        type: "object",
        required: ["uploadId"],
        properties: {
          uploadId: { type: "string", minLength: 1 }
        }
      },
      response: {
        200: {
          type: "object",
          properties: {
            success: { const: true },
            data: {
              type: "object",
              additionalProperties: true
            }
          },
          required: ["success", "data"]
        },
        401: errorSchema,
        404: errorSchema
      }
    }
  }, async (request) => {
    const { uploadId } = request.params as { uploadId: string };
    const uploadSnapshot = await uploadsCollection().doc(uploadId).get();
    const upload = uploadSnapshot.data();

    if (!uploadSnapshot.exists || !upload || upload.userId !== request.user!.uid) {
      throw new AppError("NOT_FOUND", "Upload not found", 404);
    }

    let photo = null;
    if (upload.status === "available") {
      const photoSnapshot = await photosCollection().doc(upload.photoId).get();
      const found = photoSnapshot.data();
      photo = photoSnapshot.exists && found?.userId === request.user!.uid
        ? {
            photoId: found.photoId,
            filename: found.filename,
            mimeType: found.mimeType,
            sizeBytes: found.sizeBytes,
            width: found.width,
            height: found.height,
            uploadedAt: found.uploadedAt.toDate().toISOString(),
            originalAvailable: found.originalAvailable,
            purgedAt: found.purgedAt ? found.purgedAt.toDate().toISOString() : null,
            status: found.status
          }
        : null;
    }

    return createSuccess({
      uploadId,
      photoId: upload.photoId,
      status: upload.status,
      failureReason: upload.failureReason ?? undefined,
      photo
    });
  });
}
