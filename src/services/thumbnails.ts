import { mkdir, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import sharp from "sharp";
import { config } from "../config/env.js";

export interface LocalImageMetadata {
  width: number;
  height: number;
  sizeBytes: number;
  metadata: {
    format?: string;
    space?: string;
    channels?: number;
    density?: number;
    hasAlpha?: boolean;
    orientation?: number;
  } | null;
}

export async function inspectLocalImage(sourcePath: string): Promise<LocalImageMetadata> {
  const [imageMetadata, fileStat] = await Promise.all([
    sharp(sourcePath).metadata(),
    stat(sourcePath)
  ]);

  return {
    width: imageMetadata.width ?? 1,
    height: imageMetadata.height ?? 1,
    sizeBytes: fileStat.size,
    metadata: {
      format: imageMetadata.format,
      space: imageMetadata.space,
      channels: imageMetadata.channels,
      density: imageMetadata.density,
      hasAlpha: imageMetadata.hasAlpha,
      orientation: imageMetadata.orientation
    }
  };
}

export async function generatePreview(photoId: string, userId: string, sourcePath: string): Promise<string> {
  const outputPath = path.join(config.previewDir, userId, `${photoId}.webp`);

  await mkdir(path.dirname(outputPath), { recursive: true });
  const buffer = await sharp(sourcePath)
    .rotate()
    .resize(1280, 1280, { fit: "inside", withoutEnlargement: true })
    .webp({ quality: 72 })
    .toBuffer();

  await writeFile(outputPath, buffer);
  return outputPath;
}
