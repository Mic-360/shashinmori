import Fastify from "fastify";
import middie from "@fastify/middie";
import { config } from "./config/env.js";
import authPlugin from "./plugins/auth.js";
import corsPlugin from "./plugins/cors.js";
import errorHandlerPlugin from "./plugins/errorHandler.js";
import rateLimitPlugin from "./plugins/rateLimit.js";
import swaggerPlugin from "./plugins/swagger.js";
import { registerV1Routes } from "./routes/v1/index.js";
import { ensureRuntimeDirectories } from "./services/filesystem.js";

export async function buildServer() {
  await ensureRuntimeDirectories();

  const app = Fastify({
    logger: {
      level: config.logLevel
    }
  });

  await app.register(middie);
  await app.register(errorHandlerPlugin);
  await app.register(corsPlugin);
  await app.register(swaggerPlugin);
  await app.register(authPlugin);
  await app.register(rateLimitPlugin);
  await app.register(async (instance) => {
    await instance.register(async (v1) => {
      await registerV1Routes(v1);
    }, { prefix: "/v1" });
  });

  return app;
}
