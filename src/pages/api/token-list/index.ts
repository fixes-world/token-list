import type { APIRoute } from "astro";
import type { FilterType } from "@shared/flow/enums";
import { queryTokenListUsingCache } from "@shared/api/utilties.server";

export const GET: APIRoute = async ({ request }) => {
  const query = new URL(request.url).searchParams;
  const filter = parseInt(query.get("filter") || "0") as FilterType;
  const pagination =
    query.get("page") && query.get("limit")
      ? {
          page: parseInt(query.get("page") || "0"),
          limit: parseInt(query.get("limit") || "100"),
        }
      : undefined;
  const isEVMOnly = query.get("evm") === "true";
  return new Response(
    JSON.stringify(
      await queryTokenListUsingCache(undefined, filter, isEVMOnly, pagination),
    ),
  );
};
