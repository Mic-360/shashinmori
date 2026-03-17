import { Redis } from "@upstash/redis";
import { config } from "../config/env.js";

export const cache = new Redis({
  url: config.upstashRedisRestUrl,
  token: config.upstashRedisRestToken
});

export async function getCached<T>(key: string): Promise<T | null> {
  const value = await cache.get<string>(key);
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
  await cache.set(key, JSON.stringify(value), { ex: ttlSeconds });
}

export async function deleteCached(key: string): Promise<void> {
  await cache.del(key);
}

export async function incrementCounter(key: string, ttlSeconds: number): Promise<number> {
  const value = await cache.incr(key);
  if (value === 1) {
    await cache.expire(key, ttlSeconds);
  }

  return value;
}
