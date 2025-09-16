import { queryNFTListUsingCache } from "@shared/api/utilties.server";
import Exception from "@shared/exception";
import type { FilterType } from "@shared/flow/enums";
import type { APIRoute } from "astro";

export const GET: APIRoute = async ({ params, request }) => {
  const reviewer = params.reviewer;
  if (!reviewer) {
    throw new Exception(400, "The reviewer address is required");
  }
  const query = new URL(request.url).searchParams;
  const filter = parseInt(query.get("filter") || "0", 10) as FilterType;
  const pagination =
    query.get("page") && query.get("limit")
      ? {
          page: parseInt(query.get("page") || "0", 10),
          limit: parseInt(query.get("limit") || "100", 10),
        }
      : undefined;
  const isEVMOnly = query.get("evm") === "true";
  return new Response(
    JSON.stringify(
      await queryNFTListUsingCache(reviewer, filter, isEVMOnly, pagination),
    ),
  );
};
