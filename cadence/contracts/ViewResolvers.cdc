/**
> Author: FIXeS World <https://fixes.world/>

# Token List - A on-chain list of Flow Standard Fungible Tokens (FTs).

This is the view resolver utilties contract of the Token List.

*/
import "MetadataViews"
import "ViewResolver"

access(all) contract ViewResolvers {

    /* --- Contract View Resolver --- */

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

        access(all) view
        fun getViews(): [Type] {
            let viewResolver = self.borrowContractViewResolver()
            return viewResolver.getViews()
        }

        access(all) view
        fun resolveView(_ view: Type): AnyStruct? {
            let viewResolver = self.borrowContractViewResolver()
            return viewResolver.resolveView(view)
        }

        // ---- Local Methods ----

        access(self)
        fun borrowContractViewResolver(): &ViewResolver {
            return ViewResolvers.borrowContractViewResolver(self.address, self.contractName)
                ?? panic("Contract view resolver not found")
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

    /// Borrow a contract view resolver
    ///
    access(all)
    fun borrowContractViewResolver(_ addr: Address, _ name: String): &ViewResolver? {
        let viewResolver: &ViewResolver? = getAccount(addr).contracts.borrow<&ViewResolver>(name: name)
        log("Borrowed contract view resolver: ".concat(addr.toString()).concat(" - ").concat(name))
        return viewResolver
    }

    /* --- Collection Resolver --- */

    /// The collection view resolver
    ///
    access(all) resource CollectionViewResolver: MetadataViews.Resolver {
        // FTView Resolver Collection Capability
        access(self)
        let cap: Capability<&{MetadataViews.ResolverCollection}>
        // FTView Id
        access(self)
        let id: UInt64

        init(
            _ cap: Capability<&{MetadataViews.ResolverCollection}>,
            id: UInt64
        ) {
            pre {
                cap.check(): "Collection view resolver capability is invalid"
            }
            post {
                self.borrowViewResolver() != nil: "Collection view resolver is invalid"
            }
            self.cap = cap
            self.id = id
            // Ensure the collection view resolver is valid
            self.borrowViewResolver()
        }

        // ---- Implementing the Resolver ----

        access(all) view
        fun getViews(): [Type] {
            let viewResolver = self.borrowViewResolver()
            return viewResolver?.getViews() ?? []
        }

        access(all) view
        fun resolveView(_ view: Type): AnyStruct? {
            let viewResolver = self.borrowViewResolver()
            return viewResolver?.resolveView(view)
        }

        // ---- Local Methods ----

        access(self) view
        fun borrowViewResolver(): &{MetadataViews.Resolver}? {
            let ref = self.cap.borrow()
                ?? panic("Collection view resolver not found")
            return ref.borrowViewResolver(id: self.id)
        }
    }

    /// Create a collection view resolver
    ///
    access(all)
    fun createCollectionViewResolver(
        _ cap: Capability<&{MetadataViews.ResolverCollection}>,
        id: UInt64
    ): @CollectionViewResolver {
        return <- create CollectionViewResolver(cap, id: id)
    }
}
