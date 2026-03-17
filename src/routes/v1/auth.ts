import type { FastifyInstance } from "fastify";
import { Timestamp } from "firebase-admin/firestore";
import { usersCollection } from "../../services/firestore.js";
import { AppError, createSuccess } from "../../types/api.js";

const profileBodySchema = {
  type: "object",
  required: ["displayName", "photoURL"],
  properties: {
    displayName: { type: "string", minLength: 1 },
    photoURL: { type: "string", minLength: 1 }
  }
} as const;

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

export async function registerAuthRoutes(app: FastifyInstance): Promise<void> {
  app.post("/auth/profile", {
    schema: {
      tags: ["Auth"],
      summary: "Upsert user profile",
      description: "Verifies the Firebase bearer token and upserts the authenticated user's profile in Firestore.",
      security: [{ bearerAuth: [] }],
      body: profileBodySchema,
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
        400: errorSchema
      }
    }
  }, async (request) => {
    const decoded = await app.verifyFirebaseToken(request);
    const email = decoded.email;
    if (!email) {
      throw new AppError("INVALID_TOKEN", "Firebase token does not include an email address", 400);
    }

    const body = request.body as { displayName: string; photoURL: string };
    const userRef = usersCollection().doc(decoded.uid);
    const now = Timestamp.now();
    const existing = await userRef.get();

    await userRef.set({
      uid: decoded.uid,
      email,
      displayName: body.displayName,
      photoURL: body.photoURL,
      createdAt: existing.exists ? existing.data()?.createdAt ?? now : now,
      updatedAt: now
    }, { merge: true });

    return createSuccess((await userRef.get()).data());
  });
}
