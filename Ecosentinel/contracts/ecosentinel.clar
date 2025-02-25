;; EcoSentinel: Secure Decentralized Ecosystem Health Monitoring Contract

(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-data (err u101))
(define-constant err-insufficient-stake (err u102))
(define-constant err-already-verified (err u103))
(define-constant err-invalid-input (err u104))

;; Data submission stake requirement
(define-constant minimum-stake u500)
(define-constant max-data-length u256)
(define-constant max-reward-pool u1000000)

;; Reward pool for data contributors
(define-data-var reward-pool uint u10000)

;; Sensor data structure
(define-map sensor-data 
  { 
    sensor-id: uint, 
    timestamp: uint 
  }
  {
    data-point: (string-utf8 256),
    contributor: principal,
    stake: uint,
    verified: bool
  }
)

;; Verification tracking
(define-map data-verifications
  {
    sensor-id: uint,
    timestamp: uint
  }
  {
    verification-count: uint,
    verified: bool
  }
)

;; Input validation functions
(define-private (is-valid-sensor-id (sensor-id uint))
  (and (> sensor-id u0) (<= sensor-id u10000))
)

(define-private (is-valid-data-point (data-point (string-utf8 256)))
  (and 
    (> (len data-point) u0) 
    (<= (len data-point) max-data-length)
  )
)

;; Register a new environmental sensor
(define-public (register-sensor 
  (sensor-id uint)
  (initial-data (string-utf8 256))
)
  (begin
    ;; Validate inputs
    (asserts! (is-valid-sensor-id sensor-id) err-invalid-input)
    (asserts! (is-valid-data-point initial-data) err-invalid-input)
    
    ;; Check stake
    (asserts! (> (stx-get-balance tx-sender) minimum-stake) err-insufficient-stake)
    
    ;; Store initial sensor data
    (map-set sensor-data 
      { sensor-id: sensor-id, timestamp: block-height }
      {
        data-point: initial-data,
        contributor: tx-sender,
        stake: minimum-stake,
        verified: false
      }
    )
    
    ;; Lock contributor's stake
    (try! (stx-transfer? minimum-stake tx-sender (as-contract tx-sender)))
    
    (ok true)
  )
)

;; Submit environmental data
(define-public (submit-sensor-data
  (sensor-id uint)
  (data-point (string-utf8 256))
)
  (let 
    (
      (current-timestamp block-height)
      (existing-entry 
        (map-get? sensor-data 
          { sensor-id: sensor-id, timestamp: current-timestamp }
        )
    ))
    
    ;; Validate inputs
    (asserts! (is-valid-sensor-id sensor-id) err-invalid-input)
    (asserts! (is-valid-data-point data-point) err-invalid-input)
    
    ;; Prevent duplicate submissions
    (asserts! (is-none existing-entry) err-already-verified)
    
    ;; Require minimum stake
    (asserts! (> (stx-get-balance tx-sender) minimum-stake) err-insufficient-stake)
    
    ;; Store sensor data
    (map-set sensor-data 
      { sensor-id: sensor-id, timestamp: current-timestamp }
      {
        data-point: data-point,
        contributor: tx-sender,
        stake: minimum-stake,
        verified: false
      }
    )
    
    ;; Initialize verification tracking
    (map-set data-verifications
      { sensor-id: sensor-id, timestamp: current-timestamp }
      {
        verification-count: u0,
        verified: false
      }
    )
    
    ;; Lock contributor's stake
    (try! (stx-transfer? minimum-stake tx-sender (as-contract tx-sender)))
    
    (ok true)
  )
)

;; Verify submitted sensor data
(define-public (verify-sensor-data
  (sensor-id uint)
  (timestamp uint)
  (is-valid bool)
)
  (let 
    (
      (verification-entry 
        (unwrap! 
          (map-get? data-verifications 
            { sensor-id: sensor-id, timestamp: timestamp }
          )
          err-invalid-data
        )
      )
      (sensor-entry 
        (unwrap! 
          (map-get? sensor-data 
            { sensor-id: sensor-id, timestamp: timestamp }
          )
          err-invalid-data
        )
      )
    )
    
    ;; Validate inputs
    (asserts! (is-valid-sensor-id sensor-id) err-invalid-input)
    (asserts! (> timestamp u0) err-invalid-input)
    
    ;; Prevent multiple verifications from same contributor
    (asserts! 
      (not (is-eq tx-sender (get contributor sensor-entry))) 
      err-unauthorized
    )
    
    ;; Update verification count
    (map-set data-verifications
      { sensor-id: sensor-id, timestamp: timestamp }
      {
        verification-count: (+ (get verification-count verification-entry) u1),
        verified: (if is-valid 
                    (>= (+ (get verification-count verification-entry) u1) u3)
                    false)
      }
    )
    
    ;; If data is validated, reward contributor and return stake
    (if 
      (and is-valid (>= (+ (get verification-count verification-entry) u1) u3))
      (begin
        ;; Update sensor data as verified
        (map-set sensor-data 
          { sensor-id: sensor-id, timestamp: timestamp }
          (merge sensor-entry { verified: true })
        )
        
        ;; Distribute reward and return stake
        (try! 
          (as-contract 
            (stx-transfer? 
              (+ minimum-stake (/ (var-get reward-pool) u10)) 
              tx-sender 
              (get contributor sensor-entry)
            )
          )
        )
      )
      ;; If invalid, penalize contributor
      (if (not is-valid)
        (try! 
          (as-contract 
            (stx-transfer? 
              (/ minimum-stake u2) 
              tx-sender 
              contract-owner
            )
          )
        )
        true
      )
    )
    
    (ok true)
  )
)

;; Admin function to add to reward pool
(define-public (contribute-to-reward-pool (amount uint))
  (begin
    ;; Validate inputs
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (asserts! (and (> amount u0) (<= amount max-reward-pool)) err-invalid-input)
    
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok true)
  )
)

;; Read-only function to check data verification status
(define-read-only (is-data-verified (sensor-id uint) (timestamp uint))
  (match 
    (map-get? data-verifications { sensor-id: sensor-id, timestamp: timestamp })
    entry (get verified entry)
    false
  )
)