export class ClientNotificationError extends Error {}

export class InvalidWalletUserTypeError extends ClientNotificationError {}

export class UnsupportedNetworkError extends ClientNotificationError {}

export class FailedToSignTransactionError extends ClientNotificationError {}

export class FailedToGetValidKeyIndexError extends ClientNotificationError {}
