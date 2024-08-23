import "NFTViewUtils"
import "NFTList"

access(all)
fun main(
    address: Address,
    reviewer: Address?,
): QueryResult {
    var totalAmt: Int = 0
    var list: [NFTViewUtils.StandardTokenView] = []

    let registry = NFTList.borrowRegistry()

    var types: [Type] = registry.getNFTEntriesByAddress(address)
    totalAmt = types.length

    // load token view
    for nftType in types {
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
