import type { APIRoute } from "astro";
import { queryReviewersUsingCache } from "@shared/api/utilties.server";

export const GET: APIRoute = async ({ params, request }) => {
  return new Response(JSON.stringify(await queryReviewersUsingCache()));
};
