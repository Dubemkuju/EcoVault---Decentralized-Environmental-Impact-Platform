;; EcoVault - Decentralized Environmental Impact Platform
;; A comprehensive blockchain-based sustainability platform that tracks carbon footprint,
;; rewards eco-friendly actions, and builds green communities

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-insufficient-tokens (err u105))
(define-constant err-invalid-measurement (err u106))
(define-constant err-project-not-active (err u107))

;; Token constants
(define-constant token-name "EcoVault Carbon Credit Token")
(define-constant token-symbol "ECT")
(define-constant token-decimals u6)
(define-constant token-max-supply u8000000000000) ;; 8 million tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-carbon-offset u100000000) ;; 100 ECT
(define-constant reward-recycling u40000000) ;; 40 ECT
(define-constant reward-renewable-energy u150000000) ;; 150 ECT
(define-constant reward-tree-planting u80000000) ;; 80 ECT
(define-constant reward-verification u50000000) ;; 50 ECT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-action-id uint u1)
(define-data-var next-project-id uint u1)
(define-data-var next-verification-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Environmental action types
(define-map action-types
  uint
  {
    name: (string-ascii 64),
    category: (string-ascii 32), ;; "transport", "energy", "waste", "conservation"
    carbon-impact-kg: uint, ;; CO2 equivalent reduction in kg
    measurement-unit: (string-ascii 16), ;; "km", "kwh", "kg", "hours"
    difficulty-level: uint, ;; 1-5
    verified: bool
  }
)

;; User environmental profiles
(define-map user-profiles
  principal
  {
    username: (string-ascii 32),
    eco-level: uint, ;; 1-10
    total-actions: uint,
    carbon-saved-kg: uint,
    trees-planted: uint,
    recycling-kg: uint,
    renewable-energy-kwh: uint,
    current-streak: uint,
    reputation-score: uint,
    join-date: uint,
    last-activity: uint
  }
)

;; Environmental actions
(define-map eco-actions
  uint
  {
    user: principal,
    action-type-id: uint,
    quantity: uint, ;; amount in measurement unit
    carbon-saved-kg: uint,
    location: (string-ascii 64),
    notes: (string-ascii 300),
    photo-hash: (optional (buff 32)),
    timestamp: uint,
    verified: bool,
    verifier: (optional principal)
  }
)

;; Green projects
(define-map green-projects
  uint
  {
    creator: principal,
    title: (string-ascii 128),
    description: (string-ascii 500),
    project-type: (string-ascii 32), ;; "reforestation", "solar", "cleanup", "education"
    target-participants: uint,
    current-participants: uint,
    carbon-goal-kg: uint,
    current-carbon-kg: uint,
    start-date: uint,
    end-date: uint,
    location: (string-ascii 64),
    active: bool
  }
)

;; Project participation
(define-map project-participants
  { project-id: uint, participant: principal }
  {
    join-date: uint,
    contribution-actions: uint,
    carbon-contributed-kg: uint,
    role: (string-ascii 32) ;; "participant", "volunteer", "coordinator"
  }
)

;; Carbon footprint tracking
(define-map carbon-footprints
  { user: principal, period: uint } ;; monthly periods
  {
    transport-emissions-kg: uint,
    energy-emissions-kg: uint,
    waste-emissions-kg: uint,
    total-emissions-kg: uint,
    offset-actions-kg: uint,
    net-footprint-kg: uint,
    improvement-percent: uint
  }
)

;; Verification requests
(define-map verification-requests
  uint
  {
    action-id: uint,
    requester: principal,
    verifier: principal,
    status: (string-ascii 16), ;; "pending", "approved", "rejected"
    evidence-notes: (string-ascii 500),
    verification-date: uint,
    confidence-score: uint ;; 1-100
  }
)

;; Eco challenges
(define-map eco-challenges
  uint
  {
    title: (string-ascii 128),
    challenge-type: (string-ascii 32),
    target-value: uint,
    duration-days: uint,
    participants: uint,
    start-date: uint,
    reward-pool: uint,
    active: bool
  }
)

;; Helper function to get or create user profile
(define-private (get-or-create-profile (user principal))
  (match (map-get? user-profiles user)
    profile profile
    {
      username: "",
      eco-level: u1,
      total-actions: u0,
      carbon-saved-kg: u0,
      trees-planted: u0,
      recycling-kg: u0,
      renewable-energy-kwh: u0,
      current-streak: u0,
      reputation-score: u100,
      join-date: stacks-block-height,
      last-activity: stacks-block-height
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (let (
    (sender-balance (default-to u0 (map-get? token-balances sender)))
  )
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    (asserts! (>= sender-balance amount) err-insufficient-tokens)
    (try! (mint-tokens recipient amount))
    (map-set token-balances sender (- sender-balance amount))
    (print {action: "transfer", sender: sender, recipient: recipient, amount: amount, memo: memo})
    (ok true)
  )
)

;; Action type management
(define-public (add-action-type (name (string-ascii 64)) (category (string-ascii 32))
                               (carbon-impact-kg uint) (measurement-unit (string-ascii 16)) (difficulty uint))
  (let (
    (action-type-id (var-get next-action-id))
  )
    (asserts! (> (len name) u0) err-invalid-input)
    (asserts! (> (len category) u0) err-invalid-input)
    (asserts! (> carbon-impact-kg u0) err-invalid-input)
    (asserts! (and (>= difficulty u1) (<= difficulty u5)) err-invalid-input)
    
    (map-set action-types action-type-id {
      name: name,
      category: category,
      carbon-impact-kg: carbon-impact-kg,
      measurement-unit: measurement-unit,
      difficulty-level: difficulty,
      verified: false
    })
    
    (var-set next-action-id (+ action-type-id u1))
    (print {action: "action-type-added", action-type-id: action-type-id, name: name})
    (ok action-type-id)
  )
)

;; Environmental action logging
(define-public (log-eco-action (action-type-id uint) (quantity uint) (location (string-ascii 64))
                              (notes (string-ascii 300)) (photo-hash (optional (buff 32))))
  (let (
    (action-type (unwrap! (map-get? action-types action-type-id) err-not-found))
    (action-id (var-get next-action-id))
    (profile (get-or-create-profile tx-sender))
    (carbon-saved (* quantity (get carbon-impact-kg action-type)))
  )
    (asserts! (> quantity u0) err-invalid-input)
    (asserts! (> (len location) u0) err-invalid-input)
    
    ;; Create action record
    (map-set eco-actions action-id {
      user: tx-sender,
      action-type-id: action-type-id,
      quantity: quantity,
      carbon-saved-kg: carbon-saved,
      location: location,
      notes: notes,
      photo-hash: photo-hash,
      timestamp: stacks-block-height,
      verified: false,
      verifier: none
    })
    
    ;; Update user profile based on action category
    (let (
      (updated-profile 
        (if (is-eq (get category action-type) "transport")
          (merge profile {carbon-saved-kg: (+ (get carbon-saved-kg profile) carbon-saved)})
          (if (is-eq (get category action-type) "waste")
            (merge profile {recycling-kg: (+ (get recycling-kg profile) quantity)})
            (if (is-eq (get category action-type) "energy")
              (merge profile {renewable-energy-kwh: (+ (get renewable-energy-kwh profile) quantity)})
              (if (is-eq (get category action-type) "conservation")
                (merge profile {trees-planted: (+ (get trees-planted profile) quantity)})
                profile)))))
    )
      (map-set user-profiles tx-sender
        (merge updated-profile {
          total-actions: (+ (get total-actions profile) u1),
          current-streak: (+ (get current-streak profile) u1),
          reputation-score: (+ (get reputation-score profile) u5),
          last-activity: stacks-block-height
        })
      )
    )
    
    ;; Award appropriate rewards based on action type
    (let (
      (reward-amount 
        (if (is-eq (get category action-type) "transport")
          reward-carbon-offset
          (if (is-eq (get category action-type) "waste")
            reward-recycling
            (if (is-eq (get category action-type) "energy")
              reward-renewable-energy
              (if (is-eq (get category action-type) "conservation")
                reward-tree-planting
                reward-carbon-offset)))))
    )
      (try! (mint-tokens tx-sender reward-amount))
    )
    
    (var-set next-action-id (+ action-id u1))
    (print {action: "eco-action-logged", action-id: action-id, user: tx-sender, carbon-saved: carbon-saved})
    (ok action-id)
  )
)

;; Green project creation
(define-public (create-green-project (title (string-ascii 128)) (description (string-ascii 500))
                                    (project-type (string-ascii 32)) (target-participants uint)
                                    (carbon-goal-kg uint) (duration-days uint) (location (string-ascii 64)))
  (let (
    (project-id (var-get next-project-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len title) u0) err-invalid-input)
    (asserts! (> (len description) u0) err-invalid-input)
    (asserts! (> target-participants u0) err-invalid-input)
    (asserts! (> carbon-goal-kg u0) err-invalid-input)
    (asserts! (> duration-days u0) err-invalid-input)
    
    (map-set green-projects project-id {
      creator: tx-sender,
      title: title,
      description: description,
      project-type: project-type,
      target-participants: target-participants,
      current-participants: u0,
      carbon-goal-kg: carbon-goal-kg,
      current-carbon-kg: u0,
      start-date: stacks-block-height,
      end-date: (+ stacks-block-height duration-days),
      location: location,
      active: true
    })
    
    ;; Update creator profile
    (map-set user-profiles tx-sender
      (merge profile {
        reputation-score: (+ (get reputation-score profile) u20),
        last-activity: stacks-block-height
      })
    )
    
    (var-set next-project-id (+ project-id u1))
    (print {action: "green-project-created", project-id: project-id, creator: tx-sender})
    (ok project-id)
  )
)

;; Project participation
(define-public (join-green-project (project-id uint) (role (string-ascii 32)))
  (let (
    (project (unwrap! (map-get? green-projects project-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (get active project) err-project-not-active)
    (asserts! (< (get current-participants project) (get target-participants project)) err-invalid-input)
    (asserts! (is-none (map-get? project-participants {project-id: project-id, participant: tx-sender})) err-already-exists)
    
    ;; Add participant
    (map-set project-participants {project-id: project-id, participant: tx-sender} {
      join-date: stacks-block-height,
      contribution-actions: u0,
      carbon-contributed-kg: u0,
      role: role
    })
    
    ;; Update project participant count
    (map-set green-projects project-id
      (merge project {current-participants: (+ (get current-participants project) u1)})
    )
    
    ;; Update user profile
    (map-set user-profiles tx-sender
      (merge profile {
        reputation-score: (+ (get reputation-score profile) u10),
        last-activity: stacks-block-height
      })
    )
    
    (print {action: "green-project-joined", project-id: project-id, participant: tx-sender})
    (ok true)
  )
)

;; Carbon footprint tracking
(define-public (update-carbon-footprint (transport-emissions uint) (energy-emissions uint)
                                       (waste-emissions uint) (offset-actions uint))
  (let (
    (current-period (/ stacks-block-height u4320)) ;; Approximate monthly periods
    (profile (get-or-create-profile tx-sender))
    (total-emissions (+ (+ transport-emissions energy-emissions) waste-emissions))
    (net-footprint (if (>= total-emissions offset-actions) 
                     (- total-emissions offset-actions) 
                     u0))
  )
    (asserts! (> total-emissions u0) err-invalid-input)
    
    (map-set carbon-footprints {user: tx-sender, period: current-period} {
      transport-emissions-kg: transport-emissions,
      energy-emissions-kg: energy-emissions,
      waste-emissions-kg: waste-emissions,
      total-emissions-kg: total-emissions,
      offset-actions-kg: offset-actions,
      net-footprint-kg: net-footprint,
      improvement-percent: u0 ;; Calculate improvement in future versions
    })
    
    ;; Update user profile
    (map-set user-profiles tx-sender (merge profile {last-activity: stacks-block-height}))
    
    ;; Award tokens for tracking footprint
    (try! (mint-tokens tx-sender u20000000)) ;; 20 ECT for tracking
    
    (print {action: "carbon-footprint-updated", user: tx-sender, net-footprint: net-footprint})
    (ok true)
  )
)

;; Verification system
(define-public (verify-eco-action (action-id uint) (confidence-score uint) (evidence-notes (string-ascii 500)))
  (let (
    (eco-action (unwrap! (map-get? eco-actions action-id) err-not-found))
    (verification-id (var-get next-verification-id))
    (verifier-profile (get-or-create-profile tx-sender))
  )
    (asserts! (not (is-eq tx-sender (get user eco-action))) err-unauthorized)
    (asserts! (>= (get reputation-score verifier-profile) u200) err-unauthorized)
    (asserts! (and (>= confidence-score u1) (<= confidence-score u100)) err-invalid-input)
    
    ;; Create verification record
    (map-set verification-requests verification-id {
      action-id: action-id,
      requester: (get user eco-action),
      verifier: tx-sender,
      status: (if (>= confidence-score u70) "approved" "rejected"),
      evidence-notes: evidence-notes,
      verification-date: stacks-block-height,
      confidence-score: confidence-score
    })
    
    ;; Update action verification status
    (if (>= confidence-score u70)
      (map-set eco-actions action-id
        (merge eco-action {
          verified: true,
          verifier: (some tx-sender)
        }))
      true
    )
    
    ;; Award verifier
    (try! (mint-tokens tx-sender reward-verification))
    
    ;; Update verifier reputation
    (map-set user-profiles tx-sender
      (merge verifier-profile {
        reputation-score: (+ (get reputation-score verifier-profile) u8),
        last-activity: stacks-block-height
      })
    )
    
    (var-set next-verification-id (+ verification-id u1))
    (print {action: "eco-action-verified", action-id: action-id, verifier: tx-sender, approved: (>= confidence-score u70)})
    (ok verification-id)
  )
)

;; Read-only functions
(define-read-only (get-user-profile (user principal))
  (map-get? user-profiles user)
)

(define-read-only (get-action-type (action-type-id uint))
  (map-get? action-types action-type-id)
)

(define-read-only (get-eco-action (action-id uint))
  (map-get? eco-actions action-id)
)

(define-read-only (get-green-project (project-id uint))
  (map-get? green-projects project-id)
)

(define-read-only (get-project-participation (project-id uint) (participant principal))
  (map-get? project-participants {project-id: project-id, participant: participant})
)

(define-read-only (get-carbon-footprint (user principal) (period uint))
  (map-get? carbon-footprints {user: user, period: period})
)

(define-read-only (get-verification-request (verification-id uint))
  (map-get? verification-requests verification-id)
)

;; Admin functions
(define-public (verify-action-type (action-type-id uint))
  (let (
    (action-type (unwrap! (map-get? action-types action-type-id) err-not-found))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set action-types action-type-id (merge action-type {verified: true}))
    (print {action: "action-type-verified", action-type-id: action-type-id})
    (ok true)
  )
)

(define-public (update-username (new-username (string-ascii 32)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-username) u0) err-invalid-input)
    (map-set user-profiles tx-sender (merge profile {username: new-username}))
    (print {action: "username-updated", user: tx-sender, username: new-username})
    (ok true)
  )
)