import type { APIRoute } from "astro";

export const GET: APIRoute = async ({ params, request }) => {
  let ret = {};
  return new Response(JSON.stringify(ret));
};
