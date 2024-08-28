import "NFTViewUtils"
import "NFTList"

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
    var list: [NFTViewUtils.StandardTokenView] = []
    // If filterType is not in the range of 0-4, return empty list
    if filterType != nil && filterType! > 4 {
        return QueryResult(total: totalAmt, list: list)
    }

    let registry = NFTList.borrowRegistry()

    var nftTypes: [Type] = []
    if reviewer != nil && filterType != 0 {
        if let reviewerRef = NFTList.borrowReviewerPublic(reviewer!) {
            var all: [Type] = []
            let start = page * size
            var end = start + size
            if filterType == 1 {
                // Reviewed by Reviewer
                all = reviewerRef.getReviewedNFTTypes()
            } else if filterType == 2 {
                // Managed by Reviewer
                all = []
            } else if filterType == 3 {
                // Verified by Reviewer
                all = reviewerRef.getVerifiedNFTTypes()
            } else if filterType == 4 {
                // Featured by Reviewer
                all = reviewerRef.getFeaturedNFTTypes()
            }
            totalAmt = all.length
            if totalAmt == 0 || start >= totalAmt {
                return QueryResult(total: totalAmt, list: [])
            }
            if end > totalAmt {
                end = totalAmt
            }
            nftTypes = all.slice(from: start, upTo: end)
        }
    } else {
        totalAmt = registry.getNFTEntriesAmount()
        nftTypes = registry.getNFTEntries(page, size)
    }
    log("Page:".concat(page.toString()).concat(" Size:").concat(size.toString()).concat(" Reviewer:").concat(reviewer?.toString() ?? "").concat(" Total:").concat(totalAmt.toString()))

    // load token view
    for nftType in nftTypes {
        if let entry = registry.borrowNFTEntry(nftType) {
            let identity = entry.getIdentity()
            let data = entry.getCollectionData()
            list.append(NFTViewUtils.StandardTokenView(
                identity: identity,
                tags: entry.getTags(reviewer),
                dataSource: nil,
                paths: NFTViewUtils.StandardNFTPaths(
                    data.storagePath,
                    data.publicPath,
                ),
                display: entry.getDisplay(reviewer),
            ))
        }
    }
    return QueryResult(total: totalAmt, list: list)
}

access(all) struct QueryResult {
    access(all)
    let total: Int
    access(all)
    let list: [NFTViewUtils.StandardTokenView]

    init(total: Int, list: [NFTViewUtils.StandardTokenView]) {
        self.total = total
        self.list = list
    }
}
