import { FilterType } from "@shared/flow/enums";
import {
  FailedToLoadTokenListJsonError,
  FailedToParseTokenListJsonError,
} from "@shared/exception.client";

/**
 * Send a request to the OpenAPI server
 * @param path
 * @param body
 */
export async function queryTokenListByAPI(
  reviewer?: string,
  filter: FilterType = FilterType.ALL,
  page?: number,
  limit?: number,
) {
  let url = "/api/token-list";
  if (reviewer) {
    url += `/${reviewer}`;
  }
  if (page && limit) {
    url += `?page=${page}&limit=${limit}&filter=${filter}`;
  } else {
    url += `?filter=${filter}`;
  }
  const res = await fetch(url, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
  });
  if (res.status >= 200 && res.status < 300) {
    try {
      return await res.json();
    } catch (e) {
      throw new FailedToParseTokenListJsonError();
    }
  } else {
    throw new FailedToLoadTokenListJsonError();
  }
}
