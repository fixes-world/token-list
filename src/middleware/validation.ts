import { defineMiddleware } from "astro:middleware";
import Exception from "@shared/exception";

export const validation = defineMiddleware(async ({ locals, request }, next) => {
  // validation for API endpoints
  if (locals.isAPIEndpoint) {
    const contentType = request.headers.get("content-type");
    if (request.method !== "GET" && contentType !== "application/json") {
      console.warn(`Invalid content type: ${contentType}`);
      throw new Exception(400, `Invalid content type: ${contentType}`);
    }
  }
  return await next();
});

export default validation;
