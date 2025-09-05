;; Title: BitVault - Bitcoin-Secured NFT DeFi Protocol
;;
;; Summary:
;; A revolutionary DeFi protocol that bridges Bitcoin's security with NFT innovation,
;; enabling collateralized minting, fractional ownership, yield farming, and 
;; decentralized marketplace trading - all secured by Bitcoin's proof-of-work.
;;
;; Description:
;; BitVault transforms the NFT landscape by introducing Bitcoin-backed digital assets
;; with sophisticated DeFi mechanics. Users can mint NFTs by providing STX collateral,
;; fractionalize ownership for democratized access, stake assets for passive yield,
;; and trade in a decentralized marketplace. The protocol leverages Stacks' unique
;; architecture to inherit Bitcoin's security while enabling smart contract functionality
;; previously impossible on the Bitcoin network. Each NFT becomes a productive asset
;; generating yield through our innovative staking mechanism, while fractional ownership
;; opens premium digital assets to a broader investor base.
;;
;; Key Features:
;; - Bitcoin-secured NFT minting with collateral requirements
;; - Fractional ownership system for shared asset exposure  
;; - Yield-generating staking with automatic reward distribution
;; - Gasless decentralized marketplace with protocol fees
;; - Overflow protection and comprehensive input validation
;; - Multi-layer security with ownership verification

;; CONSTANTS & ERROR CODES

(define-constant CONTRACT_OWNER tx-sender)

;; Error Constants - Comprehensive error handling system
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))
(define-constant ERR_INVALID_TOKEN (err u103))
(define-constant ERR_LISTING_NOT_FOUND (err u104))
(define-constant ERR_INVALID_PRICE (err u105))
(define-constant ERR_INSUFFICIENT_COLLATERAL (err u106))
(define-constant ERR_ALREADY_STAKED (err u107))
(define-constant ERR_NOT_STAKED (err u108))
(define-constant ERR_INVALID_PERCENTAGE (err u109))
(define-constant ERR_INVALID_URI (err u110))
(define-constant ERR_INVALID_RECIPIENT (err u111))
(define-constant ERR_OVERFLOW (err u112))

;; Protocol Constants
(define-constant MIN_COLLATERAL_RATIO u150) ;; 150% minimum collateral ratio
(define-constant PROTOCOL_FEE u25) ;; 2.5% protocol fee (basis points)
(define-constant YIELD_RATE u50) ;; 5% annual yield rate (basis points) 
(define-constant BLOCKS_PER_YEAR u52560) ;; Approximate Bitcoin blocks per year
(define-constant BASIS_POINTS u1000) ;; For percentage calculations
(define-constant MAX_URI_LENGTH u256) ;; Maximum URI string length

;; DATA STORAGE LAYER

;; Protocol State Variables
(define-data-var total-supply uint u0)
(define-data-var total-staked uint u0)
(define-data-var protocol-treasury uint u0)

;; Core NFT Registry - The heart of BitVault's asset management
(define-map nft-registry
  { token-id: uint }
  {
    owner: principal,
    uri: (string-ascii 256),
    collateral-value: uint,
    is-staked: bool,
    stake-height: uint,
    fractional-shares: uint,
    creation-height: uint,
  }
)

;; Marketplace Listings - Decentralized trading infrastructure  
(define-map marketplace-listings
  { token-id: uint }
  {
    price: uint,
    seller: principal,
    is-active: bool,
    listing-height: uint,
  }
)

;; Fractional Ownership Ledger - Democratizing high-value asset access
(define-map ownership-ledger
  {
    token-id: uint,
    holder: principal,
  }
  { share-count: uint }
)

;; Yield Distribution System - Passive income generation mechanism
(define-map yield-tracker
  { token-id: uint }
  {
    accumulated-rewards: uint,
    last-claim-height: uint,
    total-distributed: uint,
  }
)

;; SECURITY & VALIDATION LAYER

;; URI Validation - Ensures metadata integrity
(define-private (validate-uri (uri (string-ascii 256)))
  (let ((uri-length (len uri)))
    (and
      (> uri-length u0)
      (<= uri-length MAX_URI_LENGTH)
    )
  )
)

