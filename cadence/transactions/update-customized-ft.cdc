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
        if acct.check<&{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.reviewerStoragePath) {
            maintainer = acct.borrow<&{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.reviewerStoragePath)
                ?? panic("Failed to load FungibleTokenReviewMaintainer from reviewer")
        }
        // Try borrow review
        if acct.check<&{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.maintainerStoragePath) {
            maintainer = acct.borrow<&{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.maintainerStoragePath)
                ?? panic("Failed to load FungibleTokenReviewMaintainer from review maintainer")
        }

        self.maintainer = maintainer ?? panic("Missing maintainer")
    }

    execute {
        let tokenType = FTViewUtils.buildFTVaultType(ftAddress, ftContractName)
            ?? panic("Failed to build ft type")
        let ftviewRef = self.maintainer.borrowFTViewEditor(tokenType)
            ?? panic("Failed to get the ft view")
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
