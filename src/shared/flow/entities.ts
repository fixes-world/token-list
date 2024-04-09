/**
 * @file This file contains all the entity types that are used in the application.
 */

export interface TokenIdentity {
  address: string;
  contractName: string;
}

export interface TokenDisplay {}

export interface StandardTokenView {
  display: TokenDisplay;
}
