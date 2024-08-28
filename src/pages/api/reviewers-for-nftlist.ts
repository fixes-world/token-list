import type { APIRoute } from "astro";
import { queryReviewersForNFTListUsingCache } from "@shared/api/utilties.server";

export const GET: APIRoute = async ({ params, request }) => {
  return new Response(
    JSON.stringify(await queryReviewersForNFTListUsingCache()),
  );
};
