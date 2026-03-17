export interface UploadJobPayload {
  uploadId: string;
  photoId: string;
  userId: string;
  filename: string;
  localPath: string;
  mimeType: string;
}

export interface OriginalsPurgeJobPayload {
  type: "purge_originals";
  reason: "scheduled" | "manual";
}

export type CleanupJobPayload = OriginalsPurgeJobPayload;

export interface StorageGuardJobPayload {
  reason: "scheduled" | "manual";
}
