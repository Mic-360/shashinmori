import type { FastifyInstance } from "fastify";
import { cleanupQueue, uploadQueue } from "../../queues/definitions.js";
import { systemCollection } from "../../services/firestore.js";
import { createSuccess } from "../../types/api.js";

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

export async function registerSystemRoutes(app: FastifyInstance): Promise<void> {
  app.get("/health", {
    schema: {
      tags: ["System"],
      summary: "Health check",
      description: "Unauthenticated health endpoint for monitoring and load balancers.",
      security: [],
      response: {
        200: {
          type: "object",
          properties: {
            success: { const: true },
            data: {
              type: "object",
              properties: {
                status: { type: "string" },
                version: { type: "string" },
                uptime: { type: "number" }
              },
              required: ["status", "version", "uptime"]
            }
          },
          required: ["success", "data"]
        }
      }
    }
  }, async () => createSuccess({
    status: "ok",
    version: "1.0.0",
    uptime: process.uptime()
  }));

  app.get("/status", {
    preHandler: app.requireAuth,
    schema: {
      tags: ["System"],
      summary: "System status",
      description: "Returns storage status, queue state, and API quota visibility for authenticated clients.",
      security: [{ bearerAuth: [] }],
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
        401: errorSchema
      }
    }
  }, async () => {
    const storageSnapshot = await systemCollection().doc("storage-status").get();
    const storageData = storageSnapshot.exists ? storageSnapshot.data() : null;

    return createSuccess({
      storage: storageData,
      queues: {
        uploadsPaused: await uploadQueue.isPaused(),
        cleanupPaused: await cleanupQueue.isPaused()
      },
      apiQuotaState: "unknown"
    });
  });
}
