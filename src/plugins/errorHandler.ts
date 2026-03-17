import fp from "fastify-plugin";
import type { FastifyInstance } from "fastify";
import { ZodError } from "zod";
import { AppError, type ApiErrorPayload } from "../types/api.js";

function buildErrorPayload(
  requestId: string,
  code: string,
  message: string,
  details?: unknown,
): ApiErrorPayload {
  return {
    success: false,
    error: {
      code,
      message,
      requestId,
      ...(details === undefined ? {} : { details })
    }
  };
}

export default fp(async function errorHandlerPlugin(app: FastifyInstance) {
  app.setNotFoundHandler(async (request, reply) => {
    const payload = buildErrorPayload(reply.request.id, "NOT_FOUND", "Route not found");
    await reply.status(404).send(payload);
  });

  app.setErrorHandler(async (error, request, reply) => {
    request.log.error(
      {
        err: error,
        requestId: request.id
      },
      "request failed",
    );

    if (error instanceof AppError) {
      await reply.status(error.statusCode).send(
        buildErrorPayload(request.id, error.code, error.message, error.details),
      );
      return;
    }

    if (error instanceof ZodError) {
      await reply.status(400).send(
        buildErrorPayload(request.id, "VALIDATION_ERROR", "Validation failed", error.flatten()),
      );
      return;
    }

    if (
      typeof error === "object"
      && error !== null
      && "validation" in error
      && "message" in error
      && error.validation
    ) {
      await reply.status(400).send(
        buildErrorPayload(
          request.id,
          "VALIDATION_ERROR",
          String(error.message),
          error.validation,
        ),
      );
      return;
    }

    const statusCode = (
      typeof error === "object"
      && error !== null
      && "statusCode" in error
      && typeof error.statusCode === "number"
      && error.statusCode >= 400
    )
      ? error.statusCode
      : 500;
    const code = statusCode === 401 ? "UNAUTHORIZED" : "INTERNAL_SERVER_ERROR";
    const message = statusCode === 500
      ? "Internal server error"
      : error instanceof Error
        ? error.message
        : "Request failed";

    await reply.status(statusCode).send(buildErrorPayload(request.id, code, message));
  });
});
