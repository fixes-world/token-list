import "FungibleToken"
import "ViewResolver"
import "FungibleTokenMetadataViews"
import "FTViewUtils"
import "TokenList"
import "ViewResolvers"

access(all)
fun main(
    addr: Address
): [FTStatus] {
    let acct = getAuthAccount<auth(Storage, Capabilities) &Account>(addr)
    let contractNames = acct.contracts.names
    if contractNames.length == 0 {
        return []
    }

    let addrNo0x = addr.toString().slice(from: 2, upTo: addr.toString().length)

    let ftDic: {Type: String} = {}
    let ftViewResolverDic: {Type: &{ViewResolver}} = {}
    for contractName in contractNames {
        log("Loading Contract: ".concat(contractName))
        if let ref = acct.contracts.borrow<&{FungibleToken}>(name: contractName) {
            if let ftType = CompositeType("A.".concat(addrNo0x)
                .concat(".").concat(contractName)
                .concat(".Vault")) {
                ftDic[ftType] = contractName
                // Borrow the view resolver for the contract
                if let viewResolver = ViewResolvers.borrowContractViewResolver(addr, contractName) {
                    log("ViewResolver for ".concat(contractName).concat("is borrowed"))
                    ftViewResolverDic[ftType] = viewResolver
                }
            }
        }
    }
    let ftVaultPathsDic: {Type: String} = {}
    let ftVaultPathToType: {String: Type} = {}
    acct.storage.forEachStored(fun (path: StoragePath, type: Type): Bool {
        if type.isSubtype(of: Type<@{FungibleToken.Vault}>()) {
            ftVaultPathsDic[type] = path.toString()
            ftVaultPathToType[path.toString()] = type
        }
        return true
    })
    let ftPublicPathsDic: {Type: {String: String}} = {}
    acct.storage.forEachPublic(fun (path: PublicPath, type: Type): Bool {
        let capExists = acct.capabilities.exists(path)
        if capExists {
            let cap = acct.capabilities.get<&AnyResource>(path)
            if let controler = acct.capabilities.storage.getController(byCapabilityID: cap.id) {
                let storagePath = controler.target()

                if let tokenType = ftVaultPathToType[storagePath.toString()] {
                    if ftPublicPathsDic[tokenType] == nil {
                        ftPublicPathsDic[tokenType] = {}
                    }
                    let ref = (&ftPublicPathsDic[tokenType] as auth(Mutate) &{String: String}?)!
                    ref[type.identifier] = path.toString()
                }
            }
        }
        return true
    })

    let ret: [FTStatus] = []
    for ftType in ftDic.keys {
        let contractName = ftDic[ftType]!
        let supportedViews = ftViewResolverDic[ftType]?.getContractViews(resourceType: nil) ?? []
        let status = FTStatus(
            address: addr,
            contractName: contractName,
            isRegistered: TokenList.isFungibleTokenRegistered(addr, contractName),
            isRegisteredWithNativeViewResolver: TokenList.isFungibleTokenRegisteredWithNativeViewResolver(addr, contractName),
            isWithDisplay: supportedViews.contains(Type<FungibleTokenMetadataViews.FTDisplay>()),
            isWithVaultData: supportedViews.contains(Type<FungibleTokenMetadataViews.FTVaultData>()),
            vaultPath: ftVaultPathsDic[ftType],
            publicPaths: ftPublicPathsDic[ftType] ?? {}
        )
        ret.append(status)
    }
    return ret
}

access(all) struct FTStatus {
    access(all)
    let address: Address
    access(all)
    let contractName: String
    access(all)
    let isRegistered: Bool
    access(all)
    let isRegisteredWithNativeViewResolver: Bool
    access(all)
    let isWithDisplay: Bool
    access(all)
    let isWithVaultData: Bool
    access(all)
    let vaultPath: String?
    // TypeIdentifier => Path
    access(all)
    let publicPaths: {String: String}

    init(
        address: Address,
        contractName: String,
        isRegistered: Bool,
        isRegisteredWithNativeViewResolver: Bool,
        isWithDisplay: Bool,
        isWithVaultData: Bool,
        vaultPath: String?,
        publicPaths: {String: String}
    ) {
        self.address = address
        self.contractName = contractName
        self.isRegistered = isRegistered
        self.isRegisteredWithNativeViewResolver = isRegisteredWithNativeViewResolver
        self.isWithDisplay = isWithDisplay
        self.isWithVaultData = isWithVaultData
        self.vaultPath = vaultPath
        self.publicPaths = publicPaths
    }
}
