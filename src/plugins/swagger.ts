import fp from "fastify-plugin";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import type { FastifyInstance } from "fastify";
import { config } from "../config/env.js";

export default fp(async function swaggerPlugin(app: FastifyInstance) {
  await app.register(swagger, {
    mode: "dynamic",
    openapi: {
      openapi: "3.0.3",
      info: {
        title: "ShashinMori API",
        description: [
          "SDK-ready REST API for ShashinMori.",
          "",
          "Authentication: send a Firebase ID token as `Authorization: Bearer <token>`.",
          "Frontends obtain this token through Firebase Auth after Google Sign-In.",
          "",
          "Errors always use the envelope `{ success: false, error: { code, message, requestId, details? } }`."
        ].join("\n"),
        version: "1.0.0"
      },
      servers: [
        {
          url: config.apiBaseUrl
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: "http",
            scheme: "bearer",
            bearerFormat: "Firebase JWT"
          }
        }
      }
    }
  });

  await app.register(swaggerUi, {
    routePrefix: "/docs"
  });

  app.get("/openapi.json", {
    schema: {
      tags: ["Docs"],
      summary: "OpenAPI JSON",
      description: "Returns the generated OpenAPI specification for the current API build.",
      security: [],
      response: {
        200: {
          type: "object",
          additionalProperties: true
        }
      }
    }
  }, async () => app.swagger());
});
