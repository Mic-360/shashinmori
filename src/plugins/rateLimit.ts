import fp from "fastify-plugin";
import fastifyRateLimit from "@fastify/rate-limit";
import type { FastifyInstance, FastifyRequest } from "fastify";
import { config } from "../config/env.js";
import { incrementCounter } from "../services/cache.js";
import { AppError } from "../types/api.js";

export default fp(async function rateLimitPlugin(app: FastifyInstance) {
  await app.register(fastifyRateLimit, {
    global: false,
    max: 200,
    timeWindow: "1 minute"
  });

  app.decorate("enforceUploadRateLimit", async (request: FastifyRequest) => {
    const user = request.user ?? (() => {
      throw new AppError("UNAUTHORIZED", "Authentication required", 401);
    })();

    const key = `upload-rate:${user.uid}`;
    const currentCount = await incrementCounter(key, 60 * 60);
    if (currentCount > config.maxUploadsPerUserPerHour) {
      throw new AppError(
        "RATE_LIMITED",
        "Upload limit reached for the current hour",
        429,
        { limit: config.maxUploadsPerUserPerHour },
      );
    }
  });
});
