import type { FastifyReply, FastifyRequest } from "fastify";

export interface ApiSuccess<T> {
  success: true;
  data: T;
}

export interface ApiList<T> {
  success: true;
  data: T[];
  nextCursor: string | null;
  hasMore: boolean;
}

export interface ApiErrorPayload {
  success: false;
  error: {
    code: string;
    message: string;
    requestId: string;
    details?: unknown;
  };
}

export interface AuthenticatedUser {
  uid: string;
  email: string;
}

export interface DecodedBearerToken {
  uid: string;
  email?: string;
}

declare module "fastify" {
  interface FastifyRequest {
    user?: AuthenticatedUser;
  }

  interface FastifyInstance {
    requireAuth: (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
    verifyFirebaseToken: (request: FastifyRequest) => Promise<DecodedBearerToken>;
    enforceUploadRateLimit: (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}

export class AppError extends Error {
  public readonly statusCode: number;
  public readonly code: string;
  public readonly details?: unknown;

  public constructor(
    code: string,
    message: string,
    statusCode = 500,
    details?: unknown,
  ) {
    super(message);
    this.name = "AppError";
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
  }
}

export function createSuccess<T>(data: T): ApiSuccess<T> {
  return { success: true, data };
}

export function createList<T>(
  data: T[],
  nextCursor: string | null,
  hasMore: boolean,
): ApiList<T> {
  return { success: true, data, nextCursor, hasMore };
}
