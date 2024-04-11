import "FungibleToken"
import "FTViewUtils"
import "TokenList"

access(all)
fun main(
    addr: Address
): [FTStatus] {
    let acct = getAuthAccount(addr)
    let contractNames = acct.contracts.names
    if contractNames.length == 0 {
        return []
    }

    let addrNo0x = addr.toString().slice(from: 2, upTo: addr.toString().length)

    let ftDic: {Type: String} = {}
    for contractName in contractNames {
        if let contract = acct.contracts.borrow<&FungibleToken>(name: contractName) {
            let ftType = CompositeType("A.".concat(addrNo0x)
                .concat(".").concat(contractName)
                .concat(".Vault"))!
            ftDic[ftType] = contractName
        }
    }
    let ftVaultPathsDic: {Type: String} = {}
    let ftVaultPathToType: {String: Type} = {}
    acct.forEachStored(fun (path: StoragePath, type: Type): Bool {
        if type.isSubtype(of: Type<@FungibleToken.Vault>()) {
            ftVaultPathsDic[type] = path.toString()
            ftVaultPathToType[path.toString()] = type
        }
        return true
    })
    let ftPublicPathsDic: {Type: {String: String}} = {}
    acct.forEachPublic(fun (path: PublicPath, type: Type): Bool {
        if let storagePath = acct.getLinkTarget(path) {
            if let tokenType = ftVaultPathToType[storagePath.toString()] {
                if ftPublicPathsDic[tokenType] == nil {
                    ftPublicPathsDic[tokenType] = {}
                }
                let ref = (&ftPublicPathsDic[tokenType] as &{String: String}?)!
                ref[type.identifier] = path.toString()
            }
        }
        return true
    })

    let ret: [FTStatus] = []
    for ftType in ftDic.keys {
        let contractName = ftDic[ftType]!
        if ftVaultPathsDic[ftType] == nil || ftPublicPathsDic[ftType] == nil {
            continue
        }
        let status = FTStatus(
            address: addr,
            contractName: contractName,
            isRegistered: TokenList.isFungibleTokenRegistered(addr, contractName),
            vaultPath: ftVaultPathsDic[ftType]!,
            publicPaths: ftPublicPathsDic[ftType]!
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
    let vaultPath: String
    // TypeIdentifier => Path
    access(all)
    let publicPaths: {String: String}

    init(
        address: Address,
        contractName: String,
        isRegistered: Bool,
        vaultPath: String,
        publicPaths: {String: String}
    ) {
        self.address = address
        self.contractName = contractName
        self.isRegistered = isRegistered
        self.vaultPath = vaultPath
        self.publicPaths = publicPaths
    }
}
