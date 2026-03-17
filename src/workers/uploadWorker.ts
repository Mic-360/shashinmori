import path from "node:path";
import { Worker } from "bullmq";
import { Timestamp } from "firebase-admin/firestore";
import pino from "pino";
import { config } from "../config/env.js";
import { validateMagicMime } from "../middleware/validateMime.js";
import { redisConnection } from "../queues/connection.js";
import { moveFileSafely, sanitizeFilename } from "../services/filesystem.js";
import { photosCollection, uploadsCollection } from "../services/firestore.js";
import { generatePreview, inspectLocalImage } from "../services/thumbnails.js";
import type { UploadJobPayload } from "../types/jobs.js";

const logger = pino({ level: config.logLevel });

export const uploadWorker = new Worker<UploadJobPayload>("photo-upload", async (job) => {
  const { uploadId, photoId, userId, filename, localPath, mimeType } = job.data;
  const maxAttempts = typeof job.opts.attempts === "number" ? job.opts.attempts : 1;
  const currentAttempt = job.attemptsMade + 1;

  await uploadsCollection().doc(uploadId).set({
    status: "processing",
    retryCount: job.attemptsMade,
    failureReason: null
  }, { merge: true });

  try {
    const actualMimeType = await validateMagicMime(localPath, mimeType);
    const imageDetails = await inspectLocalImage(localPath);
    const sanitizedFilename = sanitizeFilename(filename);
    const originalPath = path.join(config.syncFolderPath, userId, `${photoId}-${sanitizedFilename}`);

    await moveFileSafely(localPath, originalPath, config.syncFolderPath);
    const previewPath = await generatePreview(photoId, userId, originalPath);
    const uploadedAt = Timestamp.now();

    await photosCollection().doc(photoId).set({
      photoId,
      userId,
      filename: sanitizedFilename,
      mimeType: actualMimeType,
      sizeBytes: imageDetails.sizeBytes,
      width: imageDetails.width,
      height: imageDetails.height,
      uploadedAt,
      originalPath,
      previewPath,
      originalAvailable: true,
      purgedAt: null,
      status: "active",
      metadata: imageDetails.metadata
    });

    await uploadsCollection().doc(uploadId).set({
      photoId,
      originalPath,
      previewPath,
      status: "available",
      availableAt: uploadedAt,
      retryCount: job.attemptsMade,
      failureReason: null
    }, { merge: true });

    logger.info({
      jobId: job.id,
      queue: job.queueName,
      userId,
      filename: sanitizedFilename,
      photoId,
      originalPath,
      previewPath
    }, "job completed");
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);

    await uploadsCollection().doc(uploadId).set({
      status: currentAttempt >= maxAttempts ? "failed" : "processing",
      retryCount: currentAttempt,
      failureReason: currentAttempt >= maxAttempts ? message.slice(0, 500) : null
    }, { merge: true });

    throw error;
  }
}, {
  connection: redisConnection
});

uploadWorker.on("active", (job) => {
  logger.info({
    jobId: job.id,
    queue: job.queueName,
    userId: job.data.userId,
    filename: job.data.filename
  }, "job started");
});

uploadWorker.on("failed", (job, error) => {
  logger.error({
    jobId: job?.id,
    queue: job?.queueName,
    userId: job?.data.userId,
    filename: job?.data.filename,
    error: error.message
  }, "job failed");
});
