import { Worker } from "bullmq";
import checkDiskSpaceImport from "check-disk-space";
import { Timestamp } from "firebase-admin/firestore";
import pino from "pino";
import { config } from "../config/env.js";
import { redisConnection } from "../queues/connection.js";
import { storageGuardQueue, uploadQueue } from "../queues/definitions.js";
import { systemCollection } from "../services/firestore.js";
import type { StorageGuardJobPayload } from "../types/jobs.js";

const logger = pino({ level: config.logLevel });
const checkDiskSpace = checkDiskSpaceImport as unknown as (directoryPath: string) => Promise<{
  diskPath: string;
  free: number;
  size: number;
}>;

export const storageGuardWorker = new Worker<StorageGuardJobPayload>("storage-guard", async (job) => {
  const diskStatus = await checkDiskSpace(config.syncFolderPath);
  const freeMegabytes = Math.floor(diskStatus.free / (1024 * 1024));
  const warnThreshold = config.storageWarnThresholdMb;
  const pauseThreshold = config.storagePauseThresholdMb;

  let status: "ok" | "warn" | "paused" = "ok";
  if (freeMegabytes < pauseThreshold) {
    status = "paused";
  } else if (freeMegabytes < warnThreshold) {
    status = "warn";
  }

  if (status === "paused") {
    await uploadQueue.pause();
  } else if (await uploadQueue.isPaused() && freeMegabytes > warnThreshold) {
    await uploadQueue.resume();
  }

  await systemCollection().doc("storage-status").set({
    status,
    freeBytes: diskStatus.free,
    freeMegabytes,
    warnThresholdMb: warnThreshold,
    pauseThresholdMb: pauseThreshold,
    uploadsPaused: await uploadQueue.isPaused(),
    updatedAt: Timestamp.now()
  });

  logger.info({
    jobId: job.id,
    queue: job.queueName,
    userId: "system",
    filename: config.syncFolderPath,
    status,
    freeMegabytes
  }, "job completed");
}, {
  connection: redisConnection
});

storageGuardWorker.on("active", (job) => {
  logger.info({
    jobId: job.id,
    queue: job.queueName,
    userId: "system",
    filename: config.syncFolderPath
  }, "job started");
});

storageGuardWorker.on("failed", (job, error) => {
  logger.error({
    jobId: job?.id,
    queue: job?.queueName,
    userId: "system",
    filename: config.syncFolderPath,
    error: error.message
  }, "job failed");
});
