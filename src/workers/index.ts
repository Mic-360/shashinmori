import { registerSchedulers } from "../queues/scheduler.js";
import { cleanupWorker } from "./cleanupWorker.js";
import { storageGuardWorker } from "./storageGuardWorker.js";
import { uploadWorker } from "./uploadWorker.js";

export async function startWorkers() {
  await registerSchedulers();

  return [
    uploadWorker,
    cleanupWorker,
    storageGuardWorker
  ];
}
