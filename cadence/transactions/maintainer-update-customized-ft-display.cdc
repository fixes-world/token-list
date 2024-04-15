import "MetadataViews"
import "FungibleToken"
import "FTViewUtils"
import "TokenList"

transaction(
    ftAddress: Address,
    ftContractName: String,
    name: String?,
    symbol: String?,
    description: String?,
    externalURL: String?,
    logo: String?,
    socials: {String: String},
) {
    let maintainer: &{TokenList.FungibleTokenReviewMaintainer}

    prepare(acct: AuthAccount) {
        var maintainer: &{TokenList.FungibleTokenReviewMaintainer}? = nil
        // Try borrow maintainer
        if acct.check<@{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.reviewerStoragePath) {
            maintainer = acct.borrow<&{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.reviewerStoragePath)
                ?? panic("Failed to load FungibleTokenReviewMaintainer from reviewer")
        }
        // Try borrow review
        if !acct.check<@{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.maintainerStoragePath) {
            log("Creating a new reviewer")
            let reviewer <- TokenList.createFungibleTokenReviewer()
            acct.save(<- reviewer, to: TokenList.reviewerStoragePath)

            // public the public capability
            acct.link<&TokenList.FungibleTokenReviewer{TokenList.FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>(
                TokenList.reviewerPublicPath,
                target: TokenList.reviewerStoragePath
            )
        }
        maintainer = acct.borrow<&{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.maintainerStoragePath)
                ?? panic("Failed to load FungibleTokenReviewMaintainer from review maintainer")

        self.maintainer = maintainer ?? panic("Missing maintainer")
    }

    execute {
        let tokenType = FTViewUtils.buildFTVaultType(ftAddress, ftContractName)
            ?? panic("Failed to build ft type")
        var ftDisplayRef = self.maintainer.borrowFTDisplayEditor(tokenType)
        if ftDisplayRef == nil {
            self.maintainer.registerFungibleTokenDisplayPatch(ftAddress, ftContractName)
            ftDisplayRef = self.maintainer.borrowFTDisplayEditor(tokenType)
        }
        assert(
            ftDisplayRef != nil,
            message: "Failed to borrow FT Display Editor"
        )
        // update FT Display
        ftDisplayRef!.setFTDisplay(
            name: name,
            symbol: symbol,
            description: description,
            externalURL: externalURL,
            logo: logo,
            socials: socials
        )
    }
}
