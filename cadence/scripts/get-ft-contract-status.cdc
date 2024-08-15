import "FungibleToken"
import "ViewResolver"
import "FungibleTokenMetadataViews"
import "FTViewUtils"
import "TokenList"
import "ViewResolvers"

access(all)
fun main(
    addr: Address,
    contractName: String,
    vaultAddr: Address?
): FTStatus? {
    let acct = getAuthAccount<auth(Storage, Capabilities) &Account>(addr)
    let contractNames = acct.contracts.names
    if contractNames.length == 0 {
        return nil
    }

    let addrNo0x = addr.toString().slice(from: 2, upTo: addr.toString().length)
    log("Loading Contract: ".concat(contractName))

    let ftType = CompositeType("A.".concat(addrNo0x)
            .concat(".").concat(contractName)
            .concat(".Vault"))
    if ftType == nil {
        log("Failed to create CompositeType for ".concat(contractName))
        return nil
    }

    var ftViewResolver: &{ViewResolver}? = nil
    var isValid = false
    if let ref = acct.contracts.borrow<&{FungibleToken}>(name: contractName) {
        isValid = true
        // Borrow the view resolver for the contract
        if let viewResolver = ViewResolvers.borrowContractViewResolver(addr, contractName) {
            log("ViewResolver for ".concat(contractName).concat("is borrowed"))
            ftViewResolver = viewResolver
        }
    }
    if !isValid {
        log("Failed to create CompositeType for ".concat(contractName))
        return nil
    }

    let vaultAcct = vaultAddr != nil
        ? getAuthAccount<auth(Storage, Capabilities) &Account>(vaultAddr!)
        : acct

    var ftVaultPath: String? = nil
    vaultAcct.storage.forEachStored(fun (path: StoragePath, type: Type): Bool {
        if type.isSubtype(of: ftType!) {
            ftVaultPath = path.toString()
            return false
        }
        return true
    })

    let ftPublicPaths: {String: String} = {}
    vaultAcct.storage.forEachPublic(fun (path: PublicPath, type: Type): Bool {
        let capExists = vaultAcct.capabilities.exists(path)
        if capExists {
            let cap = vaultAcct.capabilities.get<&AnyResource>(path)
            if let controler = vaultAcct.capabilities.storage.getController(byCapabilityID: cap.id) {
                let storagePath = controler.target()
                if storagePath.toString() == ftVaultPath {
                    ftPublicPaths[type.identifier] = path.toString()
                }
            }
        }
        return true
    })

    let supportedViews = ftViewResolver?.getContractViews(resourceType: nil) ?? []
    var ret = FTStatus(
        address: addr,
        contractName: contractName,
        isRegistered: TokenList.isFungibleTokenRegistered(addr, contractName),
        isWithDisplay: supportedViews.contains(Type<FungibleTokenMetadataViews.FTDisplay>()),
        isWithVaultData: supportedViews.contains(Type<FungibleTokenMetadataViews.FTVaultData>()),
        vaultPath: ftVaultPath,
        publicPaths: ftPublicPaths
    )
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
        isWithDisplay: Bool,
        isWithVaultData: Bool,
        vaultPath: String?,
        publicPaths: {String: String}
    ) {
        self.address = address
        self.contractName = contractName
        self.isRegistered = isRegistered
        self.isWithDisplay = isWithDisplay
        self.isWithVaultData = isWithVaultData
        self.vaultPath = vaultPath
        self.publicPaths = publicPaths
    }
}
