import "MetadataViews"
import "FungibleToken"
import "FTViewUtils"
import "TokenList"

transaction(
    ftAddress: Address,
    ftContractName: String,
    storageIdentifier: String,
    receiverIdentifier: String,
    metadataIdentifier: String,
    providerIdentifier: String,
    name: String,
    symbol: String,
    description: String?,
    externalURL: String?,
    logo: String?,
    socials: {String: String},
) {
    let maintainer: &{TokenList.FungibleTokenReviewMaintainer}

    prepare(acct: AuthAccount) {
        var maintainer: &{TokenList.FungibleTokenReviewMaintainer}? = nil
        // Try borrow maintainer
        if acct.check<@{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.maintainerStoragePath) {
            maintainer = acct.borrow<&{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.maintainerStoragePath)
                ?? panic("Failed to load FungibleTokenReviewMaintainer from review maintainer")
        }
        // Try borrow review
        if acct.check<@TokenList.FungibleTokenReviewer>(from: TokenList.reviewerStoragePath) {
            maintainer = acct.borrow<&{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.reviewerStoragePath)
                    ?? panic("Failed to load FungibleTokenReviewMaintainer from reviewer")
        }
        self.maintainer = maintainer ?? panic("Missing maintainer")
    }

    execute {
        let tokenType = FTViewUtils.buildFTVaultType(ftAddress, ftContractName)
            ?? panic("Failed to build ft type")
        self.maintainer.registerFungibleTokenWithEditableFTView(
            ftAddress,
            ftContractName,
            at: StoragePath(identifier: storageIdentifier) ?? panic("Invalid Identifier.")
        )
        let ftviewRef = self.maintainer.borrowFTViewEditor(tokenType)
            ?? panic("Failed to get the ft view")
        // initialize vault data
        ftviewRef.initializeVaultData(
            receiverPath: PublicPath(identifier: receiverIdentifier) ?? panic("Invalid receiver path"),
            metadataPath: PublicPath(identifier: metadataIdentifier) ?? panic("Invalid metadata path"),
            // @deprecated in Cadence 1.0
            providerPath: PrivatePath(identifier: providerIdentifier) ?? panic("Invalid provider path"),
            receiverType: Type<&AnyResource{FungibleToken.Receiver}>(),
            metadataType: Type<&AnyResource{FungibleToken.Balance, MetadataViews.Resolver}>(),
            // @deprecated in Cadence 1.0
            providerType: Type<&AnyResource{FungibleToken.Provider}>()
        )
        // init FT Display
        ftviewRef.setFTDisplay(
            name: name,
            symbol: symbol,
            description: description,
            externalURL: externalURL,
            logo: logo,
            socials: socials
        )
    }
}
