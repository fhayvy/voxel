;; Voxel - ERC-721 equivalent NFT contract for Stacks blockchain
;; A premium non-fungible token implementation with advanced minting, trading, and metadata capabilities

;; Define the NFT
(define-non-fungible-token stellar-forge uint)

;; Constants
(define-constant contract-architect tx-sender)
(define-constant err-architect-only (err u100))
(define-constant err-not-stellar-owner (err u101))
(define-constant err-stellar-not-found (err u102))
(define-constant err-cosmos-frozen (err u103))
(define-constant err-forge-limit-exceeded (err u104))
(define-constant err-constellation-size-exceeded (err u105))
(define-constant err-forge-inactive (err u106))
(define-constant err-invalid-nebula-percentage (err u107))
(define-constant err-stellar-exists (err u108))
(define-constant err-insufficient-stardust (err u109))
(define-constant err-warp-failed (err u110))

;; Data variables
(define-data-var last-stellar-id uint u0)
(define-data-var cosmic-base-uri (string-ascii 256) "https://api.stellarforge.space/cosmos/")
(define-data-var cosmos-frozen bool false)
(define-data-var forge-limit uint u10000)
(define-data-var forge-active bool true)
(define-data-var nebula-percentage uint u500) ;; 5% = 500 basis points
(define-data-var nebula-vault principal tx-sender)
(define-data-var stardust-price uint u0) ;; Price in microSTX

;; Data maps
(define-map stellar-cosmos uint {
    designation: (string-ascii 64),
    chronicle: (string-ascii 256),
    constellation: (string-ascii 256),
    properties: (string-ascii 512)
})

(define-map cosmic-operators {navigator: principal, operator: principal} bool)
(define-map stellar-approvals uint principal)
(define-map navigator-stellar-count principal uint)
(define-map cosmic-explorers principal bool)
(define-map stellar-market-value uint uint)
(define-map stellar-locked uint bool)

;; Private functions
(define-private (is-stellar-navigator (stellar-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stellar-forge stellar-id) false)))

(define-private (is-approved-cosmic-operator (navigator principal) (operator principal))
    (default-to false (map-get? cosmic-operators {navigator: navigator, operator: operator})))

(define-private (is-approved-for-stellar (stellar-id uint) (user principal))
    (match (map-get? stellar-approvals stellar-id)
        approved (is-eq approved user)
        false))

(define-private (is-cosmic-explorer (user principal))
    (default-to false (map-get? cosmic-explorers user)))

(define-private (update-navigator-stellar-count (navigator principal) (delta int))
    (let ((current-count (default-to u0 (map-get? navigator-stellar-count navigator))))
        (if (> delta 0)
            (map-set navigator-stellar-count navigator (+ current-count (to-uint delta)))
            (map-set navigator-stellar-count navigator (if (>= current-count (to-uint (- delta))) 
                                                (- current-count (to-uint (- delta))) 
                                                u0)))))

(define-private (calculate-nebula-fee (market-value uint))
    (/ (* market-value (var-get nebula-percentage)) u10000))

(define-private (add-cosmic-explorer-helper (user principal))
    (map-set cosmic-explorers user true))

;; Read-only functions
(define-read-only (get-last-stellar-id)
    (ok (var-get last-stellar-id)))

(define-read-only (get-stellar-uri (stellar-id uint))
    (ok (concat (var-get cosmic-base-uri) (int-to-ascii (to-int stellar-id)))))

(define-read-only (get-stellar-navigator (stellar-id uint))
    (ok (nft-get-owner? stellar-forge stellar-id)))

(define-read-only (get-stellar-cosmos (stellar-id uint))
    (map-get? stellar-cosmos stellar-id))

(define-read-only (get-forge-limit)
    (ok (var-get forge-limit)))

(define-read-only (get-cosmic-base-uri)
    (ok (var-get cosmic-base-uri)))

(define-read-only (get-forge-status)
    (ok (var-get forge-active)))

(define-read-only (get-nebula-info)
    (ok {percentage: (var-get nebula-percentage), vault: (var-get nebula-vault)}))

(define-read-only (get-stardust-price)
    (ok (var-get stardust-price)))

(define-read-only (stellar-balance-of (navigator principal))
    (ok (default-to u0 (map-get? navigator-stellar-count navigator))))

(define-read-only (get-stellar-approved (stellar-id uint))
    (map-get? stellar-approvals stellar-id))

(define-read-only (is-approved-for-all-stellars (navigator principal) (operator principal))
    (is-approved-cosmic-operator navigator operator))

(define-read-only (total-stellars-forged)
    (ok (var-get last-stellar-id)))

(define-read-only (get-stellar-market-value (stellar-id uint))
    (map-get? stellar-market-value stellar-id))

(define-read-only (is-stellar-locked (stellar-id uint))
    (default-to false (map-get? stellar-locked stellar-id)))

;; Public functions

