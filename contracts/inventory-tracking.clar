;; Inventory Tracking Contract
;; Tracks warehouse inventory in real-time

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_ITEM_NOT_FOUND (err u201))
(define-constant ERR_INSUFFICIENT_QUANTITY (err u202))
(define-constant ERR_INVALID_QUANTITY (err u203))

;; Data structures
(define-map inventory-items
  { warehouse-id: uint, item-id: uint }
  {
    name: (string-ascii 50),
    quantity: uint,
    reserved-quantity: uint,
    location: (string-ascii 20),
    last-updated: uint,
    operator-id: uint
  }
)

(define-map warehouse-operators
  { warehouse-id: uint }
  { operator-id: uint }
)

(define-data-var next-item-id uint u1)

;; Add new inventory item
(define-public (add-inventory-item
  (warehouse-id uint)
  (name (string-ascii 50))
  (quantity uint)
  (location (string-ascii 20))
  (operator-id uint))
  (let ((item-id (var-get next-item-id)))
    (map-set inventory-items
      { warehouse-id: warehouse-id, item-id: item-id }
      {
        name: name,
        quantity: quantity,
        reserved-quantity: u0,
        location: location,
        last-updated: block-height,
        operator-id: operator-id
      }
    )
    (var-set next-item-id (+ item-id u1))
    (ok item-id)
  )
)

;; Update inventory quantity
(define-public (update-inventory-quantity
  (warehouse-id uint)
  (item-id uint)
  (new-quantity uint)
  (operator-id uint))
  (match (map-get? inventory-items { warehouse-id: warehouse-id, item-id: item-id })
    item-data
    (begin
      (map-set inventory-items
        { warehouse-id: warehouse-id, item-id: item-id }
        (merge item-data {
          quantity: new-quantity,
          last-updated: block-height,
          operator-id: operator-id
        })
      )
      (ok true)
    )
    ERR_ITEM_NOT_FOUND
  )
)

;; Reserve inventory for order
(define-public (reserve-inventory
  (warehouse-id uint)
  (item-id uint)
  (reserve-quantity uint))
  (match (map-get? inventory-items { warehouse-id: warehouse-id, item-id: item-id })
    item-data
    (let ((available-quantity (- (get quantity item-data) (get reserved-quantity item-data))))
      (asserts! (>= available-quantity reserve-quantity) ERR_INSUFFICIENT_QUANTITY)
      (map-set inventory-items
        { warehouse-id: warehouse-id, item-id: item-id }
        (merge item-data {
          reserved-quantity: (+ (get reserved-quantity item-data) reserve-quantity),
          last-updated: block-height
        })
      )
      (ok true)
    )
    ERR_ITEM_NOT_FOUND
  )
)

;; Release reserved inventory
(define-public (release-reservation
  (warehouse-id uint)
  (item-id uint)
  (release-quantity uint))
  (match (map-get? inventory-items { warehouse-id: warehouse-id, item-id: item-id })
    item-data
    (begin
      (asserts! (>= (get reserved-quantity item-data) release-quantity) ERR_INSUFFICIENT_QUANTITY)
      (map-set inventory-items
        { warehouse-id: warehouse-id, item-id: item-id }
        (merge item-data {
          reserved-quantity: (- (get reserved-quantity item-data) release-quantity),
          last-updated: block-height
        })
      )
      (ok true)
    )
    ERR_ITEM_NOT_FOUND
  )
)

;; Get inventory item
(define-read-only (get-inventory-item (warehouse-id uint) (item-id uint))
  (map-get? inventory-items { warehouse-id: warehouse-id, item-id: item-id })
)

;; Get available quantity
(define-read-only (get-available-quantity (warehouse-id uint) (item-id uint))
  (match (map-get? inventory-items { warehouse-id: warehouse-id, item-id: item-id })
    item-data
    (some (- (get quantity item-data) (get reserved-quantity item-data)))
    none
  )
)
