import type { Timestamp } from "firebase-admin/firestore";

export interface UserRecord {
  uid: string;
  email: string;
  displayName: string;
  photoURL: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface UploadRecord {
  uploadId: string;
  photoId: string;
  userId: string;
  filename: string;
  tempPath: string;
  originalPath: string | null;
  previewPath: string | null;
  status: "pending" | "processing" | "available" | "failed";
  retryCount: number;
  failureReason: string | null;
  createdAt: Timestamp;
  availableAt: Timestamp | null;
}

export interface PhotoRecord {
  photoId: string;
  userId: string;
  filename: string;
  mimeType: string;
  sizeBytes: number;
  width: number;
  height: number;
  uploadedAt: Timestamp;
  originalPath: string;
  previewPath: string;
  originalAvailable: boolean;
  purgedAt: Timestamp | null;
  status: "active";
  metadata: {
    format?: string;
    space?: string;
    channels?: number;
    density?: number;
    hasAlpha?: boolean;
    orientation?: number;
  } | null;
}

export interface StorageStatusRecord {
  status: "ok" | "warn" | "paused";
  freeBytes: number;
  freeMegabytes: number;
  warnThresholdMb: number;
  pauseThresholdMb: number;
  uploadsPaused: boolean;
  updatedAt: Timestamp;
}
