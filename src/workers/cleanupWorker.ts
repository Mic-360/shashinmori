import { Worker } from "bullmq";
import { Timestamp } from "firebase-admin/firestore";
import pino from "pino";
import { config } from "../config/env.js";
import { redisConnection } from "../queues/connection.js";
import { fileExists, safeDeleteFile } from "../services/filesystem.js";
import { photosCollection } from "../services/firestore.js";
import type { CleanupJobPayload } from "../types/jobs.js";

const logger = pino({ level: config.logLevel });

export const cleanupWorker = new Worker<CleanupJobPayload>("cleanup", async (job) => {
  if (job.data.type !== "purge_originals") {
    return;
  }

  const snapshot = await photosCollection()
    .where("status", "==", "active")
    .where("originalAvailable", "==", true)
    .get();

  for (const doc of snapshot.docs) {
    const photo = doc.data();
    const originalExists = await fileExists(photo.originalPath);
    const purgedAt = photo.purgedAt ?? Timestamp.now();

    if (originalExists) {
      await safeDeleteFile(photo.originalPath, config.syncFolderPath);
    }

    await doc.ref.set({
      originalAvailable: false,
      purgedAt
    }, { merge: true });
  }

  logger.info({
    jobId: job.id,
    queue: job.queueName,
    reason: job.data.reason,
    purgedCount: snapshot.size
  }, "job completed");
}, {
  connection: redisConnection
});

cleanupWorker.on("active", (job) => {
  logger.info({
    jobId: job.id,
    queue: job.queueName,
    reason: job.data.reason
  }, "job started");
});

cleanupWorker.on("failed", (job, error) => {
  logger.error({
    jobId: job?.id,
    queue: job?.queueName,
    reason: job?.data.reason,
    error: error.message
  }, "job failed");
});
