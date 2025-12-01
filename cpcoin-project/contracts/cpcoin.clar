;; title: cpcoin
;; version: 1.0.0
;; summary: A simple fungible token implementation for cpcoin.
;; description: |
;;   cpcoin is a basic fungible token that supports minting, burning,
;;   and transferring balances between principals. The contract deployer
;;   is the token admin and is the only principal allowed to mint
;;   or burn tokens.

;; -----------------------------
;; traits
;; -----------------------------

;; NOTE: Implement the appropriate fungible-token trait here if needed for your
;; deployment environment. The exact trait identifier depends on the network
;; and deployment plan.

;; -----------------------------
;; token definitions & constants
;; -----------------------------

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-OVERFLOW (err u102))

(define-constant TOKEN-NAME "cpcoin")
(define-constant TOKEN-SYMBOL "CPC")
(define-constant TOKEN-DECIMALS u6)

;; The admin is the contract deployer
(define-constant TOKEN-ADMIN tx-sender)

;; -----------------------------
;; data vars & maps
;; -----------------------------

(define-data-var total-supply uint u0)

(define-map balances
  { owner: principal }
  { amount: uint })

;; -----------------------------
;; private helpers
;; -----------------------------

(define-private (is-admin (sender principal))
  (is-eq sender TOKEN-ADMIN))

(define-private (get-balance (owner principal))
  (default-to u0 (get amount (map-get? balances { owner: owner }))))

(define-private (set-balance (owner principal) (amount uint))
  (if (is-eq amount u0)
      (begin
        (map-delete balances { owner: owner })
        true)
      (begin
        (map-set balances { owner: owner } { amount: amount })
        true)))

;; -----------------------------
;; public functions
;; -----------------------------

;; Mint new tokens to a recipient. Only admin may call.
(define-public (mint (recipient principal) (amount uint))
  (begin
    (if (not (is-admin tx-sender))
        ERR-NOT-AUTHORIZED
        (let (
              (current-balance (get-balance recipient))
              (current-supply (var-get total-supply))
             )
          (let (
                (new-balance (+ current-balance amount))
                (new-supply (+ current-supply amount))
               )
            (if (or (< new-balance current-balance)
                    (< new-supply current-supply))
                ERR-OVERFLOW
                (begin
                  (set-balance recipient new-balance)
                  (var-set total-supply new-supply)
                  (ok new-balance))))))))

;; Burn tokens from a holder. Only admin may call.
(define-public (burn (holder principal) (amount uint))
  (begin
    (if (not (is-admin tx-sender))
        ERR-NOT-AUTHORIZED
        (let (
              (current-balance (get-balance holder))
              (current-supply (var-get total-supply))
             )
          (if (< current-balance amount)
              ERR-INSUFFICIENT-BALANCE
              (let (
                    (new-balance (- current-balance amount))
                    (new-supply (- current-supply amount))
                   )
                (begin
                  (set-balance holder new-balance)
                  (var-set total-supply new-supply)
                  (ok new-balance))))))))

;; Transfer tokens from tx-sender to a recipient.
(define-public (transfer (recipient principal) (amount uint))
  (let (
        (sender tx-sender)
        (sender-balance (get-balance tx-sender))
       )
    (if (< sender-balance amount)
        ERR-INSUFFICIENT-BALANCE
        (let (
              (recipient-balance (get-balance recipient))
             )
          (let (
                (new-sender-balance (- sender-balance amount))
                (new-recipient-balance (+ recipient-balance amount))
               )
            (if (< new-recipient-balance recipient-balance)
                ERR-OVERFLOW
                (begin
                  (set-balance sender new-sender-balance)
                  (set-balance recipient new-recipient-balance)
                  (ok amount))))))))

;; -----------------------------
;; read-only functions
;; -----------------------------

(define-read-only (get-total-supply)
  (var-get total-supply))

(define-read-only (get-balance-of (owner principal))
  (get-balance owner))

(define-read-only (get-token-info)
  {
    name: TOKEN-NAME,
    symbol: TOKEN-SYMBOL,
    decimals: TOKEN-DECIMALS,
    total-supply: (var-get total-supply),
    admin: TOKEN-ADMIN
  })