;; Forge a new stellar NFT (architect only)
(define-public (forge-stellar (recipient principal) (designation (string-ascii 64)) (chronicle (string-ascii 256)) (constellation (string-ascii 256)) (properties (string-ascii 512)))
    (let 
        (
            (stellar-id (+ (var-get last-stellar-id) u1))
            (forge-cost (var-get stardust-price))
        )
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (asserts! (var-get forge-active) err-forge-inactive)
        (asserts! (<= stellar-id (var-get forge-limit)) err-forge-limit-exceeded)
        (if (> forge-cost u0)
            (try! (stx-transfer? forge-cost tx-sender (var-get nebula-vault)))
            true)
        (try! (nft-mint? stellar-forge stellar-id recipient))
        (map-set stellar-cosmos stellar-id {
            designation: designation,
            chronicle: chronicle, 
            constellation: constellation,
            properties: properties
        })
        (update-navigator-stellar-count recipient 1)
        (var-set last-stellar-id stellar-id)
        (ok stellar-id)))

;; Public stellar forging (for cosmic explorers or open forge)
(define-public (public-forge-stellar (designation (string-ascii 64)) (chronicle (string-ascii 256)) (constellation (string-ascii 256)) (properties (string-ascii 512)))
    (let 
        (
            (stellar-id (+ (var-get last-stellar-id) u1))
            (forge-cost (var-get stardust-price))
        )
        (asserts! (var-get forge-active) err-forge-inactive)
        (asserts! (or (is-cosmic-explorer tx-sender) (is-eq (var-get stardust-price) u0)) err-architect-only)
        (asserts! (<= stellar-id (var-get forge-limit)) err-forge-limit-exceeded)
        (if (> forge-cost u0)
            (try! (stx-transfer? forge-cost tx-sender (var-get nebula-vault)))
            true)
        (try! (nft-mint? stellar-forge stellar-id tx-sender))
        (map-set stellar-cosmos stellar-id {
            designation: designation,
            chronicle: chronicle, 
            constellation: constellation,
            properties: properties
        })
        (update-navigator-stellar-count tx-sender 1)
        (var-set last-stellar-id stellar-id)
        (ok stellar-id)))

;; Warp stellar NFT (enhanced with lock check)
(define-public (warp-stellar (stellar-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (var-get forge-active) err-forge-inactive)
        (asserts! (not (is-stellar-locked stellar-id)) err-warp-failed)
        (asserts! (or (is-stellar-navigator stellar-id tx-sender) 
                     (is-approved-cosmic-operator sender tx-sender)
                     (is-approved-for-stellar stellar-id tx-sender))
                 err-not-stellar-owner)
        (update-navigator-stellar-count sender -1)
        (update-navigator-stellar-count recipient 1)
        (map-delete stellar-approvals stellar-id)
        (nft-transfer? stellar-forge stellar-id sender recipient)))

;; Safe warp with cosmic data
(define-public (safe-warp-stellar (stellar-id uint) (sender principal) (recipient principal) (cosmic-memo (buff 34)))
    (begin
        (try! (warp-stellar stellar-id sender recipient))
        (print cosmic-memo)
        (ok true)))

;; Approve specific stellar
(define-public (approve-stellar-operator (stellar-id uint) (spender principal))
    (let ((navigator (unwrap! (nft-get-owner? stellar-forge stellar-id) err-stellar-not-found)))
        (asserts! (is-eq tx-sender navigator) err-not-stellar-owner)
        (ok (map-set stellar-approvals stellar-id spender))))

;; Set approval for cosmic operator
(define-public (set-cosmic-operator-approval (operator principal) (approved bool))
    (ok (map-set cosmic-operators {navigator: tx-sender, operator: operator} approved)))

;; Obliterate stellar
(define-public (obliterate-stellar (stellar-id uint))
    (let ((navigator (unwrap! (nft-get-owner? stellar-forge stellar-id) err-stellar-not-found)))
        (asserts! (is-eq tx-sender navigator) err-not-stellar-owner)
        (asserts! (not (is-stellar-locked stellar-id)) err-warp-failed)
        (update-navigator-stellar-count navigator -1)
        (map-delete stellar-cosmos stellar-id)
        (map-delete stellar-approvals stellar-id)
        (map-delete stellar-market-value stellar-id)
        (map-delete stellar-locked stellar-id)
        (nft-burn? stellar-forge stellar-id navigator)))

;; Cosmic marketplace functions
(define-public (list-stellar-for-trade (stellar-id uint) (price uint))
    (let ((navigator (unwrap! (nft-get-owner? stellar-forge stellar-id) err-stellar-not-found)))
        (asserts! (is-eq tx-sender navigator) err-not-stellar-owner)
        (asserts! (> price u0) err-invalid-nebula-percentage)
        (ok (map-set stellar-market-value stellar-id price))))

(define-public (delist-stellar-from-trade (stellar-id uint))
    (let ((navigator (unwrap! (nft-get-owner? stellar-forge stellar-id) err-stellar-not-found)))
        (asserts! (is-eq tx-sender navigator) err-not-stellar-owner)
        (ok (map-delete stellar-market-value stellar-id))))

