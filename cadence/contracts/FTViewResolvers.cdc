/**
> Author: FIXeS World <https://fixes.world/>

# Token List - A on-chain list of Flow Standard Fungible Tokens (FTs).

This is the view resolver utilties contract of the Token List.

*/
import "MetadataViews"
import "ViewResolver"

access(all) contract FTViewResolvers {
    /* --- Events --- */

    /// Event emitted when the contract is initialized
    access(all) event ContractInitialized()

    /* --- Interfaces & Resources --- */

    /// The contract view resolver
    ///
    access(all) resource ContractViewResolver: MetadataViews.Resolver {
        /// The address of the contract
        access(all) let address: Address
        /// The name of the contract
        access(all) let contractName: String

        init(
            address: Address,
            contractName: String
        ) {
            self.address = address
            self.contractName = contractName

            // Ensure the contract view resolver is valid
            self.borrowContractViewResolver()
        }

        // ---- Implementing the Resolver ----

        access(all)
        fun getViews(): [Type] {
            let viewResolver = self.borrowContractViewResolver()
            return viewResolver.getViews()
        }

        access(all)
        fun resolveView(_ view: Type): AnyStruct? {
            let viewResolver = self.borrowContractViewResolver()
            return viewResolver.resolveView(view)
        }

        // ---- Local Methods ----

        access(self)
        fun borrowContractViewResolver(): &ViewResolver {
            return getAccount(self.address).contracts
                .borrow<&ViewResolver>(name: self.contractName)
                ?? panic("ContractViewResolver not found")
        }
    }

    /// Create a contract view resolver
    ///
    access(all)
    fun createContractViewResolver(
        address: Address,
        contractName: String
    ): @ContractViewResolver {
        return <- create ContractViewResolver(address: address, contractName: contractName)
    }

    init() {
        emit ContractInitialized()
    }
}
