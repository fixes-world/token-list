import { defineMiddleware } from "astro:middleware";

export const filter = defineMiddleware(async ({ locals, request }, next) => {
  const path = new URL(request.url).pathname;
  locals.isAPIEndpoint = path.startsWith("/api");
  return await next();
});

export default filter;
