import Exception from "@shared/exception";
import type { APIRoute } from "astro";

export const ALL: APIRoute = async (_req) => {
  return new Response(
    JSON.stringify({
      success: false,
      error: {
        code: 404,
        message: "Endpoint Not Found",
      },
    }),
    { status: 404 },
  );
};
