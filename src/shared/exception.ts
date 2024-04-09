export default class Exception extends Error {
  constructor(
    readonly status: number,
    message?: string,
    readonly code?: string,
    options?: ErrorOptions
  ) {
    super(message, options);
  }
}
