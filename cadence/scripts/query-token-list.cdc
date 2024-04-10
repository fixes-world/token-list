import "TokenList"
import "FTViewUtils"

/// Filter type:
///   0 - All
///   1 - Reviewed by Reviewer
///   2 - Managed by Reviewer
///   3 - Verified by Reviewer
///   4 - Featured by Reviewer
///
access(all)
fun main(
    page: Int,
    size: Int,
    reviewer: Address?,
    filterType: UInt8?,
): QueryResult {
    var totalAmt: Int = 0
    var list: [FTViewUtils.StandardTokenView] = []
    // If filterType is not in the range of 0-4, return empty list
    if filterType != nil && filterType! > 4 {
        return QueryResult(total: totalAmt, list: list)
    }

    let registry = TokenList.borrowRegistry()

    var ftTypes: [Type] = []
    if reviewer != nil && filterType != 0 {
        if let reviewerRef = TokenList.borrowReviewerPublic(reviewer!) {
            var all: [Type] = []
            let start = page * size
            var end = start + size
            if filterType == 1 {
                // Reviewed by Reviewer
                all = reviewerRef.getReviewedFTTypes()
            } else if filterType == 2 {
                // Managed by Reviewer
                all = reviewerRef.getManagedFTTypes()
            } else if filterType == 3 {
                // Verified by Reviewer
                all = reviewerRef.getVerifiedFTTypes()
            } else if filterType == 4 {
                // Featured by Reviewer
                all = reviewerRef.getFeaturedFTTypes()
            }
            totalAmt = all.length
            if totalAmt == 0 || start >= totalAmt {
                return QueryResult(total: totalAmt, list: [])
            }
            if end > totalAmt {
                end = totalAmt
            }
            ftTypes = all.slice(from: start, upTo: end)
        }
    } else {
        totalAmt = registry.getFTEntriesAmount()
        ftTypes = registry.getFTEntries(page, size)
    }

    // load token view
    for ftType in ftTypes {
        if let ftEntry = registry.borrowFungibleTokenEntry(ftType) {
            let identity = ftEntry.getIdentity()
            var paths: FTViewUtils.StandardTokenPaths? = nil
            if let vaultData = ftEntry.getVaultData(reviewer) {
                paths = FTViewUtils.StandardTokenPaths(
                    vaultPath: vaultData.storagePath,
                    balancePath: vaultData.metadataPath,
                    receiverPath: vaultData.receiverPath,
                )
            }
            list.append(FTViewUtils.StandardTokenView(
                identity: identity,
                decimals: 8,
                tags: [],
                paths: paths,
                display: ftEntry.getDisplay(reviewer),
            ))
        }
    }
    return QueryResult(total: totalAmt, list: list)
}

access(all) struct QueryResult {
    let total: Int
    let list: [FTViewUtils.StandardTokenView]

    init(total: Int, list: [FTViewUtils.StandardTokenView]) {
        self.total = total
        self.list = list
    }
}
