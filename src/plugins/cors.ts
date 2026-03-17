import fp from "fastify-plugin";
import cors from "@fastify/cors";
import type { FastifyInstance } from "fastify";
import { config } from "../config/env.js";

function parseAllowedOrigins() {
  if (config.allowedOrigins.trim() === "*") {
    return true;
  }

  return config.allowedOrigins
    .split(",")
    .map((origin: string) => origin.trim())
    .filter((origin: string) => origin.length > 0);
}

export default fp(async function corsPlugin(app: FastifyInstance) {
  await app.register(cors, {
    origin: parseAllowedOrigins(),
    methods: ["GET", "POST", "DELETE", "OPTIONS", "PATCH"],
    allowedHeaders: [
      "Authorization",
      "Content-Type",
      "Upload-Offset",
      "Upload-Length",
      "Upload-Metadata",
      "Tus-Resumable"
    ],
    credentials: true,
    maxAge: 86_400
  });
});
