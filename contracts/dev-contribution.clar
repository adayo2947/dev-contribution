;; ----------------------------------------------------------------------------------
;; Contract: proof-of-contribution.clar
;; Description: Mints non-transferable NFTs (SBTs) for developer contributions.
;;              Each NFT contains a hash of a contribution (e.g., GitHub commit).
;;              Only the contract owner can mint tokens.
;; ----------------------------------------------------------------------------------



;; --- Constants ---
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-TRANSFER-BLOCKED (err u101))
(define-constant ERR-TOKEN-NOT-FOUND (err u102))

;; --- Data Variables ---
(define-data-var last-token-id uint u0)
(define-data-var contract-owner principal tx-sender)

;; --- Token Definition ---
(define-non-fungible-token contribution-sbt uint)

;; --- Maps ---
;; token-id => { contributor: principal, hash: string, timestamp: uint }
(define-map contributions
  uint
  { contributor: principal, hash: (string-ascii 64), timestamp: uint }
)

;; ------------------------------------------------------------------------------
;; PUBLIC: Mint a Contribution SBT (Only Contract Owner)
;; ------------------------------------------------------------------------------
(define-public (mint-contribution (recipient principal) (contribution-hash (string-ascii 64)))
  (begin
    ;; Only owner can mint
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)

    ;; Generate next token ID
    (let ((next-id (+ u1 (var-get last-token-id))))
      ;; Mint SBT to recipient
      (try! (nft-mint? contribution-sbt next-id recipient))

      ;; Store metadata
      (map-set contributions next-id {
        contributor: recipient,
        hash: contribution-hash,
        timestamp: stacks-block-height
      })

      ;; Update last token ID
      (var-set last-token-id next-id)

      ;; Log mint event
      (print {
        action: "mint-contribution",
        to: recipient,
        token-id: next-id,
        hash: contribution-hash
      })

      (ok next-id)
    )
  )
)

;; ------------------------------------------------------------------------------
;; SIP-009 NFT Trait: transfer (Disabled  SBT)
;; ------------------------------------------------------------------------------
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    ;; Only token owner can attempt transfer
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)

    ;; But transferring is permanently disabled
    ERR-TRANSFER-BLOCKED
  )
)

;; ------------------------------------------------------------------------------
;; READ-ONLY: Get contribution details for a token ID
;; ------------------------------------------------------------------------------
(define-read-only (get-contribution (token-id uint))
  (match (map-get? contributions token-id)
    details (ok details)
    ERR-TOKEN-NOT-FOUND
  )
)

;; ------------------------------------------------------------------------------
;; READ-ONLY: Get the owner of a contribution NFT
;; ------------------------------------------------------------------------------
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? contribution-sbt token-id))
)

;; ------------------------------------------------------------------------------
;; READ-ONLY: Get the last token ID that was minted
;; ------------------------------------------------------------------------------
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

