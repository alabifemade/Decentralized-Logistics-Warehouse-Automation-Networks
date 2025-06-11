;; Order Fulfillment Contract
;; Manages automated order fulfillment

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_ORDER_NOT_FOUND (err u401))
(define-constant ERR_INVALID_STATUS (err u402))
(define-constant ERR_INSUFFICIENT_INVENTORY (err u403))

;; Order status constants
(define-constant ORDER_STATUS_PENDING u0)
(define-constant ORDER_STATUS_PROCESSING u1)
(define-constant ORDER_STATUS_PICKING u2)
(define-constant ORDER_STATUS_PACKING u3)
(define-constant ORDER_STATUS_SHIPPED u4)
(define-constant ORDER_STATUS_DELIVERED u5)
(define-constant ORDER_STATUS_CANCELLED u6)

;; Data structures
(define-map orders
  { order-id: uint }
  {
    customer-address: principal,
    warehouse-id: uint,
    status: uint,
    created-at: uint,
    total-items: uint,
    priority: uint,
    assigned-robot: (optional uint),
    estimated-completion: (optional uint)
  }
)

(define-map order-items
  { order-id: uint, item-index: uint }
  {
    item-id: uint,
    quantity: uint,
    picked-quantity: uint
  }
)

(define-data-var next-order-id uint u1)

;; Create new order
(define-public (create-order
  (customer-address principal)
  (warehouse-id uint)
  (priority uint))
  (let ((order-id (var-get next-order-id)))
    (map-set orders
      { order-id: order-id }
      {
        customer-address: customer-address,
        warehouse-id: warehouse-id,
        status: ORDER_STATUS_PENDING,
        created-at: block-height,
        total-items: u0,
        priority: priority,
        assigned-robot: none,
        estimated-completion: none
      }
    )
    (var-set next-order-id (+ order-id u1))
    (ok order-id)
  )
)

;; Add item to order
(define-public (add-order-item
  (order-id uint)
  (item-id uint)
  (quantity uint))
  (match (map-get? orders { order-id: order-id })
    order-data
    (let ((item-index (get total-items order-data)))
      (map-set order-items
        { order-id: order-id, item-index: item-index }
        {
          item-id: item-id,
          quantity: quantity,
          picked-quantity: u0
        }
      )
      (map-set orders
        { order-id: order-id }
        (merge order-data { total-items: (+ item-index u1) })
      )
      (ok true)
    )
    ERR_ORDER_NOT_FOUND
  )
)

;; Start order processing
(define-public (start-processing (order-id uint) (robot-id uint))
  (match (map-get? orders { order-id: order-id })
    order-data
    (begin
      (asserts! (is-eq (get status order-data) ORDER_STATUS_PENDING) ERR_INVALID_STATUS)
      (map-set orders
        { order-id: order-id }
        (merge order-data {
          status: ORDER_STATUS_PROCESSING,
          assigned-robot: (some robot-id),
          estimated-completion: (some (+ block-height u100))
        })
      )
      (ok true)
    )
    ERR_ORDER_NOT_FOUND
  )
)

;; Update order status
(define-public (update-order-status (order-id uint) (new-status uint))
  (match (map-get? orders { order-id: order-id })
    order-data
    (begin
      (map-set orders
        { order-id: order-id }
        (merge order-data { status: new-status })
      )
      (ok true)
    )
    ERR_ORDER_NOT_FOUND
  )
)

;; Update picked quantity for order item
(define-public (update-picked-quantity
  (order-id uint)
  (item-index uint)
  (picked-quantity uint))
  (match (map-get? order-items { order-id: order-id, item-index: item-index })
    item-data
    (begin
      (map-set order-items
        { order-id: order-id, item-index: item-index }
        (merge item-data { picked-quantity: picked-quantity })
      )
      (ok true)
    )
    ERR_ORDER_NOT_FOUND
  )
)

;; Complete order
(define-public (complete-order (order-id uint))
  (match (map-get? orders { order-id: order-id })
    order-data
    (begin
      (map-set orders
        { order-id: order-id }
        (merge order-data {
          status: ORDER_STATUS_DELIVERED,
          assigned-robot: none
        })
      )
      (ok true)
    )
    ERR_ORDER_NOT_FOUND
  )
)

;; Get order info
(define-read-only (get-order (order-id uint))
  (map-get? orders { order-id: order-id })
)

;; Get order item
(define-read-only (get-order-item (order-id uint) (item-index uint))
  (map-get? order-items { order-id: order-id, item-index: item-index })
)

;; Check if order is complete
(define-read-only (is-order-complete (order-id uint))
  (match (map-get? orders { order-id: order-id })
    order-data
    (>= (get status order-data) ORDER_STATUS_DELIVERED)
    false
  )
)