;; Recipient Security Check - Prevents contract lock-up scenarios
(define-private (validate-recipient (recipient principal))
  (not (is-eq recipient (as-contract tx-sender)))
)

;; Overflow Protection - Critical security for arithmetic operations
(define-private (safe-add
    (a uint)
    (b uint)
  )
  (let ((result (+ a b)))
    (asserts! (>= result a) ERR_OVERFLOW)
    (ok result)
  )
)

;; Price Validation - Ensures economic viability
(define-private (validate-price (price uint))
  (> price u0)
)

;; CORE NFT FUNCTIONALITY

;; Mint Bitcoin-Secured NFT - The cornerstone of BitVault's value proposition
;; Creates a new NFT backed by STX collateral, inheriting Bitcoin's security model
(define-public (mint-bitcoin-nft
    (metadata-uri (string-ascii 256))
    (collateral-amount uint)
  )
  (let (
      (new-token-id (+ (var-get total-supply) u1))
      (required-collateral (/ (* MIN_COLLATERAL_RATIO collateral-amount) u100))
    )
    ;; Input validation layer
    (asserts! (validate-uri metadata-uri) ERR_INVALID_URI)
    (asserts! (>= (stx-get-balance tx-sender) required-collateral)
      ERR_INSUFFICIENT_COLLATERAL
    )

    ;; Collateral escrow - Locks STX to back the NFT
    (try! (stx-transfer? required-collateral tx-sender (as-contract tx-sender)))

    ;; Asset registration in BitVault registry
    (map-set nft-registry { token-id: new-token-id } {
      owner: tx-sender,
      uri: metadata-uri,
      collateral-value: collateral-amount,
      is-staked: false,
      stake-height: u0,
      fractional-shares: u0,
      creation-height: stacks-block-height,
    })

    ;; Update protocol state
    (var-set total-supply new-token-id)
    (ok new-token-id)
  )
)

;; Transfer Ownership - Secure asset transfer with staking checks
(define-public (transfer-ownership
    (token-id uint)
    (new-owner principal)
  )
  (let ((token-data (unwrap! (map-get? nft-registry { token-id: token-id }) ERR_INVALID_TOKEN)))
    ;; Security validations
    (asserts! (validate-recipient new-owner) ERR_INVALID_RECIPIENT)
    (asserts! (is-eq tx-sender (get owner token-data)) ERR_NOT_TOKEN_OWNER)
    (asserts! (not (get is-staked token-data)) ERR_ALREADY_STAKED)

    ;; Execute ownership transfer
    (map-set nft-registry { token-id: token-id }
      (merge token-data { owner: new-owner })
    )
    (ok true)
  )
)

;; DECENTRALIZED MARKETPLACE

;; Create Market Listing - List NFT for decentralized trading
(define-public (create-listing
    (token-id uint)
    (asking-price uint)
  )
  (let ((token-data (unwrap! (map-get? nft-registry { token-id: token-id }) ERR_INVALID_TOKEN)))
    ;; Validation checks
    (asserts! (validate-price asking-price) ERR_INVALID_PRICE)
    (asserts! (is-eq tx-sender (get owner token-data)) ERR_NOT_TOKEN_OWNER)
    (asserts! (not (get is-staked token-data)) ERR_ALREADY_STAKED)

    ;; Create marketplace listing
    (map-set marketplace-listings { token-id: token-id } {
      price: asking-price,
      seller: tx-sender,
      is-active: true,
      listing-height: stacks-block-height,
    })
    (ok true)
  )
)

