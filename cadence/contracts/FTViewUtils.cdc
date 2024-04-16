/**
> Author: FIXeS World <https://fixes.world/>

# Token List - A on-chain list of Flow Standard Fungible Tokens (FTs).

This is the Fungible Token view utilties contract of the Token List.

*/
import "MetadataViews"
import "FungibleToken"
import "FungibleTokenMetadataViews"

access(all) contract FTViewUtils {

    /*  ---- Events ---- */

    access(all) event FTViewStoragePathUpdated(
        address: Address,
        contractName: String,
        storagePath: StoragePath
    )

    access(all) event FTVaultDataUpdated(
        address: Address,
        contractName: String,
        storagePath: StoragePath,
        receiverPath: PublicPath,
        metadataPath: PublicPath,
        providerPath: PrivatePath,
        receiverType: Type,
        metadataType: Type,
        providerType: Type
    )

    access(all) event FTDisplayUpdated(
        address: Address,
        contractName: String,
        name: String?,
        symbol: String?,
        description: String?,
        externalURL: String?,
        logo: String?,
        socials: {String: String}
    )

    /// The struct interface for the Fungible Token Identity
    ///
    access(all) struct interface TokenIdentity {
        /// Build type
        access(all) view
        fun buildType(): Type
        /// Get Type identifier
        access(all) view
        fun toString(): String {
            return self.buildType().identifier
        }
    }

    /// The struct for the Fungible Token Identity
    ///
    access(all) struct FTIdentity: TokenIdentity {
        access(all)
        let address: Address
        access(all)
        let contractName: String

        init(
            _ address: Address,
            _ contractName: String
        ) {
            self.address = address
            self.contractName = contractName
        }

        access(all) view
        fun buildType(): Type {
            return FTViewUtils.buildFTVaultType(self.address, self.contractName)
                ?? panic("Could not build the FT Type")
        }

        /// Borrow the Fungible Token Contract
        ///
        access(all)
        fun borrowFungibleTokenContract(): &FungibleToken {
            return getAccount(self.address)
                .contracts.borrow<&FungibleToken>(name: self.contractName)
                ?? panic("Could not borrow the FungibleToken contract reference")
        }
    }

    /// The struct for the Fungible Token Vault Data with Source
    ///
    access(all) struct FTVaultDataWithSource {
        access(all)
        let source: Address?
        access(all)
        let vaultData: FungibleTokenMetadataViews.FTVaultData
        init(
            _ source: Address?,
            _ vaultData: FungibleTokenMetadataViews.FTVaultData
        ) {
            self.source = source
            self.vaultData = vaultData
        }
    }

    /// The struct for the Fungible Token Display with Source
    ///
    access(all) struct FTDisplayWithSource {
        access(all)
        let source: Address?
        access(all)
        let display: FungibleTokenMetadataViews.FTDisplay
        init(
            _ source: Address?,
            _ display: FungibleTokenMetadataViews.FTDisplay
        ) {
            self.source = source
            self.display = display
        }
    }

    /// The struct for the Fungible Token Paths
    ///
    access(all) struct StandardTokenPaths {
        access(all)
        let vaultPath: StoragePath
        access(all)
        let balancePath: PublicPath
        access(all)
        let receiverPath: PublicPath

        init(
            vaultPath: StoragePath,
            balancePath: PublicPath,
            receiverPath: PublicPath,
        ) {
            self.vaultPath = vaultPath
            self.balancePath = balancePath
            self.receiverPath = receiverPath
        }
    }

    /// The struct for the Fungible Token List View
    ///
    access(all) struct StandardTokenView {
        access(all)
        let identity: FTIdentity
        access(all)
        let decimals: UInt8
        access(all)
        let tags: [String]
        access(all)
        let dataSource: Address?
        access(all)
        let paths: StandardTokenPaths?
        access(all)
        let display: FTDisplayWithSource?

        init(
            identity: FTIdentity,
            decimals: UInt8,
            tags: [String],
            dataSource: Address?,
            paths: StandardTokenPaths?,
            display: FTDisplayWithSource?,
        ) {
            self.identity = identity
            self.decimals = decimals
            self.tags = tags
            self.dataSource = dataSource
            self.paths = paths
            self.display = display
        }
    }

    /** Editable FTView */

    /// The enum for the FT Capability Path
    ///
    access(all) enum FTCapPath: UInt8 {
        access(all) case receiver
        access(all) case metadata
        access(all) case provider
    }

    /// The interface for the Editable FT View Data
    ///
    access(all) resource interface EditableFTViewDataInterface {
        /// Identity of the FT
        access(all)
        let identity: FTIdentity
        // ----- FT Vault Data -----
        /// Get the Storage Path
        access(all) view
        fun getStoragePath(): StoragePath
        /// Get the Receiver Path
        access(all) view
        fun getReceiverPath(): PublicPath?
        /// Get the Metadata Path
        access(all) view
        fun getMetadataPath(): PublicPath?
        /// Get the Provider Path
        access(all) view
        fun getProviderPath(): PrivatePath?
        /// Get the Capability Path
        access(all) view
        fun getCapabilityType(_ capPath: FTCapPath): Type?
        // --- default implementation ---
        /// Check if the FT View Data is initialized
        ///
        access(all) view
        fun isInitialized(): Bool {
            return self.getReceiverPath() != nil &&
                self.getMetadataPath() != nil &&
                self.getProviderPath() != nil &&
                self.getCapabilityType(FTCapPath.receiver) != nil &&
                self.getCapabilityType(FTCapPath.metadata) != nil &&
                self.getCapabilityType(FTCapPath.provider) != nil
        }
        /// Get the FT Vault Data
        ///
        access(all)
        fun getFTVaultData(): FungibleTokenMetadataViews.FTVaultData {
            pre {
                self.isInitialized(): "FT View Data is not initialized"
            }
            let ftRef = self.identity.borrowFungibleTokenContract()
            return FungibleTokenMetadataViews.FTVaultData(
                storagePath: self.getStoragePath(),
                receiverPath: self.getReceiverPath()!,
                metadataPath: self.getMetadataPath()!,
                providerPath: self.getProviderPath()!,
                receiverLinkedType: self.getCapabilityType(FTCapPath.receiver)!,
                metadataLinkedType: self.getCapabilityType(FTCapPath.metadata)!,
                providerLinkedType: self.getCapabilityType(FTCapPath.provider)!,
                createEmptyVaultFunction: (fun (): @FungibleToken.Vault {
                    return <- ftRef.createEmptyVault()
                })
            )
        }
    }

    /// The interface for the Editable FT View Display
    ///
    access(all) resource interface EditableFTViewDisplayInterface {
        /// Identity of the FT
        access(all)
        let identity: FTIdentity
        // ----- FT Display -----
        access(all) view
        fun getSymbol(): String
        access(all) view
        fun getName(): String?
        access(all) view
        fun getDescription(): String?
        access(all) view
        fun getExternalURL(): MetadataViews.ExternalURL?
        access(all) view
        fun getLogos(): MetadataViews.Medias
        access(all) view
        fun getSocials(): {String: MetadataViews.ExternalURL}
        // --- default implementation ---
        /// Get the FT Display
        ///
        access(all)
        fun getFTDisplay(): FungibleTokenMetadataViews.FTDisplay {
            return FungibleTokenMetadataViews.FTDisplay(
                name: self.getName() ?? "Unknown Token",
                symbol: self.getSymbol(),
                description: self.getDescription() ?? "No Description",
                externalURL: self.getExternalURL() ?? MetadataViews.ExternalURL("https://fixes.world"),
                logos: self.getLogos(),
                socials: self.getSocials()
            )
        }
    }

    /// The interface for the FT View Data Editor
    ///
    access(all) resource interface FTViewDataEditor {
        /// Update the Storage Path
        access(all)
        fun updateStoragePath(_ storagePath: StoragePath)
        /// Set the FT Vault Data
        access(all)
        fun initializeVaultData(
            receiverPath: PublicPath,
            metadataPath: PublicPath,
            providerPath: PrivatePath,
            receiverType: Type,
            metadataType: Type,
            providerType: Type
        )
    }

    /// The interface for the FT View Display Editor
    ///
    access(all) resource interface FTViewDisplayEditor {
        /// Set the FT Display
        access(all)
        fun setFTDisplay(
            name: String?,
            symbol: String?,
            description: String?,
            externalURL: String?,
            logo: String?,
            socials: {String: String}
        )
    }

    /// The Resource for the FT Display
    ///
    access(all) resource EditableFTDisplay: FTViewDisplayEditor, EditableFTViewDisplayInterface, MetadataViews.Resolver {
        access(all)
        let identity: FTIdentity
        access(contract)
        let metadata: {String: String}

        init(
            _ address: Address,
            _ contractName: String,
        ) {
            self.identity = FTIdentity(address, contractName)
            self.metadata = {}
        }

        /// Set the FT Display
        /// TODO: Use entitlements to restrict the access in Cadence 1.0
        ///
        access(all)
        fun setFTDisplay(
            name: String?,
            symbol: String?,
            description: String?,
            externalURL: String?,
            logo: String?,
            socials: {String: String}
        ) {
            // set name
            if name != nil {
                self.metadata["name"] = name!
            }
            // set symbol
            if symbol != nil {
                self.metadata["symbol"] = symbol!
            }
            // set description
            if description != nil {
                self.metadata["description"] = description!
            }
            // set external URL
            if externalURL != nil {
                self.metadata["externalURL"] = externalURL!
            }
            // set logo
            if logo != nil {
                // the last 3 chars are file type, check the type
                let fileType = logo!.slice(from: logo!.length - 3, upTo: logo!.length)
                if fileType == "png" {
                    self.metadata["logo:png"] = logo!
                } else if fileType == "svg" {
                    self.metadata["logo:svg"] = logo!
                } else if fileType == "jpg" {
                    self.metadata["logo:jpg"] = logo!
                } else {
                    self.metadata["logo"] = logo!
                }
            }
            // set socials
            for key in socials.keys {
                self.metadata["social:".concat(key)] = socials[key]!
            }

            // Emit the event
            emit FTDisplayUpdated(
                address: self.identity.address,
                contractName: self.identity.contractName,
                name: name,
                symbol: symbol,
                description: description,
                externalURL: externalURL,
                logo: logo,
                socials: socials
            )
        }

        /** ---- Implement the EditableFTViewDisplayInterface ---- */

        access(all) view
        fun getSymbol(): String {
            return self.metadata["symbol"] ?? "NONE"
        }

        access(all) view
        fun getName(): String? {
            return self.metadata["name"]
        }

        access(all) view
        fun getDescription(): String? {
            return self.metadata["description"]
        }

        access(all) view
        fun getExternalURL(): MetadataViews.ExternalURL? {
            let url = self.metadata["externalURL"]
            return url != nil ? MetadataViews.ExternalURL(url!) : nil
        }

        access(all) view
        fun getLogos(): MetadataViews.Medias {
            let medias: [MetadataViews.Media] = []
            if self.metadata["logo"] != nil {
                medias.append(MetadataViews.Media(
                    file: MetadataViews.HTTPFile(url: self.metadata["logo"]!),
                    mediaType: "image/*"
                ))
            }
            if self.metadata["logo:png"] != nil {
                medias.append(MetadataViews.Media(
                    file: MetadataViews.HTTPFile(url: self.metadata["logo:png"]!),
                    mediaType: "image/png" // default is png
                ))
            }
            if self.metadata["logo:svg"] != nil {
                medias.append(MetadataViews.Media(
                    file: MetadataViews.HTTPFile(url: self.metadata["logo:svg"]!),
                    mediaType: "image/svg+xml"
                ))
            }
            if self.metadata["logo:jpg"] != nil {
                medias.append(MetadataViews.Media(
                    file: MetadataViews.HTTPFile(url: self.metadata["logo:jpg"]!),
                    mediaType: "image/jpeg"
                ))
            }
            // add default icon
            if medias.length == 0 {
                let ticker = self.getSymbol()
                let tickNameSize = 80 + (10 - ticker.length > 0 ? 10 - ticker.length : 0) * 12
                let svgStr = "data:image/svg+xml;utf8,"
                    .concat("%3Csvg%20xmlns%3D%5C%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%5C%22%20viewBox%3D%5C%22-256%20-256%20512%20512%5C%22%20width%3D%5C%22512%5C%22%20height%3D%5C%22512%5C%22%3E")
                    .concat("%3Cdefs%3E%3ClinearGradient%20gradientUnits%3D%5C%22userSpaceOnUse%5C%22%20x1%3D%5C%220%5C%22%20y1%3D%5C%22-240%5C%22%20x2%3D%5C%220%5C%22%20y2%3D%5C%22240%5C%22%20id%3D%5C%22gradient-0%5C%22%20gradientTransform%3D%5C%22matrix(0.908427%2C%20-0.41805%2C%200.320369%2C%200.696163%2C%20-69.267567%2C%20-90.441103)%5C%22%3E%3Cstop%20offset%3D%5C%220%5C%22%20style%3D%5C%22stop-color%3A%20rgb(244%2C%20246%2C%20246)%3B%5C%22%3E%3C%2Fstop%3E%3Cstop%20offset%3D%5C%221%5C%22%20style%3D%5C%22stop-color%3A%20rgb(35%2C%20133%2C%2091)%3B%5C%22%3E%3C%2Fstop%3E%3C%2FlinearGradient%3E%3C%2Fdefs%3E")
                    .concat("%3Cellipse%20style%3D%5C%22fill%3A%20rgb(149%2C%20225%2C%20192)%3B%20stroke-width%3A%201rem%3B%20paint-order%3A%20fill%3B%20stroke%3A%20url(%23gradient-0)%3B%5C%22%20ry%3D%5C%22240%5C%22%20rx%3D%5C%22240%5C%22%3E%3C%2Fellipse%3E")
                    .concat("%3Ctext%20style%3D%5C%22dominant-baseline%3A%20middle%3B%20fill%3A%20rgb(80%2C%20213%2C%20155)%3B%20font-family%3A%20system-ui%2C%20sans-serif%3B%20text-anchor%3A%20middle%3B%5C%22%20fill-opacity%3D%5C%220.2%5C%22%20y%3D%5C%22-12%5C%22%20font-size%3D%5C%22420%5C%22%3E%F0%9D%94%89%3C%2Ftext%3E")
                    .concat("%3Ctext%20style%3D%5C%22dominant-baseline%3A%20middle%3B%20fill%3A%20rgb(244%2C%20246%2C%20246)%3B%20font-family%3A%20system-ui%2C%20sans-serif%3B%20text-anchor%3A%20middle%3B%20font-style%3A%20italic%3B%20font-weight%3A%20700%3B%5C%22%20y%3D%5C%2212%5C%22%20font-size%3D%5C%22").concat(tickNameSize.toString()).concat("%5C%22%3E")
                    .concat(ticker).concat("%3C%2Ftext%3E%3C%2Fsvg%3E")
                medias.append(MetadataViews.Media(
                    file: MetadataViews.HTTPFile(url: svgStr),
                    mediaType: "image/svg+xml"
                ))
            }
            return MetadataViews.Medias(medias: medias)
        }

        access(all) view
        fun getSocials(): {String: MetadataViews.ExternalURL} {
            let ret: {String: MetadataViews.ExternalURL} = {}
            let socialKey = "social:"
            let socialKeyLen = socialKey.length
            for key in self.metadata.keys {
                if key.length >= socialKeyLen && key.slice(from: 0, upTo: socialKey.length) == socialKey {
                    let socialName = key.slice(from: socialKey.length, upTo: key.length)
                    ret[socialName] = MetadataViews.ExternalURL(self.metadata[key]!)
                }
            }
            return ret
        }

        /* --- Implement the MetadataViews.Resolver --- */

        access(all) view
        fun getViews(): [Type] {
            return [
                Type<FungibleTokenMetadataViews.FTDisplay>()
            ]
        }

        access(all) view
        fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<FungibleTokenMetadataViews.FTDisplay>():
                    return self.getFTDisplay()
            }
            return nil
        }
    }

    /// Create the FT View Data
    ///
    access(all)
    fun createEditableFTDisplay(
        _ address: Address,
        _ contractName: String,
    ): @EditableFTDisplay {
        return <- create EditableFTDisplay(address, contractName)
    }

    /// The Resource for the FT View
    ///
    access(all) resource EditableFTView: FTViewDataEditor, FTViewDisplayEditor, EditableFTViewDataInterface, EditableFTViewDisplayInterface, MetadataViews.Resolver {
        access(self)
        let display: @EditableFTDisplay
        access(all)
        let identity: FTIdentity
        access(contract)
        var storagePath: StoragePath
        access(contract)
        let capabilityPaths: {FTCapPath: CapabilityPath}
        access(contract)
        let capabilityTypes: {FTCapPath: Type}

        init(
            _ address: Address,
            _ contractName: String,
            _ storagePath: StoragePath,
        ) {
            self.identity = FTIdentity(address, contractName)
            self.display <- create EditableFTDisplay(address, contractName)
            self.capabilityPaths = {}
            self.capabilityTypes = {}
            self.storagePath = storagePath
        }

        /// @deprecated in Cadence 1.0
        destroy() {
            destroy self.display
        }

        // ---- Writable Functions ----

        /// Update the Storage Path
        /// TODO: Use entitlements to restrict the access in Cadence 1.0
        ///
        access(all)
        fun updateStoragePath(_ storagePath: StoragePath) {
            self.storagePath = storagePath

            emit FTViewStoragePathUpdated(
                address: self.identity.address,
                contractName: self.identity.contractName,
                storagePath: storagePath
            )
        }

        /// Initialize the FT View Data
        /// TODO: Use entitlements to restrict the access in Cadence 1.0
        ///
        access(all)
        fun initializeVaultData(
            receiverPath: PublicPath,
            metadataPath: PublicPath,
            providerPath: PrivatePath,
            receiverType: Type,
            metadataType: Type,
            providerType: Type
        ) {
            self.capabilityPaths[FTCapPath.receiver] = receiverPath
            self.capabilityPaths[FTCapPath.metadata] = metadataPath
            self.capabilityPaths[FTCapPath.provider] = providerPath
            self.capabilityTypes[FTCapPath.receiver] = receiverType
            self.capabilityTypes[FTCapPath.metadata] = metadataType
            self.capabilityTypes[FTCapPath.provider] = providerType

            // Emit the event
            emit FTVaultDataUpdated(
                address: self.identity.address,
                contractName: self.identity.contractName,
                storagePath: self.storagePath,
                receiverPath: receiverPath,
                metadataPath: metadataPath,
                providerPath: providerPath,
                receiverType: receiverType,
                metadataType: metadataType,
                providerType: providerType
            )
        }

        /** ---- Implement the EditableFTViewDataInterface ---- */

        access(all) view
        fun getStoragePath(): StoragePath {
            return self.storagePath
        }

        /// Get the Receiver Path
        access(all) view
        fun getReceiverPath(): PublicPath? {
            return self.capabilityPaths[FTCapPath.receiver] as! PublicPath?
        }

        /// Get the Metadata Path
        access(all) view
        fun getMetadataPath(): PublicPath? {
            return self.capabilityPaths[FTCapPath.metadata] as! PublicPath?
        }

        /// Get the Provider Path
        access(all) view
        fun getProviderPath(): PrivatePath? {
            return self.capabilityPaths[FTCapPath.provider] as! PrivatePath?
        }

        /// Get the Capability Path
        access(all) view
        fun getCapabilityType(_ capPath: FTCapPath): Type? {
            return self.capabilityTypes[capPath]
        }

        /** ---- Implement the FTViewDataEditor ---- */

        /// Set the FT Display
        /// TODO: Use entitlements to restrict the access in Cadence 1.0
        ///
        access(all)
        fun setFTDisplay(
            name: String?,
            symbol: String?,
            description: String?,
            externalURL: String?,
            logo: String?,
            socials: {String: String}
        ) {
            self.display.setFTDisplay(
                name: name,
                symbol: symbol,
                description: description,
                externalURL: externalURL,
                logo: logo,
                socials: socials
            )
        }

        /** ---- Implement the FTViewDisplayInterface ---- */

        access(all) view
        fun getSymbol(): String {
            return self.display.getSymbol()
        }

        access(all) view
        fun getName(): String? {
            return self.display.getName()
        }

        access(all) view
        fun getDescription(): String? {
            return self.display.getDescription()
        }

        access(all) view
        fun getExternalURL(): MetadataViews.ExternalURL? {
            return self.display.getExternalURL()
        }

        access(all) view
        fun getLogos(): MetadataViews.Medias {
            return self.display.getLogos()
        }

        access(all) view
        fun getSocials(): {String: MetadataViews.ExternalURL} {
            return self.display.getSocials()
        }

        /* --- Implement the MetadataViews.Resolver --- */

        access(all) view
        fun getViews(): [Type] {
            return [
                Type<MetadataViews.ExternalURL>(),
                Type<FungibleTokenMetadataViews.FTView>(),
                Type<FungibleTokenMetadataViews.FTDisplay>(),
                Type<FungibleTokenMetadataViews.FTVaultData>()
            ]
        }

        access(all) view
        fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.ExternalURL>():
                    return self.getExternalURL()
                case Type<FungibleTokenMetadataViews.FTView>():
                    return FungibleTokenMetadataViews.FTView(
                        display: self.getFTDisplay(),
                        vaultData: self.getFTVaultData()
                    )
                case Type<FungibleTokenMetadataViews.FTDisplay>():
                    return self.getFTDisplay()
                case Type<FungibleTokenMetadataViews.FTVaultData>():
                    return self.getFTVaultData()
            }
            return nil
        }
    }

    /// Create the FT View Data
    ///
    access(all)
    fun createEditableFTView(
        _ address: Address,
        _ contractName: String,
        _ storagePath: StoragePath,
    ): @EditableFTView {
        return <- create EditableFTView(address, contractName, storagePath)
    }

    /// Build the FT Vault Type
    ///
    access(all) view
    fun buildFTVaultType(_ address: Address, _ contractName: String): Type? {
        let addrStr = address.toString()
        let addrStrNo0x = addrStr.slice(from: 2, upTo: addrStr.length)
        return CompositeType("A.".concat(addrStrNo0x).concat(".").concat(contractName).concat(".Vault"))
    }
}
