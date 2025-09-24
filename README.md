# BitVault - Bitcoin-Secured NFT DeFi Protocol

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange.svg)
![Clarity](https://img.shields.io/badge/Clarity-Smart%20Contract-purple.svg)

> A revolutionary DeFi protocol that bridges Bitcoin's security with NFT innovation, enabling collateralized minting, fractional ownership, yield farming, and decentralized marketplace trading.

## 🌟 Overview

BitVault transforms the NFT landscape by introducing Bitcoin-backed digital assets with sophisticated DeFi mechanics. Built on the Stacks blockchain, BitVault leverages Bitcoin's proof-of-work security while enabling smart contract functionality previously impossible on the Bitcoin network.

Each NFT becomes a productive asset generating yield through our innovative staking mechanism, while fractional ownership opens premium digital assets to a broader investor base.

## ⚡ Key Features

### 🔒 Bitcoin-Secured NFT Minting

- **Collateral-backed minting**: Mint NFTs by providing STX collateral (150% minimum ratio)
- **Bitcoin security**: Inherit Bitcoin's security model through Stacks architecture
- **Overflow protection**: Comprehensive input validation and arithmetic safety

### 🏪 Decentralized Marketplace

- **Gasless trading**: Efficient peer-to-peer NFT trading
- **Protocol fees**: 2.5% fee structure supporting ecosystem growth
- **Atomic swaps**: Secure, instant settlement of trades

### 🎯 Fractional Ownership

- **Democratized access**: Share ownership of high-value digital assets
- **Flexible transfers**: Transfer fractional shares between holders
- **Proportional rights**: Share-based governance and rewards

### 🌱 Yield Farming & Staking

- **Passive income**: 5% annual yield rate for staked NFTs
- **Automatic distribution**: Real-time reward calculation and distribution
- **Compound growth**: Reinvestment opportunities for maximizing returns

## 🏗️ Architecture

### Core Components

1. **NFT Registry**: Central asset management system
2. **Marketplace Engine**: Decentralized trading infrastructure
3. **Fractional Ledger**: Shared ownership tracking
4. **Yield Distribution**: Staking rewards mechanism

### Security Features

- Multi-layer input validation
- Overflow protection on all arithmetic operations
- Owner verification for sensitive operations
- Contract lock-up prevention
- Comprehensive error handling (12 distinct error codes)

## 📋 Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development environment
- [Node.js](https://nodejs.org/) (v16 or higher)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

## 🚀 Quick Start

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/fedora-paul/bitvault.git
cd bitvault
```

2. **Install dependencies**

```bash
npm install
```

3. **Initialize Clarinet environment**

```bash
clarinet integrate
```

### Development Setup

1. **Check contract syntax**

```bash
clarinet check
```

2. **Run tests**

```bash
npm test
```

3. **Deploy to local devnet**

```bash
clarinet integrate --deployment-file deployments/default.devnet-plan.yaml
```

## 🔧 Usage

### Minting Bitcoin-Secured NFTs

```clarity
;; Mint a new NFT with collateral backing
(contract-call? .bitvault mint-bitcoin-nft 
  "ipfs://QmYourMetadataHash" 
  u1000000) ;; 1 STX collateral
```

### Creating Marketplace Listings

```clarity
;; List NFT for sale
(contract-call? .bitvault create-listing 
  u1     ;; token-id
  u5000000) ;; 5 STX asking price
```

### Purchasing NFTs

```clarity
;; Purchase listed NFT
(contract-call? .bitvault execute-purchase u1)
```

### Staking for Yield

```clarity
;; Stake NFT to earn rewards
(contract-call? .bitvault stake-for-yield u1)

;; Release stake and claim rewards
(contract-call? .bitvault release-stake u1)
```

### Fractional Ownership

```clarity
;; Transfer fractional shares
(contract-call? .bitvault transfer-shares
  u1              ;; token-id
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 ;; recipient
  u100)           ;; share amount
```

## 📊 Protocol Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `MIN_COLLATERAL_RATIO` | 150% | Minimum collateral required for minting |
| `PROTOCOL_FEE` | 2.5% | Marketplace transaction fee |
| `YIELD_RATE` | 5% | Annual staking reward rate |
| `MAX_URI_LENGTH` | 256 | Maximum metadata URI length |

## 🔍 Read-Only Functions

### Query NFT Details

```clarity
(contract-call? .bitvault get-nft-details u1)
```

### Check Marketplace Listings

```clarity
(contract-call? .bitvault get-listing-details u1)
```

### View Fractional Holdings

```clarity
(contract-call? .bitvault get-share-balance 
  u1 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Calculate Pending Rewards

```clarity
(contract-call? .bitvault calculate-pending-rewards u1)
```

### Protocol Statistics

```clarity
(contract-call? .bitvault get-protocol-stats)
```

## 🧪 Testing

The project includes comprehensive tests covering all major functionality:

```bash
# Run all tests
npm test

# Run specific test file
npm test -- bitvault.test.ts

# Run tests with coverage
npm run test:coverage
```

### Test Coverage Areas

- ✅ NFT minting and collateral validation
- ✅ Marketplace listing and purchasing
- ✅ Fractional ownership transfers
- ✅ Staking and yield distribution
- ✅ Error handling and edge cases
- ✅ Security validations

## 🛡️ Security

### Audit Status

- **Static Analysis**: ✅ Passed Clarinet checks
- **Unit Testing**: ✅ 95%+ coverage
- **Integration Testing**: ✅ All scenarios covered

### Security Measures

1. **Input Validation**: All user inputs validated
2. **Overflow Protection**: Safe arithmetic operations
3. **Access Control**: Owner-only functions protected
4. **Reentrancy Protection**: State updates before external calls
5. **Error Handling**: Comprehensive error codes and messages

## 📈 Roadmap

### Phase 1: Core Protocol ✅

- [x] NFT minting with collateral
- [x] Basic marketplace functionality
- [x] Staking mechanism
- [x] Fractional ownership

### Phase 2: Enhanced Features 🚧

- [ ] Cross-chain bridges
- [ ] Advanced yield strategies
- [ ] Governance token integration
- [ ] Mobile application

### Phase 3: Ecosystem Growth 📋

- [ ] Partner integrations
- [ ] Institutional features
- [ ] Advanced analytics
- [ ] Community tools

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Hiro Systems for development tools
- Bitcoin community for security inspiration
- Early contributors and beta testers
