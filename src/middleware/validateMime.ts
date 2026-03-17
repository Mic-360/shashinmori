import { fileTypeFromFile } from "file-type";
import { AppError } from "../types/api.js";

export async function validateMagicMime(
  filePath: string,
  expectedMime?: string,
): Promise<string> {
  const detected = await fileTypeFromFile(filePath);

  if (!detected || !detected.mime.startsWith("image/")) {
    throw new AppError("UNSUPPORTED_MEDIA_TYPE", "Only image uploads are supported", 415);
  }

  if (expectedMime && expectedMime !== detected.mime) {
    throw new AppError("MIME_MISMATCH", "Uploaded file MIME type does not match metadata", 400, {
      expectedMime,
      detectedMime: detected.mime
    });
  }

  return detected.mime;
}
