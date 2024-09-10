import "EVM"
import "FlowEVMBridge"
import "FlowEVMBridgeConfig"
import "FlowEVMBridgeUtils"

import "EVMTokenList"

access(all)
fun main(
    evmContractAddress: String,
): EVMAssetStatus? {
    let addrNo0x = evmContractAddress.slice(from: 0, upTo: 2) == "0x"
            ? evmContractAddress.slice(from: 2, upTo: evmContractAddress.length)
            : evmContractAddress
    let acct = EVM.addressFromString(addrNo0x)

    let isRequires = FlowEVMBridge.evmAddressRequiresOnboarding(acct)
    if isRequires == nil {
        return nil
    }

    let isRegistered = EVMTokenList.isEVMAddressRegistered(addrNo0x)

    let isNFT = FlowEVMBridgeUtils.isERC721(evmContractAddress: acct)

    return EVMAssetStatus(
        address: acct,
        isNFT: isNFT,
        isRegistered: isRegistered,
        isBridged: isRequires!,
        bridgedType: FlowEVMBridgeConfig.getTypeAssociated(with: acct)
    )
}

access(all) struct EVMAssetStatus {
    access(all)
    let evmAddress: String
    access(all)
    let isNFT: Bool
    access(all)
    let isRegistered: Bool
    access(all)
    let isBridged: Bool
    access(all)
    let bridgedType: Type?

    init(
        address: EVM.EVMAddress,
        isNFT: Bool,
        isRegistered: Bool,
        isBridged: Bool,
        bridgedType: Type?
    ) {
        self.evmAddress = address.toString()
        self.isNFT = isNFT
        self.isRegistered = isRegistered
        self.isBridged = isBridged
        self.bridgedType = bridgedType
    }
}
