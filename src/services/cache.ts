import { Redis } from "@upstash/redis";
import { config } from "../config/env.js";

export const cache = new Redis({
  url: config.upstashRedisRestUrl,
  token: config.upstashRedisRestToken
});

const REDIS_BACKOFF_MS = 60_000;
let redisUnavailableUntil = 0;
let lastRedisWarningAt = 0;

function isRedisTemporarilyUnavailable(): boolean {
  return Date.now() < redisUnavailableUntil;
}

function markRedisUnavailable(error: unknown): void {
  const now = Date.now();
  redisUnavailableUntil = now + REDIS_BACKOFF_MS;

  if (now - lastRedisWarningAt >= REDIS_BACKOFF_MS) {
    const message = error instanceof Error ? error.message : String(error);
    console.warn(`Redis unavailable, cache operations are bypassed for 60s: ${message}`);
    lastRedisWarningAt = now;
  }
}

async function safeCacheOperation<T>(
  operation: () => Promise<T>,
  fallbackValue: T,
): Promise<T> {
  if (isRedisTemporarilyUnavailable()) {
    return fallbackValue;
  }

  try {
    return await operation();
  } catch (error) {
    markRedisUnavailable(error);
    return fallbackValue;
  }
}

export async function getCached<T>(key: string): Promise<T | null> {
  const value = await safeCacheOperation(() => cache.get<string>(key), null);
  if (value === null || value === undefined) {
    return null;
  }

  if (typeof value !== "string") {
    return value as T;
  }

  return JSON.parse(value) as T;
}

export async function setCached<T>(
  key: string,
  value: T,
  ttlSeconds: number,
): Promise<void> {
  await safeCacheOperation(
    () => cache.set(key, JSON.stringify(value), { ex: ttlSeconds }),
    "OK",
  );
}

export async function deleteCached(key: string): Promise<void> {
  await safeCacheOperation(() => cache.del(key), 0);
}

export async function incrementCounter(key: string, ttlSeconds: number): Promise<number> {
  const value = await safeCacheOperation(() => cache.incr(key), 1);
  if (value === 1) {
    await safeCacheOperation(() => cache.expire(key, ttlSeconds), 0);
  }

  return value;
}
