import "NonFungibleToken"
import "ViewResolver"
import "MetadataViews"
import "NFTViewUtils"
import "NFTList"
import "ViewResolvers"

access(all)
fun main(
    addr: Address,
    contractName: String,
    collectionAddr: Address?
): NFTStatus? {
    let acct = getAuthAccount<auth(Storage, Capabilities) &Account>(addr)
    let contractNames = acct.contracts.names
    if contractNames.length == 0 {
        return nil
    }

    let addrNo0x = addr.toString().slice(from: 2, upTo: addr.toString().length)
    log("Loading Contract: ".concat(contractName))

    let collectionType = CompositeType("A.".concat(addrNo0x)
            .concat(".").concat(contractName)
            .concat(".Collection"))
    if collectionType == nil {
        log("Failed to create CompositeType for ".concat(contractName))
        return nil
    }

    var nftViewResolver: &{ViewResolver}? = nil
    var isValid = false
    if let ref = acct.contracts.borrow<&{NonFungibleToken}>(name: contractName) {
        isValid = true
        // Borrow the view resolver for the contract
        if let viewResolver = ViewResolvers.borrowContractViewResolver(addr, contractName) {
            log("ViewResolver for ".concat(contractName).concat("is borrowed"))
            nftViewResolver = viewResolver
        }
    }
    if !isValid {
        log("Failed to create CompositeType for ".concat(contractName))
        return nil
    }

    let collectionAcct = collectionAddr != nil
        ? getAuthAccount<auth(Storage, Capabilities) &Account>(collectionAddr!)
        : acct

    var nftCollectionPath: String? = nil
    collectionAcct.storage.forEachStored(fun (path: StoragePath, type: Type): Bool {
        if type.isSubtype(of: collectionType!) {
            nftCollectionPath = path.toString()
            return false
        }
        return true
    })

    var nftPublicPath: String? = nil
    collectionAcct.storage.forEachPublic(fun (path: PublicPath, type: Type): Bool {
        let capExists = collectionAcct.capabilities.exists(path)
        if capExists {
            let cap = collectionAcct.capabilities.get<&AnyResource>(path)
            if let controler = collectionAcct.capabilities.storage.getController(byCapabilityID: cap.id) {
                let storagePath = controler.target()
                if storagePath.toString() == nftCollectionPath {
                    nftPublicPath = path.toString()
                    return false
                }
            }
        }
        return true
    })

    let supportedViews = nftViewResolver?.getContractViews(resourceType: nil) ?? []
    var ret = NFTStatus(
        address: addr,
        contractName: contractName,
        isRegistered: NFTList.isNFTCollectionRegistered(addr, contractName),
        isWithDisplay: supportedViews.contains(Type<MetadataViews.NFTCollectionDisplay>()),
        storagePath: nftCollectionPath,
        publicPath: nftPublicPath
    )
    return ret
}

access(all) struct NFTStatus {
    access(all)
    let address: Address
    access(all)
    let contractName: String
    access(all)
    let isRegistered: Bool
    access(all)
    let isWithDisplay: Bool
    access(all)
    let storagePath: String?
    access(all)
    let publicPath: String?

    init(
        address: Address,
        contractName: String,
        isRegistered: Bool,
        isWithDisplay: Bool,
        storagePath: String?,
        publicPath: String?,
    ) {
        self.address = address
        self.contractName = contractName
        self.isRegistered = isRegistered
        self.isWithDisplay = isWithDisplay
        self.storagePath = storagePath
        self.publicPath = publicPath
    }
}
