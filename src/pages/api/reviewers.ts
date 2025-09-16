import { queryReviewersUsingCache } from "@shared/api/utilties.server";
import type { APIRoute } from "astro";

export const GET: APIRoute = async () => {
  return new Response(JSON.stringify(await queryReviewersUsingCache()));
};
