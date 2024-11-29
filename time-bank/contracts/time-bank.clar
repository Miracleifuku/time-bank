;; Decentralized Time Banking Smart Contract

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-SERVICE-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-INVALID-INPUT (err u104))

;; Data stores
;; Store user profiles
(define-map user-profiles 
  principal 
  {
    total-credits: uint,
    skills: (list 10 (string-ascii 50)),
    reputation-score: uint
  }
)

;; Store service offerings
(define-map service-offerings 
  uint 
  {
    provider: principal,
    skill-domain: (string-ascii 50),
    hours-offered: uint,
    rate: uint,
    description: (string-ascii 200)
  }
)

;; Store service exchanges
(define-map service-exchanges 
  uint 
  {
    service-id: uint,
    provider: principal,
    recipient: principal,
    hours-exchanged: uint,
    status: (string-ascii 20),
    timestamp: uint
  }
)

;; Next available IDs
(define-data-var next-service-id uint u0)
(define-data-var next-exchange-id uint u0)

;; User Registration
(define-public (register-user (skills (list 10 (string-ascii 50))))
  (begin
    ;; Prevent re-registration
    (asserts! (is-none (map-get? user-profiles tx-sender)) ERR-ALREADY-EXISTS)
    
    ;; Create user profile
    (map-set user-profiles tx-sender {
      total-credits: u0,
      skills: skills,
      reputation-score: u100  ;; Start with neutral reputation
    })
    
    (ok true)
  )
)

;; Add or Update User Skills
(define-public (update-skills (new-skills (list 10 (string-ascii 50))))
  (let 
    ((current-profile (unwrap! (map-get? user-profiles tx-sender) ERR-NOT-AUTHORIZED)))
    
    (map-set user-profiles tx-sender (merge current-profile {
      skills: new-skills
    }))
    
    (ok true)
  )
)

;; Create Service Offering
(define-public (create-service-offering 
  (skill-domain (string-ascii 50)) 
  (hours-offered uint) 
  (description (string-ascii 200))
)
  (let 
    ((service-id (var-get next-service-id))
     (current-profile (unwrap! (map-get? user-profiles tx-sender) ERR-NOT-AUTHORIZED)))
    
    ;; Validate input
    (asserts! (> hours-offered u0) ERR-INVALID-INPUT)
    
    ;; Create service offering
    (map-set service-offerings service-id {
      provider: tx-sender,
      skill-domain: skill-domain,
      hours-offered: hours-offered,
      rate: u1,  ;; 1 credit per hour
      description: description
    })
    
    ;; Increment next service ID
    (var-set next-service-id (+ service-id u1))
    
    (ok service-id)
  )
)

;; Exchange Services
(define-public (exchange-service 
  (service-id uint) 
  (hours-requested uint)
)
  (let 
    ((service (unwrap! (map-get? service-offerings service-id) ERR-SERVICE-NOT-FOUND))
     (recipient-profile (unwrap! (map-get? user-profiles tx-sender) ERR-NOT-AUTHORIZED))
     (provider-profile (unwrap! (map-get? user-profiles (get provider service)) ERR-NOT-AUTHORIZED))
     (exchange-id (var-get next-exchange-id))
     (credits-to-exchange (* hours-requested (get rate service))))
    
    ;; Validate service request
    (asserts! (<= hours-requested (get hours-offered service)) ERR-INVALID-INPUT)
    (asserts! (not (is-eq tx-sender (get provider service))) ERR-NOT-AUTHORIZED)
    
    ;; Record service exchange
    (map-set service-exchanges exchange-id {
      service-id: service-id,
      provider: (get provider service),
      recipient: tx-sender,
      hours-exchanged: hours-requested,
      status: "pending",
      timestamp: block-height
    })
    
    ;; Increment next exchange ID
    (var-set next-exchange-id (+ exchange-id u1))
    
    (ok exchange-id)
  )
)

;; Complete Service Exchange
(define-public (complete-service-exchange 
  (exchange-id uint)
)
  (let 
    ((exchange (unwrap! (map-get? service-exchanges exchange-id) ERR-SERVICE-NOT-FOUND))
     (provider-profile (unwrap! (map-get? user-profiles (get provider exchange)) ERR-NOT-AUTHORIZED))
     (recipient-profile (unwrap! (map-get? user-profiles (get recipient exchange)) ERR-NOT-AUTHORIZED))
     (credits-to-transfer (* (get hours-exchanged exchange) u1)))
    
    ;; Validate that only the provider can complete
    (asserts! (is-eq tx-sender (get provider exchange)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status exchange) "pending") ERR-INVALID-INPUT)
    
    ;; Update profiles with credits
    (map-set user-profiles (get recipient exchange)
      (merge recipient-profile {
        total-credits: (+ (get total-credits recipient-profile) credits-to-transfer)
      })
    )
    
    (map-set user-profiles (get provider exchange)
      (merge provider-profile {
        total-credits: (- (get total-credits provider-profile) credits-to-transfer)
      })
    )
    
    ;; Update exchange status
    (map-set service-exchanges exchange-id
      (merge exchange {
        status: "completed"
      })
    )
    
    (ok true)
  )
)

;; View User Profile (Read-only)
(define-read-only (get-user-profile (user principal))
  (map-get? user-profiles user)
)

;; View Service Offering (Read-only)
(define-read-only (get-service-offering (service-id uint))
  (map-get? service-offerings service-id)
)

;; View Service Exchange (Read-only)
(define-read-only (get-service-exchange (exchange-id uint))
  (map-get? service-exchanges exchange-id)
)