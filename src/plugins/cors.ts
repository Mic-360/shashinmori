import fp from "fastify-plugin";
import cors from "@fastify/cors";
import type { FastifyInstance } from "fastify";
import { config } from "../config/env.js";

function normalizeOrigin(origin: string) {
  return origin.trim().replace(/\/+$/, "");
}

function parseAllowedOrigins() {
  if (config.allowedOrigins.trim() === "*") {
    return true as const;
  }

  return new Set(
    config.allowedOrigins
      .split(",")
      .map((origin: string) => normalizeOrigin(origin))
      .filter((origin: string) => origin.length > 0)
  );
}

export default fp(async function corsPlugin(app: FastifyInstance) {
  const allowedOrigins = parseAllowedOrigins();

  await app.register(cors, {
    origin(origin, callback) {
      if (!origin) {
        callback(null, true);
        return;
      }

      if (allowedOrigins === true) {
        callback(null, true);
        return;
      }

      callback(null, allowedOrigins.has(normalizeOrigin(origin)));
    },
    methods: ["GET", "POST", "OPTIONS", "PATCH", "HEAD"],
    allowedHeaders: [
      "Authorization",
      "Content-Type",
      "Upload-Offset",
      "Upload-Length",
      "Upload-Metadata",
      "Tus-Resumable"
    ],
    exposedHeaders: [
      "Location",
      "Upload-Offset",
      "Upload-Length",
      "Tus-Resumable",
      "Tus-Version",
      "Tus-Extension",
      "Tus-Max-Size",
      "X-Upload-Id"
    ],
    credentials: true,
    maxAge: 86_400
  });
});
