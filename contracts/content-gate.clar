;; Content Gate Contract

;; Error codes
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_CONTENT (err u101))
(define-constant ERR_ALREADY_PUBLISHED (err u102))
(define-constant ERR_INSUFFICIENT_TOKENS (err u103))

;; Data variables
(define-data-var min-tokens uint u100)
(define-data-var token-address principal 'SP000000000000000000002Q6VF78.token)

;; Content storage maps
(define-map contents { content-id: uint } { 
    creator: principal,
    hash: (string-ascii 64),
    price: uint,
    is-active: bool
})

(define-map user-access { user: principal, content-id: uint } { access: bool })

;; Read only functions
(define-read-only (can-access-content (user principal) (content-id uint))
    (let (
        (access (default-to { access: false } 
            (map-get? user-access { user: user, content-id: content-id })))
    )
    (ok (get access access))
    )
)

(define-read-only (get-content (content-id uint))
    (ok (map-get? contents { content-id: content-id }))
)

(define-read-only (get-min-tokens)
    (ok (var-get min-tokens))
)

;; Public functions
(define-public (publish-content (content-id uint) (content-hash (string-ascii 64)) (price uint))
    (let ((existing-content (map-get? contents { content-id: content-id })))
        (asserts! (is-none existing-content) ERR_ALREADY_PUBLISHED)
        (ok (map-set contents { content-id: content-id }
            { 
                creator: tx-sender,
                hash: content-hash,
                price: price,
                is-active: true
            }))
    )
)

(define-public (purchase-access (content-id uint))
    (let (
        (content (unwrap! (map-get? contents { content-id: content-id }) ERR_INVALID_CONTENT))
        (token-balance (unwrap! (contract-call? .token get-balance tx-sender) ERR_UNAUTHORIZED))
    )
        (asserts! (>= token-balance (var-get min-tokens)) ERR_INSUFFICIENT_TOKENS)
        (asserts! (get is-active content) ERR_INVALID_CONTENT)
        
        (ok (map-set user-access 
            { user: tx-sender, content-id: content-id }
            { access: true }))
    )
)

(define-public (update-min-tokens (new-minimum uint))
    (begin
        (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
        (ok (var-set min-tokens new-minimum))
    )
)
