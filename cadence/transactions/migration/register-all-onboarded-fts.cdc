import "TokenList"
import "FlowEVMBridgeConfig"
import "EVMTokenList"

transaction {
    prepare(signer: &Account) {
        let registry = TokenList.borrowRegistry()
        let entries = registry.getAllFTEntries()
        for tokenType in entries {
            if let evmAddr = FlowEVMBridgeConfig.getEVMAddressAssociated(with: tokenType) {
                EVMTokenList.ensureEVMAssetRegistered(evmAddr.toString(), feeProvider: nil)
            }
        }
    }
}
