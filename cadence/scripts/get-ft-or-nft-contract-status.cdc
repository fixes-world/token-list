import "ViewResolver"
import "FungibleToken"
import "NonFungibleToken"
import "MetadataViews"
import "FungibleTokenMetadataViews"
import "ViewResolvers"
import "FTViewUtils"
import "TokenList"
import "NFTViewUtils"
import "NFTList"

access(all)
fun main(
    addr: Address,
    contractName: String,
    resourceAddr: Address?
): TokenAssetStatus? {
    let acct = getAuthAccount<auth(Storage, Capabilities) &Account>(addr)
    let contractNames = acct.contracts.names
    if contractNames.length == 0 {
        return nil
    }

    let addrNo0x = addr.toString().slice(from: 2, upTo: addr.toString().length)
    log("Loading Contract: ".concat(contractName))

    var tokenType = CompositeType("A.".concat(addrNo0x)
            .concat(".").concat(contractName)
            .concat(".Vault"))
    if tokenType?.isRecovered == true {
        log("Failed to create CompositeType for ".concat(contractName))
        return nil
    }
    if tokenType == nil {
        tokenType = CompositeType("A.".concat(addrNo0x)
            .concat(".").concat(contractName)
            .concat(".Collection"))
        if tokenType?.isRecovered == true {
            log("Failed to create CompositeType for ".concat(contractName))
            return nil
        }
    }
    if tokenType == nil {
        log("Failed to create CompositeType for ".concat(contractName))
        return nil
    }

    var contractViewResolver: &{ViewResolver}? = nil
    if let ref = acct.contracts.borrow<&{FungibleToken}>(name: contractName) {
        // Borrow the view resolver for the contract
        if let viewResolver = ViewResolvers.borrowContractViewResolver(addr, contractName) {
            log("ViewResolver for ".concat(contractName).concat("is borrowed"))
            contractViewResolver = viewResolver
        }
    }
    if contractViewResolver == nil {
        log("Failed to create CompositeType for ".concat(contractName))
        return nil
    }

    let resourceAcct = resourceAddr != nil
        ? getAuthAccount<auth(Storage, Capabilities) &Account>(resourceAddr!)
        : acct

    var storagePath: String? = nil
    resourceAcct.storage.forEachStored(fun (path: StoragePath, type: Type): Bool {
        if type.isRecovered {
            return true
        }
        if type.isSubtype(of: tokenType!) {
            storagePath = path.toString()
            return false
        }
        return true
    })

    let publicPathsDic: {String: String} = {}
    resourceAcct.storage.forEachPublic(fun (path: PublicPath, type: Type): Bool {
        let capExists = resourceAcct.capabilities.exists(path)
        if capExists {
            let cap = resourceAcct.capabilities.get<&AnyResource>(path)
            if let controler = resourceAcct.capabilities.storage.getController(byCapabilityID: cap.id) {
                if controler.target().toString() == storagePath {
                    publicPathsDic[type.identifier] = path.toString()
                }
            }
        }
        return true
    })

    let supportedViews = contractViewResolver!.getContractViews(resourceType: nil)
    let isNFT = tokenType!.isSubtype(of: Type<@{NonFungibleToken.Collection}>())
    let status = TokenAssetStatus(
        address: addr,
        contractName: contractName,
        isNFT: isNFT,
        isRegistered: isNFT
            ? NFTList.isNFTCollectionRegistered(addr, contractName)
            : TokenList.isFungibleTokenRegistered(addr, contractName),
        isRegisteredWithNativeViewResolver: contractViewResolver != nil,
        isWithDisplay: isNFT
            ? supportedViews.contains(Type<MetadataViews.NFTCollectionDisplay>())
            : supportedViews.contains(Type<FungibleTokenMetadataViews.FTDisplay>()),
        isWithVaultData: isNFT
            ? supportedViews.contains(Type<MetadataViews.NFTCollectionData>())
            : supportedViews.contains(Type<FungibleTokenMetadataViews.FTVaultData>()),
        storagePath: storagePath,
        publicPath: publicPathsDic[publicPathsDic.keys[0]],
        publicPaths: publicPathsDic
    )
    return status
}

access(all) struct TokenAssetStatus {
    access(all)
    let address: Address
    access(all)
    let contractName: String
    access(all)
    let isNFT: Bool
    access(all)
    let isRegistered: Bool
    access(all)
    let isRegisteredWithNativeViewResolver: Bool
    access(all)
    let isWithDisplay: Bool
    access(all)
    let isWithVaultData: Bool
    access(all)
    let storagePath: String?
    access(all)
    let publicPath: String?
    access(all)
    let publicPaths: {String: String}

    init(
        address: Address,
        contractName: String,
        isNFT: Bool,
        isRegistered: Bool,
        isRegisteredWithNativeViewResolver: Bool,
        isWithDisplay: Bool,
        isWithVaultData: Bool,
        storagePath: String?,
        publicPath: String?,
        publicPaths: {String: String}
    ) {
        self.address = address
        self.contractName = contractName
        self.isNFT = isNFT
        self.isRegistered = isRegistered
        self.isRegisteredWithNativeViewResolver = isRegisteredWithNativeViewResolver
        self.isWithDisplay = isWithDisplay
        self.isWithVaultData = isWithVaultData
        self.storagePath = storagePath
        self.publicPath = publicPath
        self.publicPaths = publicPaths
    }
}