import { copyFile, mkdir, rename, stat, unlink } from "node:fs/promises";
import path from "node:path";
import { config } from "../config/env.js";
import { AppError } from "../types/api.js";

function normalizeBaseDir(baseDir: string): string {
  const resolved = path.resolve(baseDir);
  return resolved.endsWith(path.sep) ? resolved : `${resolved}${path.sep}`;
}

export function assertWithinBaseDir(inputPath: string, expectedBaseDir: string): string {
  const resolved = path.resolve(inputPath);
  const normalizedBase = normalizeBaseDir(expectedBaseDir);
  const normalizedResolved = resolved.endsWith(path.sep) ? resolved : resolved;

  if (!normalizedResolved.startsWith(normalizedBase) && resolved !== path.resolve(expectedBaseDir)) {
    throw new AppError("PATH_TRAVERSAL", "Path traversal detected", 400, {
      inputPath: resolved,
      expectedBaseDir
    });
  }

  return resolved;
}

export async function ensureRuntimeDirectories(): Promise<void> {
  await Promise.all([
    mkdir(config.uploadTempDir, { recursive: true }),
    mkdir(config.syncFolderPath, { recursive: true }),
    mkdir(config.previewDir, { recursive: true })
  ]);
}

export function sanitizeFilename(filename: string): string {
  const extension = path.extname(filename).slice(0, 16);
  const basename = path.basename(filename, extension);
  const safeBase = basename
    .trim()
    .replace(/[^a-zA-Z0-9-_]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 80);

  const fallback = safeBase.length > 0 ? safeBase : "upload";
  return `${fallback}${extension.toLowerCase()}`;
}

export async function moveFileSafely(
  sourcePath: string,
  destinationPath: string,
  destinationBaseDir: string,
): Promise<void> {
  const source = assertWithinBaseDir(sourcePath, config.uploadTempDir);
  const destination = assertWithinBaseDir(destinationPath, destinationBaseDir);

  await mkdir(path.dirname(destination), { recursive: true });

  try {
    await rename(source, destination);
  } catch {
    await copyFile(source, destination);
    await unlink(source);
  }
}

export async function safeDeleteFile(filePath: string, expectedBaseDir: string): Promise<void> {
  const resolved = assertWithinBaseDir(filePath, expectedBaseDir);
  await unlink(resolved);
}

export async function fileExists(filePath: string): Promise<boolean> {
  try {
    await stat(filePath);
    return true;
  } catch {
    return false;
  }
}
