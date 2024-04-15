import "TokenList"
import "FTViewUtils"

access(all)
fun main(
    ftAddress: Address,
    reviewer: Address?,
): QueryResult {
    var totalAmt: Int = 0
    var list: [FTViewUtils.StandardTokenView] = []

    let registry = TokenList.borrowRegistry()

    var ftTypes: [Type] = registry.getFTEntriesByAddress(ftAddress)
    totalAmt = ftTypes.length

    // load token view
    for ftType in ftTypes {
        if let ftEntry = registry.borrowFungibleTokenEntry(ftType) {
            let identity = ftEntry.getIdentity()
            var paths: FTViewUtils.StandardTokenPaths? = nil
            var source: Address? = nil
            if let data = ftEntry.getVaultData(reviewer) {
                source = data.source
                paths = FTViewUtils.StandardTokenPaths(
                    vaultPath: data.vaultData.storagePath,
                    balancePath: data.vaultData.metadataPath,
                    receiverPath: data.vaultData.receiverPath,
                )
            }
            list.append(FTViewUtils.StandardTokenView(
                identity: identity,
                decimals: 8,
                tags: [],
                dataSource: source,
                paths: paths,
                display: ftEntry.getDisplay(reviewer),
            ))
        }
    }
    return QueryResult(total: totalAmt, list: list)
}

access(all) struct QueryResult {
    access(all)
    let total: Int
    access(all)
    let list: [FTViewUtils.StandardTokenView]

    init(total: Int, list: [FTViewUtils.StandardTokenView]) {
        self.total = total
        self.list = list
    }
}
