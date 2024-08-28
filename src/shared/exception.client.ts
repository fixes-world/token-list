import Exception from "./exception";

export class ClientNotificationError extends Exception {}

export class UnsupportedNetworkError extends ClientNotificationError {}
export class FailedToParseJsonError extends ClientNotificationError {}
export class FailedToRequestError extends ClientNotificationError {}
