export class ClientNotificationError extends Error {}

export class UnsupportedNetworkError extends ClientNotificationError {}
export class FailedToLoadTokenListJsonError extends ClientNotificationError {}
export class FailedToParseTokenListJsonError extends ClientNotificationError {}
