/**
 * @file This file contains all the entity types that are used in the application.
 */

export interface TokenIdentity {
  address: string;
  contractName: string;
}

export interface Media {
  uri: string;
  type: string;
}

export interface TokenPaths {
  vault: string;
  balance: string;
  receiver: string;
  provider?: string;
}

export interface TokenStatusBasic extends TokenIdentity {
  isRegistered?: boolean;
  isWithDisplay: boolean;
  isWithVaultData: boolean;
}

export interface TokenStatus extends TokenStatusBasic {
  vaultPath: string;
  publicPaths: Record<string, string>;
}

export interface TokenDisplayBasic {
  symbol: string;
  name: string;
  description?: string;
  externalURL?: string;
}

export interface TokenDisplay extends TokenDisplayBasic {
  logos: Media[];
  social: Record<string, string>;
}

export interface StandardTokenView {
  identity: TokenStatusBasic;
  decimals: number;
  tags: string[];
  dataSource?: string;
  path?: TokenPaths;
  display?: TokenDisplay;
}

export interface CustomizedTokenDto extends TokenDisplayBasic {
  logo: String;
  social: Record<string, string>;
}

export interface TokenQueryResult {
  total: number;
  list: StandardTokenView[];
}

export interface ReviewerInfo {
  address: string;
  verified: boolean;
  name?: string;
  url?: string;
  managedTokenAmt: number;
  reviewedTokenAmt: number;
  customziedTokenAmt: number;
}

export interface AddressStatus {
  isReviewer: boolean;
  isReviewMaintainer: boolean;
  isPendingToClaimReviewMaintainer: boolean;
  reviewerAddr?: string;
}
