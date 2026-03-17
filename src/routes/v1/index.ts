import type { FastifyInstance } from "fastify";
import { registerAuthRoutes } from "./auth.js";
import { registerPhotoRoutes } from "./photos.js";
import { registerSystemRoutes } from "./system.js";
import { registerUploadRoutes } from "./uploads.js";

export async function registerV1Routes(app: FastifyInstance): Promise<void> {
  await registerAuthRoutes(app);
  await registerUploadRoutes(app);
  await registerPhotoRoutes(app);
  await registerSystemRoutes(app);
}
