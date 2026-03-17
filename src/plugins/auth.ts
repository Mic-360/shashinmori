import fp from "fastify-plugin";
import type { FastifyInstance, FastifyRequest } from "fastify";
import { firebaseAuth } from "../services/firestore.js";
import { AppError, type AuthenticatedUser, type DecodedBearerToken } from "../types/api.js";

function getFirebaseToken(request: FastifyRequest): string {
  const authorization = request.headers.authorization;
  if (authorization?.startsWith("Bearer ")) {
    return authorization.slice("Bearer ".length).trim();
  }

  const query = request.query as { token?: unknown } | undefined;
  if (typeof query?.token === "string" && query.token.trim().length > 0) {
    return query.token.trim();
  }

  throw new AppError("UNAUTHORIZED", "Missing Firebase ID token", 401);
}

function toAuthenticatedUser(token: DecodedBearerToken): AuthenticatedUser {
  return {
    uid: token.uid,
    email: token.email ?? ""
  };
}

export default fp(async function authPlugin(app: FastifyInstance) {
  app.decorate("verifyFirebaseToken", async (request: FastifyRequest) => {
    try {
      const token = getFirebaseToken(request);
      const decoded = await firebaseAuth.verifyIdToken(token);
      return {
        uid: decoded.uid,
        email: decoded.email
      };
    } catch {
      throw new AppError("UNAUTHORIZED", "Invalid Firebase ID token", 401);
    }
  });

  app.decorate("requireAuth", async (request: FastifyRequest) => {
    const decoded = await app.verifyFirebaseToken(request);
    request.user = toAuthenticatedUser(decoded);
  });
});
