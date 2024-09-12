import { FilterType } from "@shared/flow/enums";
import { sendGetRequest } from "./utilities.shared";
import Exception from "@shared/exception";

/**
 * Send a request to the OpenAPI server
 * @param path
 * @param body
 */
export async function queryTokenListByAPI(
  reviewer?: string,
  filter: FilterType = FilterType.ALL,
  isEVMOnly: boolean = false,
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
  if (isEVMOnly) {
    url += "&evm=true";
  }
  return await sendGetRequest(undefined, url);
}

/**
 * Send a request to the OpenAPI server
 * @param path
 * @param body
 */
export async function queryNFTListByAPI(
  reviewer?: string,
  filter: FilterType = FilterType.ALL,
  isEVMOnly: boolean = false,
  page?: number,
  limit?: number,
) {
  let url = "/api/nft-list";
  if (reviewer) {
    url += `/${reviewer}`;
  }
  if (page && limit) {
    url += `?page=${page}&limit=${limit}&filter=${filter}`;
  } else {
    url += `?filter=${filter}`;
  }
  if (isEVMOnly) {
    url += "&evm=true";
  }
  return await sendGetRequest(undefined, url);
}

/**
 * Load or generate an upload token for Qiniu
 */
export async function loadOrGenerateUploadToken(): Promise<string> {
  let localToken = localStorage.getItem("qiniu-upload-token");
  let localExpireAt = parseInt(
    localStorage.getItem("qiniu-upload-token-expire-at") ?? "0",
  );
  if (localExpireAt > Date.now() && !!localToken) {
    return localToken;
  }
  const data = await sendGetRequest(undefined, "/api/get-upload-token");
  if (typeof data.token !== "string") {
    throw new Exception(500, `Invalid response from get-upload-token`);
  }
  if (typeof data.expireAt !== "number") {
    throw new Exception(500, `Invalid response from get-upload-token`);
  }
  localStorage.setItem("qiniu-upload-token", data.token);
  localStorage.setItem(
    "qiniu-upload-token-expire-at",
    data.expireAt.toString(),
  );
  return data.token;
}
