;; Multi-Signature Wallet Contract
;; Requires M-of-N signatures to approve and execute transactions

(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-SIGNATURE (err u2))
(define-constant ERR-ALREADY-SIGNED (err u3))
(define-constant ERR-INSUFFICIENT-SIGNATURES (err u4))
(define-constant ERR-INVALID-THRESHOLD (err u5))
(define-constant ERR-TX-NOT-FOUND (err u6))
(define-constant ERR-MAX-SIGNERS (err u7))
(define-constant ERR-LIST-OVERFLOW (err u8))
(define-constant ERR-NOT-PENDING (err u9))
(define-constant ERR-ALREADY-OWNER (err u10))
(define-constant ERR-NOT-OWNER (err u11))
(define-constant ERR-OWNER-THRESHOLD (err u12))
(define-constant ERR-EXPIRED (err u13))
(define-constant ERR-INVALID-SIG-COUNT (err u14))
(define-constant ERR-TX-ACTIVE (err u15))


;; Data Variables
(define-data-var required-signatures uint u2)  ;; M signatures required
(define-data-var total-owners uint u3)         ;; N total owners

;; Data Maps
(define-map owners principal bool)
(define-map transactions 
    uint 
    {
        recipient: principal,
        amount: uint,
        status: (string-ascii 20),
        signatures: uint,
        signers: (list 20 principal)
    }
)

(define-data-var tx-nonce uint u0)

;; Initialize contract with owners and signature threshold
(define-public (initialize (owners-list (list 20 principal)) (threshold uint))
    (begin
        (asserts! (> threshold u0) ERR-INVALID-THRESHOLD)
        (asserts! (<= threshold (len owners-list)) ERR-INVALID-THRESHOLD)
        (asserts! (< (len owners-list) u20) ERR-INVALID-THRESHOLD)

        (var-set required-signatures threshold)
        (var-set total-owners (len owners-list))

        ;; Register all owners
        (map register-owner owners-list)
        (ok true)
    )
)

;; Helper function to register an owner
(define-private (register-owner (owner principal))
    (map-set owners owner true)
)

;; Submit a new transaction for approval
(define-public (submit-transaction (recipient principal) (amount uint))
    (let
        ((tx-id (var-get tx-nonce)))

        ;; Verify sender is an owner
        (asserts! (is-owner tx-sender) ERR-NOT-AUTHORIZED)

        ;; Create new transaction
        (map-set transactions tx-id {
            recipient: recipient,
            amount: amount,
            status: "pending",
            signatures: u0,
            signers: (list)
        })

        ;; Increment nonce
        (var-set tx-nonce (+ tx-id u1))
        (ok tx-id)
    )
)
