import "FungibleToken"
import "FlowToken"

import "ScopedFTProviders"
import "FlowEVMBridgeConfig"

import "TokenList"
import "NFTList"
import "EVMTokenList"

transaction(
    address: Address,
    contractName: String,
    isOnboardToBridge: Bool
) {
    prepare(signer: auth(CopyValue, BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue) &Account) {
        if isOnboardToBridge {
            if TokenList.isValidToRegister(address, contractName) {
                TokenList.ensureFungibleTokenRegistered(address, contractName)
            } else if NFTList.isValidToRegister(address, contractName) {
                NFTList.ensureNFTCollectionRegistered(address, contractName)
            }
        } else {
            /* --- Configure a ScopedFTProvider - Start -- */

            // Issue and store bridge-dedicated Provider Capability in storage if necessary
            if signer.storage.type(at: FlowEVMBridgeConfig.providerCapabilityStoragePath) == nil {
                let providerCap = signer.capabilities
                    .storage.issue<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>(/storage/flowTokenVault)
                signer.storage.save(providerCap, to: FlowEVMBridgeConfig.providerCapabilityStoragePath)
            }
            // Copy the stored Provider capability and create a ScopedFTProvider
            let providerCapCopy = signer.storage
                .copy<Capability<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>>(
                    from: FlowEVMBridgeConfig.providerCapabilityStoragePath
                ) ?? panic("Invalid Provider Capability found in storage.")
            let providerFilter = ScopedFTProviders.AllowanceFilter(FlowEVMBridgeConfig.onboardFee)
            let scopedProvider <- ScopedFTProviders.createScopedFTProvider(
                provider: providerCapCopy,
                filters: [ providerFilter ],
                expiration: getCurrentBlock().timestamp + 1.0
            )
            /* --- Configure a ScopedFTProvider - End -- */

            EVMTokenList.ensureCadenceAssetRegistered(
                address,
                contractName,
                feeProvider:  &scopedProvider as auth(FungibleToken.Withdraw) &{FungibleToken.Provider}
            )
            destroy scopedProvider
        }
    }
}