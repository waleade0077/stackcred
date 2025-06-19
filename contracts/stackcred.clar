;; CreditScore structure: (tuple (repayment uint) (staking uint) (nft uint) (dao uint) (total uint) (last-updated uint))

;; Config type definition as a tuple
(define-data-var config (tuple (repayment-weight uint) (staking-weight uint) (nft-weight uint) (dao-weight uint))
    (tuple 
        (repayment-weight u25)
        (staking-weight u25)
        (nft-weight u25)
        (dao-weight u25)))

(define-map credit-scores 
    principal 
    (tuple (repayment uint) (staking uint) (nft uint) (dao uint) (total uint) (last-updated uint)))

(define-data-var admin principal tx-sender)
(define-map loan-history principal (list 100 uint))
(define-map score-nfts principal bool)

(define-private (calculate-total-score (score (tuple (repayment uint) (staking uint) (nft uint) (dao uint) (total uint) (last-updated uint))))
  (let (
    (cfg (var-get config))
    (r (* (get repayment score) (get repayment-weight cfg)))
    (s (* (get staking score) (get staking-weight cfg)))
    (n (* (get nft score) (get nft-weight cfg)))
    (d (* (get dao score) (get dao-weight cfg)))
  )
    (+ r (+ s (+ n d)))
  )
)

;; Safe update helper function
(define-private (safe-update-score (user principal) (new-score (tuple (repayment uint) (staking uint) (nft uint) (dao uint) (total uint) (last-updated uint))))
  (begin
    (ok (map-set credit-scores user new-score))))

(define-public (update-score (user principal) (repayment uint) (staking uint) (nft uint) (dao uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (let (
      (existing (default-to 
        (tuple (repayment u0) (staking u0) (nft u0) (dao u0) (total u0) (last-updated u0))
        (map-get? credit-scores user)))
      (updated (tuple
        (repayment (+ (get repayment existing) repayment))
        (staking (+ (get staking existing) staking))
        (nft (+ (get nft existing) nft))
        (dao (+ (get dao existing) dao))
        (total u0)
        (last-updated burn-block-height)))
      (new-total (calculate-total-score updated))
      (final-score (merge updated (tuple (total new-total))))
    )
      (map-set credit-scores user final-score)
      (ok new-total)
    )
  )
)

(define-public (mint-score-nft)
  (begin
    (asserts! (not (default-to false (map-get? score-nfts tx-sender))) (err u409))
    (map-set score-nfts tx-sender true)
    (ok "Score NFT minted")
  )
)

(define-read-only (get-user-score (user principal))
  (ok (map-get? credit-scores user))
)

(define-read-only (get-score-tier (user principal))
  (match (map-get? credit-scores user)
    score
      (let ((t (get total score)))
        (if (>= t u1000)
          (ok "Platinum")
          (if (>= t u750)
            (ok "Gold")
            (if (>= t u500)
              (ok "Silver")
              (ok "Bronze")))))
    (err u404))
)

(define-public (update-weights (repayment-weight uint) (staking-weight uint) (nft-weight uint) (dao-weight uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set config (tuple
      (repayment-weight repayment-weight)
      (staking-weight staking-weight)
      (nft-weight nft-weight)
      (dao-weight dao-weight)))
    (ok "Weights updated")
  )
)

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok "Admin transferred")
  )
)

(define-read-only (snapshot-score (user principal))
  (match (map-get? credit-scores user)
    score
      (ok (get total score))
    (err u404))
)

(define-public (reset-score (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-delete credit-scores user)
    (map-delete score-nfts user)
    (ok "Score reset")
  )
)

;; Safe admin update helper function
;; Safe admin update helper function
(define-private (safe-update-admin (new-admin principal))
  (begin
    (ok (var-set admin new-admin))))
;; Safe map delete helper function
(define-private (safe-delete-user-data (user principal))
  (begin
    (map-delete credit-scores user)
    (map-delete score-nfts user)
    (ok true)))