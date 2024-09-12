/**
 * @file This file contains all enum types that are used in the application.
 */

export enum EvaluationType {
  UNVERIFIED,
  PENDING,
  VERIFIED,
  FEATURED,
  BLOCKED,
}

///   0 - All
///   1 - Reviewed by Reviewer
///   2 - Managed by Reviewer
///   3 - Verified by Reviewer
///   4 - Featured by Reviewer
///   5 - Blocked by Reviewer
export enum FilterType {
  ALL,
  REVIEWED,
  MANAGED,
  VERIFIED,
  FEATURED,
  BLOCKED,
}
