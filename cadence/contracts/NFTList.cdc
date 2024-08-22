/**
> Author: Fixes World <https://fixes.world/>

# NFT List - An on-chain list of Flow Standard Non-Fungible Tokens (NFTs).

This is the basic contract of the NFT List.
It will be used to store the list of all the Flow Standard Non-Fungible Tokens (NFTs) that are available on the Flow blockchain.

*/
import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
// TokenList Imports
import "ViewResolvers"
import "FTViewUtils"

/// NFT List registry contract
///
access(all) contract NFTList {

    /* --- Entitlement --- */

    access(all) entitlement Maintainer
    access(all) entitlement SuperAdmin


}
