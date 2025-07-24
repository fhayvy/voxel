# 🌟 Voxel

**A next-generation NFT smart contract for the Stacks blockchain, engineered for the cosmic digital frontier.**

Voxel is a premium ERC-721 equivalent NFT implementation that brings advanced functionality and cosmic-themed branding to the Stacks ecosystem. Forge unique stellar assets, trade in the cosmic marketplace, and navigate the digital cosmos with unprecedented control and flexibility.

## ✨ Features

### 🔨 Advanced Minting System
- **Architect Minting**: Contract owner can forge stellars for any recipient
- **Public Forge**: Whitelisted cosmic explorers can forge their own stellars
- **Constellation Batching**: Mint multiple stellars in a single transaction
- **Configurable Pricing**: Set stardust costs for public minting

### 🌌 Cosmic Marketplace
- **Stellar Trading**: List and trade stellars with built-in marketplace
- **Nebula Fees**: Automatic royalty distribution to the nebula vault
- **Secure Transactions**: Built-in STX transfer handling with fee calculations

### 🛡️ Enhanced Security & Control
- **Stellar Locking**: Lock stellars to prevent transfers
- **Forge Status**: Pause/unpause contract functionality
- **Cosmic Explorer Whitelist**: Manage privileged minting access
- **Emergency Extraction**: Owner can recover stuck funds

### 🎨 Rich Metadata System
- **Stellar Cosmos**: Comprehensive metadata with designation, chronicle, constellation, and properties
- **Freezable Metadata**: Permanently lock metadata URLs
- **Dynamic URIs**: Configurable base URI for metadata endpoints

### 🚀 Advanced Transfer System
- **Safe Warping**: Enhanced transfer functions with memo support
- **Operator Approvals**: Delegate transfer rights to other addresses
- **Transfer Restrictions**: Respect stellar locks and contract status

## 🏗️ Contract Architecture

### Data Structures

```clarity
;; Core stellar metadata
stellar-cosmos: {
    designation: string-ascii(64),    // Stellar name/title
    chronicle: string-ascii(256),     // Description/story
    constellation: string-ascii(256), // Image/visual data
    properties: string-ascii(512)     // Additional attributes
}
```

### Key Variables
- `last-stellar-id`: Current maximum stellar ID
- `forge-limit`: Maximum number of stellars that can be forged
- `stardust-price`: Cost to forge stellars (in microSTX)
- `nebula-percentage`: Marketplace fee percentage (basis points)
- `cosmic-base-uri`: Base URI for metadata endpoints

## 🚀 Getting Started

### Deployment
1. Deploy the contract to Stacks blockchain
2. The deployer becomes the `contract-architect` with admin privileges
3. Configure initial parameters (forge limit, pricing, etc.)

### Basic Usage

#### Forge a Stellar (Architect Only)
```clarity
(forge-stellar 
    'SP1234...RECIPIENT 
    "Stellar Alpha" 
    "A magnificent stellar creation" 
    "https://cosmos.art/alpha.png" 
    "{\"rarity\":\"legendary\",\"power\":\"9000\"}")
```

#### Public Stellar Forging
```clarity
(public-forge-stellar 
    "My Stellar" 
    "Created by cosmic explorer" 
    "https://my-art.com/stellar.png" 
    "{\"type\":\"explorer\"}")
```

#### Warp (Transfer) Stellar
```clarity
(warp-stellar u1 'SP1234...FROM 'SP5678...TO)
```

#### Trade in Cosmic Marketplace
```clarity
;; List for sale
(list-stellar-for-trade u1 u1000000) ;; 1 STX

;; Purchase stellar
(acquire-stellar u1)
```

## 🎛️ Admin Functions

### Forge Management
- `activate-forge` / `deactivate-forge`: Control contract operation
- `set-forge-limit`: Update maximum stellar supply
- `set-stardust-price`: Configure minting costs

### Cosmic Explorer Management
- `add-cosmic-explorer`: Grant minting privileges
- `batch-add-cosmic-explorers`: Add multiple explorers at once
- `remove-cosmic-explorer`: Revoke minting privileges

### Marketplace Configuration
- `set-nebula-percentage`: Configure marketplace fees (max 20%)
- `set-nebula-vault`: Update fee recipient address

### Metadata Management
- `set-cosmic-base-uri`: Update metadata base URL
- `freeze-cosmos`: Permanently lock metadata (irreversible)

## 📖 Read-Only Functions

### Stellar Information
- `get-stellar-navigator(id)`: Get stellar owner
- `get-stellar-cosmos(id)`: Get stellar metadata
- `get-stellar-market-value(id)`: Check listing price
- `is-stellar-locked(id)`: Check if stellar is locked

### Contract Status
- `get-forge-status()`: Check if forging is active
- `total-stellars-forged()`: Get total supply
- `get-stardust-price()`: Current minting cost
- `get-nebula-info()`: Marketplace fee information

### User Information
- `stellar-balance-of(user)`: Get user's stellar count
- `is-approved-for-all-stellars(owner, operator)`: Check operator approval

## 🔒 Security Features

### Access Control
- **Architect-only functions**: Critical operations restricted to contract owner
- **Navigator verification**: Stellar operations require ownership proof
- **Operator system**: Secure delegation of transfer rights

### Transfer Protection
- **Lock mechanism**: Prevent transfers of specific stellars
- **Contract pause**: Halt all operations in emergencies
- **Safe transfer**: Enhanced transfer with memo support

### Economic Security
- **Fee validation**: Ensure marketplace fees don't exceed 20%
- **Balance checks**: Verify sufficient funds before operations
- **Emergency extraction**: Recover stuck contract funds

## 🌌 Cosmic Terminology

Voxel uses space-themed terminology throughout:

- **Stellar**: NFT token
- **Navigator**: Token owner
- **Architect**: Contract owner/admin
- **Forge**: Mint/create
- **Warp**: Transfer
- **Cosmos**: Metadata
- **Constellation**: Batch of stellars
- **Nebula**: Marketplace fees
- **Stardust**: STX currency/pricing
- **Cosmic Explorer**: Whitelisted user
- **Obliterate**: Burn token

## 📄 License

This project is released under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