(define-public (acquire-stellar (stellar-id uint))
    (let 
        (
            (navigator (unwrap! (nft-get-owner? stellar-forge stellar-id) err-stellar-not-found))
            (market-price (unwrap! (map-get? stellar-market-value stellar-id) err-stellar-not-found))
            (nebula-fee (calculate-nebula-fee market-price))
            (navigator-payment (- market-price nebula-fee))
        )
        (asserts! (not (is-eq tx-sender navigator)) err-not-stellar-owner)
        (try! (stx-transfer? nebula-fee tx-sender (var-get nebula-vault)))
        (try! (stx-transfer? navigator-payment tx-sender navigator))
        (try! (warp-stellar stellar-id navigator tx-sender))
        (map-delete stellar-market-value stellar-id)
        (ok true)))

;; Architect administration functions

;; Activate/deactivate forge
(define-public (deactivate-forge)
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (ok (var-set forge-active false))))

(define-public (activate-forge)
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (ok (var-set forge-active true))))

;; Set stardust price
(define-public (set-stardust-price (new-price uint))
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (ok (var-set stardust-price new-price))))

;; Cosmic explorer management
(define-public (add-cosmic-explorer (user principal))
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (ok (map-set cosmic-explorers user true))))

(define-public (remove-cosmic-explorer (user principal))
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (ok (map-delete cosmic-explorers user))))

(define-public (batch-add-cosmic-explorers (users (list 50 principal)))
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (ok (map add-cosmic-explorer-helper users))))

;; Lock/unlock stellars
(define-public (lock-stellar (stellar-id uint))
    (let ((navigator (unwrap! (nft-get-owner? stellar-forge stellar-id) err-stellar-not-found)))
        (asserts! (is-eq tx-sender navigator) err-not-stellar-owner)
        (ok (map-set stellar-locked stellar-id true))))

(define-public (unlock-stellar (stellar-id uint))
    (let ((navigator (unwrap! (nft-get-owner? stellar-forge stellar-id) err-stellar-not-found)))
        (asserts! (is-eq tx-sender navigator) err-not-stellar-owner)
        (ok (map-delete stellar-locked stellar-id))))

;; Nebula fee management
(define-public (set-nebula-percentage (new-percentage uint))
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (asserts! (<= new-percentage u2000) err-invalid-nebula-percentage) ;; Max 20%
        (ok (var-set nebula-percentage new-percentage))))

(define-public (set-nebula-vault (new-vault principal))
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (ok (var-set nebula-vault new-vault))))

;; Emergency void extraction
(define-public (emergency-void-extraction)
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (let ((void-balance (stx-get-balance (as-contract tx-sender))))
            (if (> void-balance u0)
                (match (stx-transfer? void-balance (as-contract tx-sender) contract-architect)
                    success (ok void-balance)
                    error (err error))
                (ok u0)))))

;; Set cosmic base URI (only architect, only if cosmos not frozen)
(define-public (set-cosmic-base-uri (new-cosmic-uri (string-ascii 256)))
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (asserts! (not (var-get cosmos-frozen)) err-cosmos-frozen)
        (ok (var-set cosmic-base-uri new-cosmic-uri))))

;; Freeze cosmos metadata (irreversible)
(define-public (freeze-cosmos)
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (ok (var-set cosmos-frozen true))))

;; Update forge limit (only architect)
(define-public (set-forge-limit (new-limit uint))
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (ok (var-set forge-limit new-limit))))

;; Simplified constellation forge - forge multiple stellars to the same navigator
(define-public (forge-constellation (recipient principal) (count uint) (base-designation (string-ascii 50)) (chronicle (string-ascii 256)) (constellation (string-ascii 256)))
    (begin
        (asserts! (is-eq tx-sender contract-architect) err-architect-only)
        (asserts! (<= count u10) err-constellation-size-exceeded)
        (asserts! (<= (+ (var-get last-stellar-id) count) (var-get forge-limit)) err-forge-limit-exceeded)
        (fold constellation-forge-fold (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) {
            recipient: recipient,
            base-designation: base-designation,
            chronicle: chronicle,
            constellation: constellation,
            count: count,
            current: u0,
            success: true
        })
        (ok count)))

(define-private (constellation-forge-fold (n uint) (data {recipient: principal, base-designation: (string-ascii 50), chronicle: (string-ascii 256), constellation: (string-ascii 256), count: uint, current: uint, success: bool}))
    (if (and (get success data) (<= (+ (get current data) u1) (get count data)))
        (let ((stellar-designation (default-to "Stellar" (as-max-len? (concat (get base-designation data) " ") u64))))
            (match (forge-stellar (get recipient data) stellar-designation (get chronicle data) (get constellation data) "")
                success (merge data {current: (+ (get current data) u1)})
                error (merge data {success: false})))
        data))

;; Initialize contract
(begin
    (print "StellarForge NFT contract deployed successfully to the cosmos")
    (print {contract-architect: contract-architect, forge-limit: (var-get forge-limit)}))