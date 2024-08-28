import "NonFungibleToken"
import "ViewResolver"
import "MetadataViews"
import "NFTViewUtils"
import "NFTList"
import "ViewResolvers"

access(all)
fun main(
    addr: Address
): [NFTStatus] {
    let acct = getAuthAccount<auth(Storage, Capabilities) &Account>(addr)
    let contractNames = acct.contracts.names
    if contractNames.length == 0 {
        return []
    }

    let addrNo0x = addr.toString().slice(from: 2, upTo: addr.toString().length)

    let typeDic: {Type: String} = {}
    let viewResolverDic: {Type: &{ViewResolver}} = {}
    for contractName in contractNames {
        log("Loading Contract: ".concat(contractName))
        if let ref = acct.contracts.borrow<&{NonFungibleToken}>(name: contractName) {
            if let collectionType = CompositeType("A.".concat(addrNo0x)
                .concat(".").concat(contractName)
                .concat(".Collection")) {
                typeDic[collectionType] = contractName
                // Borrow the view resolver for the contract
                if let viewResolver = ViewResolvers.borrowContractViewResolver(addr, contractName) {
                    log("ViewResolver for ".concat(contractName).concat("is borrowed"))
                    viewResolverDic[collectionType] = viewResolver
                }
            }
        }
    }
    let pathsDic: {Type: String} = {}
    let storagePathToType: {String: Type} = {}
    acct.storage.forEachStored(fun (path: StoragePath, type: Type): Bool {
        if type.isSubtype(of: Type<@{NonFungibleToken.Collection}>()) {
            pathsDic[type] = path.toString()
            storagePathToType[path.toString()] = type
        }
        return true
    })
    let publicPathsDic: {Type: String} = {}
    acct.storage.forEachPublic(fun (path: PublicPath, type: Type): Bool {
        let capExists = acct.capabilities.exists(path)
        if capExists {
            let cap = acct.capabilities.get<&AnyResource>(path)
            if let controler = acct.capabilities.storage.getController(byCapabilityID: cap.id) {
                let storagePath = controler.target()

                if let colType = storagePathToType[storagePath.toString()] {
                    publicPathsDic[colType] = path.toString()
                }
            }
        }
        return true
    })

    let ret: [NFTStatus] = []
    for ftType in typeDic.keys {
        let contractName = typeDic[ftType]!
        let supportedViews = viewResolverDic[ftType]?.getContractViews(resourceType: nil) ?? []
        let status = NFTStatus(
            address: addr,
            contractName: contractName,
            isRegistered: NFTList.isNFTCollectionRegistered(addr, contractName),
            isWithDisplay: supportedViews.contains(Type<MetadataViews.NFTCollectionDisplay>()),
            storagePath: pathsDic[ftType],
            publicPath: publicPathsDic[ftType],
        )
        ret.append(status)
    }
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
