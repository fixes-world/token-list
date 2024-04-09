import "TokenList"
import "FTViewUtils"

access(all)
fun main(
    symbol: String,
    reviewer: Address?,
): QueryResult {
    var totalAmt: Int = 0
    var list: [FTViewUtils.StandardTokenView] = []

    let registry = TokenList.borrowRegistry()

    var ftTypes: [Type] = registry.getFTEntriesBySymbol(symbol)
    totalAmt = ftTypes.length

    // load token view
    for ftType in ftTypes {
        if let ftEntry = registry.borrowFungibleTokenEntry(ftType) {
            let identity = ftEntry.getIdentity()
            let vaultData = ftEntry.getVaultData()
            list.append(FTViewUtils.StandardTokenView(
                identity: identity,
                vaultPath: vaultData.storagePath,
                balancePath: vaultData.metadataPath,
                receiverPath: vaultData.receiverPath,
                decimals: 8,
                display: ftEntry.getDisplay(reviewer),
                tags: []
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
