import "NFTList"
import "NFTCatalog"

transaction() {

    prepare(acct: &Account) {
        NFTCatalog.forEachCatalogKey(fun (key: String): Bool {
            if let metadata = NFTCatalog.getCatalogEntry(collectionIdentifier: key) {
                if !metadata.nftType.isRecovered {
                    NFTList.ensureNFTCollectionRegistered(metadata.contractAddress, metadata.contractName)
                }
            }
            return true
        })
    }
}

