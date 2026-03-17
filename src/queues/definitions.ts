import { Queue } from "bullmq";
import { redisConnection } from "./connection.js";

const defaultJobOptions = {
  attempts: 3,
  backoff: { type: "exponential" as const, delay: 30_000 },
  removeOnComplete: { count: 100 },
  removeOnFail: { count: 500 }
};

export const uploadQueue = new Queue("photo-upload", {
  connection: redisConnection,
  defaultJobOptions
});

export const cleanupQueue = new Queue("cleanup", {
  connection: redisConnection,
  defaultJobOptions
});

export const storageGuardQueue = new Queue("storage-guard", {
  connection: redisConnection,
  defaultJobOptions
});
