/**
 * @file This file contains all the entity types that are used in the application.
 */

export interface TokenIdentity {
  address: string;
  contractName: string;
}

export interface TokenPaths {
  vault: string;
  balance: string;
  receiver: string;
  provider?: string;
}

export interface TokenMedia {
  uri: string;
  type: string;
}

export interface TokenDisplayBasic {
  symbol: string;
  name: string;
  description?: string;
  externalURL?: string;
}

export interface TokenDisplay extends TokenDisplayBasic {
  logos: TokenMedia[];
  social: Record<string, string>;
}

export interface StandardTokenView {
  identity: TokenIdentity;
  decimals: number;
  tags: string[];
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