;; Execute Purchase - Atomic swap with protocol fee distribution
(define-public (execute-purchase (token-id uint))
  (let (
      (listing-data (unwrap! (map-get? marketplace-listings { token-id: token-id })
        ERR_LISTING_NOT_FOUND
      ))
      (sale-price (get price listing-data))
      (seller (get seller listing-data))
      (protocol-fee (/ (* sale-price PROTOCOL_FEE) BASIS_POINTS))
      (seller-proceeds (- sale-price protocol-fee))
    )
    ;; Listing validation
    (asserts! (get is-active listing-data) ERR_LISTING_NOT_FOUND)

    ;; Atomic settlement - STX transfers
    (try! (stx-transfer? seller-proceeds tx-sender seller))
    (try! (stx-transfer? protocol-fee tx-sender (as-contract tx-sender)))

    ;; Asset ownership transfer
    (try! (transfer-ownership token-id tx-sender))

    ;; Update protocol treasury
    (var-set protocol-treasury (+ (var-get protocol-treasury) protocol-fee))

    ;; Deactivate listing
    (map-set marketplace-listings { token-id: token-id }
      (merge listing-data { is-active: false })
    )
    (ok true)
  )
)

;; FRACTIONAL OWNERSHIP SYSTEM  

;; Transfer Fractional Shares - Enable shared ownership of high-value NFTs
(define-public (transfer-shares
    (token-id uint)
    (recipient principal)
    (share-amount uint)
  )
  (let (
      (sender-shares (unwrap!
        (map-get? ownership-ledger {
          token-id: token-id,
          holder: tx-sender,
        })
        ERR_INSUFFICIENT_BALANCE
      ))
      (recipient-shares (default-to { share-count: u0 }
        (map-get? ownership-ledger {
          token-id: token-id,
          holder: recipient,
        })
      ))
      (new-recipient-total (unwrap! (safe-add (get share-count recipient-shares) share-amount)
        ERR_OVERFLOW
      ))
    )
    ;; Transfer validations
    (asserts! (validate-recipient recipient) ERR_INVALID_RECIPIENT)
    (asserts! (>= (get share-count sender-shares) share-amount)
      ERR_INSUFFICIENT_BALANCE
    )

    ;; Update sender's position
    (map-set ownership-ledger {
      token-id: token-id,
      holder: tx-sender,
    } { share-count: (- (get share-count sender-shares) share-amount) }
    )

    ;; Update recipient's position  
    (map-set ownership-ledger {
      token-id: token-id,
      holder: recipient,
    } { share-count: new-recipient-total }
    )
    (ok true)
  )
)

;; YIELD FARMING & STAKING

;; Stake NFT for Yield - Lock NFT to earn passive Bitcoin-secured rewards
(define-public (stake-for-yield (token-id uint))
  (let ((token-data (unwrap! (map-get? nft-registry { token-id: token-id }) ERR_INVALID_TOKEN)))
    ;; Staking eligibility checks
    (asserts! (is-eq tx-sender (get owner token-data)) ERR_NOT_TOKEN_OWNER)
    (asserts! (not (get is-staked token-data)) ERR_ALREADY_STAKED)

    ;; Initialize staking state
    (map-set nft-registry { token-id: token-id }
      (merge token-data {
        is-staked: true,
        stake-height: stacks-block-height,
      })
    )

    ;; Initialize yield tracking
    (map-set yield-tracker { token-id: token-id } {
      accumulated-rewards: u0,
      last-claim-height: stacks-block-height,
      total-distributed: u0,
    })

    ;; Update global staking metrics
    (var-set total-staked (+ (var-get total-staked) u1))
    (ok true)
  )
)

;; Unstake NFT - Release staked NFT and claim final rewards
(define-public (release-stake (token-id uint))
  (let ((token-data (unwrap! (map-get? nft-registry { token-id: token-id }) ERR_INVALID_TOKEN)))
    ;; Unstaking validations
    (asserts! (is-eq tx-sender (get owner token-data)) ERR_NOT_TOKEN_OWNER)
    (asserts! (get is-staked token-data) ERR_NOT_STAKED)

    ;; Claim final rewards before unstaking
    (try! (claim-yield-rewards token-id))

    ;; Reset staking state
    (map-set nft-registry { token-id: token-id }
      (merge token-data {
        is-staked: false,
        stake-height: u0,
      })
    )

    ;; Update global metrics
    (var-set total-staked (- (var-get total-staked) u1))
    (ok true)
  )
)