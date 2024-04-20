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
  isRegisteredWithNativeViewResolver?: boolean;
  isWithDisplay: boolean;
  isWithVaultData: boolean;
}

export interface TokenStatus extends TokenStatusBasic {
  vaultPath?: string;
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

export interface TokenDisplayWithSource {
  source: string;
  display: TokenDisplay;
}

export interface StandardTokenView {
  identity: TokenStatusBasic;
  decimals: number;
  tags: string[];
  dataSource?: string;
  path?: TokenPaths;
  display?: TokenDisplayWithSource;
}

export interface SocialKeyPair {
  key: string;
  value: string;
}

export interface CustomizedTokenDto extends TokenDisplayBasic {
  logo: string;
  social: SocialKeyPair[];
}

export interface QueryResult<T> {
  total: number;
  list: T[];
}

export type TokenQueryResult = QueryResult<StandardTokenView>;

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

export interface ExportedTokenInfo extends TokenIdentity {
  path: TokenPaths;
  symbol: string;
  name: string;
  decimals: number;
  description: string;
  logoURI: string;
  tags: string[];
  extensions: Record<string, string>;
}

export interface TokenTag {
  name: string;
  description: string;
}

export interface TokenList {
  name: string;
  logoURI: string;
  keywords: string[];
  tags: Record<string, TokenTag>;
  timestamp: Date;
  tokens: ExportedTokenInfo[];
  totalAmount: number;
  filterType: string;
  version: {
    major: number;
    minor: number;
    patch: number;
  };
}
