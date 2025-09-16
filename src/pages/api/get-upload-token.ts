import { generateQiniuUploadToken } from "@shared/api/utilties.server";
import type { APIRoute } from "astro";

export const GET: APIRoute = async () => {
  const token = generateQiniuUploadToken();
  // expire in 1 hour
  const expireAt = Date.now() + 3600 * 1000;
  return new Response(JSON.stringify({ token, expireAt }));
};
