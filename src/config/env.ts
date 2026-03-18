import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { z } from "zod";

const currentFilePath = fileURLToPath(import.meta.url);
const currentDir = path.dirname(currentFilePath);
const projectRoot = path.resolve(currentDir, "..", "..");

function loadEnvFile() {
  const envPath = path.join(projectRoot, ".env");
  if (!existsSync(envPath)) {
    return;
  }

  const contents = readFileSync(envPath, "utf8");
  for (const rawLine of contents.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#")) {
      continue;
    }

    const separatorIndex = line.indexOf("=");
    if (separatorIndex === -1) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    const value = line.slice(separatorIndex + 1);

    if (!(key in process.env)) {
      process.env[key] = value;
    }
  }
}

loadEnvFile();

const envSchema = z.object({
  PORT: z.coerce.number().int().positive().default(3000),
  API_BASE_URL: z.string().min(1),
  ALLOWED_ORIGINS: z.string().min(1).default("*"),
  LOG_LEVEL: z.enum(["trace", "debug", "info", "warn", "error"]).default("info"),
  FIREBASE_PROJECT_ID: z.string().min(1),
  FIREBASE_CLIENT_EMAIL: z.string().min(1),
  FIREBASE_PRIVATE_KEY: z.string().min(1),
  UPSTASH_REDIS_REST_URL: z.string().url(),
  UPSTASH_REDIS_REST_TOKEN: z.string().min(1),
  UPSTASH_REDIS_TLS_URL: z.string().startsWith("rediss://"),
  UPLOAD_TEMP_DIR: z.string().min(1),
  SYNC_FOLDER_PATH: z.string().min(1),
  PREVIEW_DIR: z.string().min(1),
  MAX_UPLOAD_SIZE_BYTES: z.coerce.number().int().positive().default(2_147_483_648),
  MAX_UPLOADS_PER_USER_PER_HOUR: z.coerce.number().int().positive().default(20),
  STORAGE_WARN_THRESHOLD_MB: z.coerce.number().int().positive().default(500),
  STORAGE_PAUSE_THRESHOLD_MB: z.coerce.number().int().positive().default(200)
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error("Invalid environment configuration:");
  for (const issue of parsed.error.issues) {
    console.error(`- ${issue.path.join(".")}: ${issue.message}`);
  }

  process.exit(1);
}

const env = parsed.data;

export const config = {
  port: env.PORT,
  apiBaseUrl: env.API_BASE_URL,
  allowedOrigins: env.ALLOWED_ORIGINS,
  logLevel: env.LOG_LEVEL,
  firebaseProjectId: env.FIREBASE_PROJECT_ID,
  firebaseClientEmail: env.FIREBASE_CLIENT_EMAIL,
  firebasePrivateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
  upstashRedisRestUrl: env.UPSTASH_REDIS_REST_URL,
  upstashRedisRestToken: env.UPSTASH_REDIS_REST_TOKEN,
  upstashRedisTlsUrl: env.UPSTASH_REDIS_TLS_URL,
  uploadTempDir: env.UPLOAD_TEMP_DIR,
  syncFolderPath: env.SYNC_FOLDER_PATH,
  previewDir: env.PREVIEW_DIR,
  maxUploadSizeBytes: env.MAX_UPLOAD_SIZE_BYTES,
  maxUploadsPerUserPerHour: env.MAX_UPLOADS_PER_USER_PER_HOUR,
  storageWarnThresholdMb: env.STORAGE_WARN_THRESHOLD_MB,
  storagePauseThresholdMb: env.STORAGE_PAUSE_THRESHOLD_MB
} as const;

export type AppConfig = typeof config;
