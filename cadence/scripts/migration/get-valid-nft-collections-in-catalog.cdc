import "NFTCatalog"

access(all)
fun main(): [String] {
    let ret: [String] = []

    NFTCatalog.forEachCatalogKey(fun (key: String): Bool {
        if let metadata = NFTCatalog.getCatalogEntry(collectionIdentifier: key) {
            if !metadata.nftType.isRecovered {
                ret.append(metadata.nftType.identifier)
            }
        }
        return true
    })
    return ret
}
