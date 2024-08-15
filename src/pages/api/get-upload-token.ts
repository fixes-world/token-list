import type { APIRoute } from "astro";
import { generateQiniuUploadToken } from "@shared/api/utilties.server";

export const GET: APIRoute = async ({ params, request }) => {
  const token = generateQiniuUploadToken();
  // expire in 1 hour
  const expireAt = Date.now() + 3600 * 1000;
  return new Response(JSON.stringify({ token, expireAt }));
};
