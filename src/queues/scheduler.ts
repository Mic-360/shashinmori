import { cleanupQueue, storageGuardQueue } from "./definitions.js";

export async function registerSchedulers(): Promise<void> {
  await storageGuardQueue.add(
    "storage-guard",
    { reason: "scheduled" },
    {
      jobId: "storage-guard-repeat",
      repeat: {
        every: 300_000
      }
    },
  );

  await cleanupQueue.add(
    "purge-originals",
    { type: "purge_originals", reason: "scheduled" },
    {
      jobId: "purge-originals-repeat",
      repeat: {
        every: 43_200_000
      }
    },
  );
}
