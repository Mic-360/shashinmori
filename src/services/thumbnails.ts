import { mkdir, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { Jimp } from "jimp";
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
  const [image, fileStat] = await Promise.all([
    Jimp.read(sourcePath),
    stat(sourcePath)
  ]);

  const extension = path.extname(sourcePath).toLowerCase();
  const format = extension ? extension.slice(1) : undefined;

  return {
    width: image.bitmap.width || 1,
    height: image.bitmap.height || 1,
    sizeBytes: fileStat.size,
    metadata: {
      format,
      hasAlpha: Boolean(image.hasAlpha())
    }
  };
}

export async function generatePreview(photoId: string, userId: string, sourcePath: string): Promise<string> {
  const outputPath = path.join(config.previewDir, userId, `${photoId}.jpg`);

  await mkdir(path.dirname(outputPath), { recursive: true });
  const image = await Jimp.read(sourcePath);
  image.scaleToFit({ w: 1280, h: 1280 });
  const buffer = await image.getBuffer("image/jpeg");

  await writeFile(outputPath, buffer);
  return outputPath;
}
