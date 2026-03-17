import RedisImport from "ioredis";
import type { ConnectionOptions } from "bullmq";
import { config } from "../config/env.js";

type RedisConstructor = new (
  url: string,
  options: {
    maxRetriesPerRequest: null;
    enableReadyCheck: false;
    tls: { rejectUnauthorized: true };
  },
) => {
  on(event: "error", listener: (error: Error) => void): void;
};

const Redis = RedisImport as unknown as RedisConstructor;

const redisClient = new Redis(config.upstashRedisTlsUrl, {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
  tls: { rejectUnauthorized: true }
});

redisClient.on("error", (error: Error) => {
  console.error("[Redis] connection error", error.message);
});

export const redisConnection = redisClient as unknown as ConnectionOptions;
