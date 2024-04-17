import { defineMiddleware } from "astro:middleware";
import Exception from "@shared/exception";

export const normalize = defineMiddleware(async ({ locals, request }, next) => {
  let response: Response | undefined = undefined;
  try {
    response = await next();
  } catch (e: any) {
    console.error("Request Error: ", e);
    if (e instanceof Exception) {
      response = new Response(
        JSON.stringify({
          success: false,
          error: {
            code: e.code,
            message: e.message,
          },
        }),
        { status: e.status },
      );
    } else {
      response = new Response(
        JSON.stringify({
          success: false,
          error: {
            message: `Internal Server Error: ${e.message}`,
          },
        }),
        { status: 500 },
      );
    }
  } finally {
    if (!response?.ok) {
      console.warn(`Invalid response: ${response?.status}`);
    } else {
      if (locals.isAPIEndpoint && request.method === "GET") {
        // ensure all response has cache control
        response.headers.set("Cache-Control", "public, max-age=60");
      }
    }
  }
  if (locals.isAPIEndpoint) {
    // ensure all response content type is application/json
    response.headers.set("content-type", "application/json");
    // ensure all response has CORS enabled
    response.headers.set("Access-Control-Allow-Origin", "*");
    // ensure all response has security headers
    response.headers.set("X-Content-Type-Options", "nosniff");
    response.headers.set("X-Frame-Options", "DENY");
    response.headers.set("X-XSS-Protection", "1; mode=block");
  }
  return response;
});

export default normalize;
