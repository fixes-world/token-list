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
