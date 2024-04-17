import { FilterType } from "@shared/flow/enums";
import Exception from "@shared/exception";

/**
 * Send a request to the OpenAPI server
 * @param path
 * @param body
 */
async function queryTokenList(
  page: number,
  limit: number,
  reviewer?: string,
  filter: FilterType = FilterType.ALL,
) {
  // const res = await fetch("/api/token-list", {
  //   method: "GET",
  //   body: JSON.stringify({ path, data: body, verify: verifyDto }),
  //   headers: {
  //     "Content-Type": "application/json",
  //   },
  // });
  // if (res.status >= 200 && res.status < 300) {
  //   try {
  //     return await res.json();
  //   } catch (e) {
  //     throw new Exception(
  //       500,
  //       `Failed to parse response from ${path}: ${e.message}`,
  //     );
  //   }
  // } else {
  //   throw new Exception(
  //     res.status,
  //     `Failed to query tokenlist: ${res.statusText}`,
  //   );
  // }
}
