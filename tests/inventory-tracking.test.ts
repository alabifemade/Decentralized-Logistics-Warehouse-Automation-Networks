import { describe, it, expect, beforeEach } from "vitest"

// Mock contract state
const mockContract = {
  inventoryItems: new Map(),
  nextItemId: 1,
}

// Mock functions
function addInventoryItem(warehouseId, name, quantity, location, operatorId) {
  const itemId = mockContract.nextItemId
  const key = `${warehouseId}-${itemId}`
  
  const itemData = {
    name,
    quantity,
    reservedQuantity: 0,
    location,
    lastUpdated: 100, // mock block height
    operatorId,
  }
  
  mockContract.inventoryItems.set(key, itemData)
  mockContract.nextItemId++
  
  return { success: itemId }
}

function updateInventoryQuantity(warehouseId, itemId, newQuantity, operatorId) {
  const key = `${warehouseId}-${itemId}`
  const item = mockContract.inventoryItems.get(key)
  
  if (!item) {
    return { error: "ERR_ITEM_NOT_FOUND" }
  }
  
  item.quantity = newQuantity
  item.lastUpdated = 101
  item.operatorId = operatorId
  mockContract.inventoryItems.set(key, item)
  
  return { success: true }
}

function reserveInventory(warehouseId, itemId, reserveQuantity) {
  const key = `${warehouseId}-${itemId}`
  const item = mockContract.inventoryItems.get(key)
  
  if (!item) {
    return { error: "ERR_ITEM_NOT_FOUND" }
  }
  
  const availableQuantity = item.quantity - item.reservedQuantity
  if (availableQuantity < reserveQuantity) {
    return { error: "ERR_INSUFFICIENT_QUANTITY" }
  }
  
  item.reservedQuantity += reserveQuantity
  item.lastUpdated = 102
  mockContract.inventoryItems.set(key, item)
  
  return { success: true }
}

function releaseReservation(warehouseId, itemId, releaseQuantity) {
  const key = `${warehouseId}-${itemId}`
  const item = mockContract.inventoryItems.get(key)
  
  if (!item) {
    return { error: "ERR_ITEM_NOT_FOUND" }
  }
  
  if (item.reservedQuantity < releaseQuantity) {
    return { error: "ERR_INSUFFICIENT_QUANTITY" }
  }
  
  item.reservedQuantity -= releaseQuantity
  item.lastUpdated = 103
  mockContract.inventoryItems.set(key, item)
  
  return { success: true }
}

function getInventoryItem(warehouseId, itemId) {
  const key = `${warehouseId}-${itemId}`
  return mockContract.inventoryItems.get(key) || null
}

function getAvailableQuantity(warehouseId, itemId) {
  const item = getInventoryItem(warehouseId, itemId)
  return item ? item.quantity - item.reservedQuantity : null
}

describe("Inventory Tracking Contract", () => {
  beforeEach(() => {
    mockContract.inventoryItems.clear()
    mockContract.nextItemId = 1
  })
  
  describe("add-inventory-item", () => {
    it("should add new inventory item successfully", () => {
      const result = addInventoryItem(1, "Widget A", 100, "A1-B2", 1)
      
      expect(result.success).toBe(1)
      
      const item = getInventoryItem(1, 1)
      expect(item).toBeTruthy()
      expect(item.name).toBe("Widget A")
      expect(item.quantity).toBe(100)
      expect(item.reservedQuantity).toBe(0)
      expect(item.location).toBe("A1-B2")
    })
    
    it("should increment item ID for multiple items", () => {
      const result1 = addInventoryItem(1, "Widget A", 100, "A1-B2", 1)
      const result2 = addInventoryItem(1, "Widget B", 50, "A2-B3", 1)
      
      expect(result1.success).toBe(1)
      expect(result2.success).toBe(2)
    })
  })
  
  describe("update-inventory-quantity", () => {
    it("should update quantity successfully", () => {
      addInventoryItem(1, "Widget A", 100, "A1-B2", 1)
      
      const result = updateInventoryQuantity(1, 1, 150, 1)
      expect(result.success).toBe(true)
      
      const item = getInventoryItem(1, 1)
      expect(item.quantity).toBe(150)
    })
    
    it("should fail for non-existent item", () => {
      const result = updateInventoryQuantity(1, 999, 150, 1)
      expect(result.error).toBe("ERR_ITEM_NOT_FOUND")
    })
  })
  
  describe("reserve-inventory", () => {
    it("should reserve inventory successfully", () => {
      addInventoryItem(1, "Widget A", 100, "A1-B2", 1)
      
      const result = reserveInventory(1, 1, 30)
      expect(result.success).toBe(true)
      
      const item = getInventoryItem(1, 1)
      expect(item.reservedQuantity).toBe(30)
      
      const available = getAvailableQuantity(1, 1)
      expect(available).toBe(70)
    })
    
    it("should fail when insufficient quantity available", () => {
      addInventoryItem(1, "Widget A", 100, "A1-B2", 1)
      
      const result = reserveInventory(1, 1, 150)
      expect(result.error).toBe("ERR_INSUFFICIENT_QUANTITY")
    })
    
    it("should handle multiple reservations", () => {
      addInventoryItem(1, "Widget A", 100, "A1-B2", 1)
      
      reserveInventory(1, 1, 30)
      const result = reserveInventory(1, 1, 20)
      
      expect(result.success).toBe(true)
      
      const item = getInventoryItem(1, 1)
      expect(item.reservedQuantity).toBe(50)
    })
  })
  
  describe("release-reservation", () => {
    it("should release reservation successfully", () => {
      addInventoryItem(1, "Widget A", 100, "A1-B2", 1)
      reserveInventory(1, 1, 30)
      
      const result = releaseReservation(1, 1, 10)
      expect(result.success).toBe(true)
      
      const item = getInventoryItem(1, 1)
      expect(item.reservedQuantity).toBe(20)
    })
    
    it("should fail when trying to release more than reserved", () => {
      addInventoryItem(1, "Widget A", 100, "A1-B2", 1)
      reserveInventory(1, 1, 30)
      
      const result = releaseReservation(1, 1, 50)
      expect(result.error).toBe("ERR_INSUFFICIENT_QUANTITY")
    })
  })
  
  describe("get-available-quantity", () => {
    it("should calculate available quantity correctly", () => {
      addInventoryItem(1, "Widget A", 100, "A1-B2", 1)
      reserveInventory(1, 1, 25)
      
      const available = getAvailableQuantity(1, 1)
      expect(available).toBe(75)
    })
    
    it("should return null for non-existent item", () => {
      const available = getAvailableQuantity(1, 999)
      expect(available).toBeNull()
    })
  })
})
