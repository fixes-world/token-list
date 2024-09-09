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
}

export interface TokenStatusBasic extends TokenIdentity {
  isNFT: boolean;
  isRegistered?: boolean;
  isRegisteredWithNativeViewResolver?: boolean;
  isWithDisplay: boolean;
  isWithVaultData: boolean;
}

export interface AssetPaths {
  storage: string;
  public?: string;
}

export interface TokenAssetStatus extends TokenStatusBasic, AssetPaths {
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

export interface TagableItem {
  identity: TokenStatusBasic;
  tags: string[];
}

export interface StandardTokenView extends TagableItem {
  decimals: number;
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
  chainId: number;
  path: TokenPaths;
  evmAddress?: string;
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
  network: string;
  chainId?: number;
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

export interface NFTCollectionDisplayBasic {
  name: string;
  description?: string;
  externalURL?: string;
}

export interface NFTCollectionDisplay extends NFTCollectionDisplayBasic {
  squareImage: Media;
  bannerImage: Media;
  social: Record<string, string>;
}

export interface NFTCollectionDisplayDto extends NFTCollectionDisplayBasic {
  squareImage: string;
  bannerImage: string;
  social: SocialKeyPair[];
}

export interface NFTCollectionDisplayWithSource {
  source: string;
  display: NFTCollectionDisplay;
}

export interface StandardNFTCollectionView extends TagableItem {
  paths: AssetPaths;
  display?: NFTCollectionDisplayWithSource;
}

export type NFTListQueryResult = QueryResult<StandardNFTCollectionView>;

export interface ExportedNFTCollectionInfo extends TokenIdentity {
  chainId: number;
  path: AssetPaths;
  evmAddress?: string;
  name: string;
  description: string;
  logoURI: string;
  bannerURI: string;
  tags: string[];
  extensions: Record<string, string>;
}

export interface NFTList {
  name: string;
  network: string;
  chainId?: number;
  tags: Record<string, TokenTag>;
  timestamp: Date;
  tokens: ExportedNFTCollectionInfo[];
  totalAmount: number;
  filterType: string;
  version: {
    major: number;
    minor: number;
    patch: number;
  };
}
