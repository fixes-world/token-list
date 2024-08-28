import "NonFungibleToken"
import "NFTViewUtils"
import "FTViewUtils"
import "NFTList"

transaction(
    address: Address,
    contractName: String,
    rank: UInt8?,
    tags: [String],
) {
    let maintainer: auth(NFTList.Maintainer) &{NFTList.NFTListReviewMaintainer}

    prepare(acct: auth(Storage) &Account) {
        var maintainer: auth(NFTList.Maintainer) &{NFTList.NFTListReviewMaintainer}? = nil
        // Try borrow maintainer
        if acct.storage.check<@{NFTList.NFTListReviewMaintainer}>(from: NFTList.maintainerStoragePath) {
            maintainer = acct.storage
                .borrow<auth(NFTList.Maintainer) &{NFTList.NFTListReviewMaintainer}>(from: NFTList.maintainerStoragePath)
                ?? panic("Failed to load NFTListReviewMaintainer from review maintainer")
        }
        // Try borrow review
        if acct.storage.check<@NFTList.NFTListReviewer>(from: NFTList.reviewerStoragePath) {
            maintainer = acct.storage.borrow<auth(NFTList.Maintainer) &{NFTList.NFTListReviewMaintainer}>(from: NFTList.reviewerStoragePath)
                    ?? panic("Failed to load NFTListReviewMaintainer from reviewer")
        }
        self.maintainer = maintainer ?? panic("Missing maintainer")
    }

    execute {
        let nftType = NFTViewUtils.buildNFTType(address, contractName)
            ?? panic("Failed to build ft type")

        // update rank
        if rank != nil {
            if let evalRank = FTViewUtils.Evaluation(rawValue: rank!) {
                self.maintainer.reviewNFTEvalute(nftType, rank: evalRank)
            }
        }
        // add tags
        if tags.length > 0 {
            self.maintainer.reviewNFTAddTags(nftType, tags: tags)
        }
    }
}
