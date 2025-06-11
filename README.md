# Decentralized Logistics Warehouse Automation Networks

A comprehensive blockchain-based system for managing warehouse automation operations using Clarity smart contracts on the Stacks blockchain.

## Overview

This project implements a decentralized network for warehouse automation that includes operator verification, inventory tracking, robot coordination, order fulfillment, and performance optimization. The system ensures transparency, accountability, and efficiency in warehouse operations through smart contracts.

## Features

### 🔐 Warehouse Operator Verification
- Register and verify warehouse automation operators
- Track operator performance scores
- Manage operator status (pending, verified, suspended, revoked)
- Ensure only verified operators can perform critical operations

### 📦 Inventory Tracking
- Real-time inventory management
- Reserve and release inventory for orders
- Track item locations within warehouses
- Monitor inventory levels and availability

### 🤖 Robot Coordination
- Register and manage warehouse automation robots
- Create and assign tasks to robots
- Track robot status and battery levels
- Coordinate robot movements and operations

### 📋 Order Fulfillment
- Create and manage customer orders
- Track order status through fulfillment pipeline
- Assign robots to process orders
- Monitor picking and packing progress

### 📊 Performance Optimization
- Track warehouse performance metrics
- Create optimization rules and alerts
- Calculate efficiency scores
- Monitor trends and performance indicators

## Smart Contracts

### 1. Warehouse Operator Verification (`warehouse-operator-verification.clar`)
Manages the registration and verification of warehouse operators.

**Key Functions:**
- \`register-operator\`: Register a new warehouse operator
- \`verify-operator\`: Verify an operator (owner only)
- \`update-performance-score\`: Update operator performance
- \`is-operator-verified\`: Check if operator is verified

### 2. Inventory Tracking (`inventory-tracking.clar`)
Handles real-time inventory management and tracking.

**Key Functions:**
- \`add-inventory-item\`: Add new inventory items
- \`update-inventory-quantity\`: Update item quantities
- \`reserve-inventory\`: Reserve items for orders
- \`release-reservation\`: Release reserved inventory
- \`get-available-quantity\`: Check available inventory

### 3. Robot Coordination (`robot-coordination.clar`)
Coordinates warehouse automation robots and task assignment.

**Key Functions:**
- \`register-robot\`: Register a new robot
- \`create-task\`: Create automation tasks
- \`assign-task\`: Assign tasks to robots
- \`complete-task\`: Mark tasks as completed
- \`update-robot-status\`: Update robot status

### 4. Order Fulfillment (`order-fulfillment.clar`)
Manages the complete order fulfillment process.

**Key Functions:**
- \`create-order\`: Create new customer orders
- \`add-order-item\`: Add items to orders
- \`start-processing\`: Begin order processing
- \`update-picked-quantity\`: Track picking progress
- \`complete-order\`: Complete order fulfillment

### 5. Performance Optimization (`performance-optimization.clar`)
Optimizes warehouse performance through metrics and rules.

**Key Functions:**
- \`update-metric\`: Update performance metrics
- \`create-optimization-rule\`: Create optimization rules
- \`create-alert\`: Generate performance alerts
- \`calculate-efficiency-score\`: Calculate warehouse efficiency
- \`meets-target\`: Check if metrics meet targets

## Installation

1. Clone the repository:
   \`\`\`bash
   git clone <repository-url>
   cd warehouse-automation-network
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Run tests:
   \`\`\`bash
   npm test
   \`\`\`

## Usage

### Deploying Contracts

Deploy the contracts to the Stacks blockchain in the following order:

1. Warehouse Operator Verification
2. Inventory Tracking
3. Robot Coordination
4. Order Fulfillment
5. Performance Optimization

### Basic Workflow

1. **Register Operators**: Register warehouse operators and verify them
2. **Add Inventory**: Add inventory items to the warehouse system
3. **Register Robots**: Register automation robots for warehouse operations
4. **Create Orders**: Create customer orders with required items
5. **Process Orders**: Assign robots to fulfill orders automatically
6. **Monitor Performance**: Track metrics and optimize operations

## Testing

The project includes comprehensive tests for all smart contracts using Vitest:

\`\`\`bash
# Run all tests
npm test

# Run specific test file
npm test warehouse-operator-verification.test.js
\`\`\`

## Error Codes

### Warehouse Operator Verification
- \`ERR_UNAUTHORIZED (100)\`: Unauthorized access
- \`ERR_OPERATOR_NOT_FOUND (101)\`: Operator not found
- \`ERR_OPERATOR_ALREADY_EXISTS (102)\`: Operator already exists
- \`ERR_INVALID_STATUS (103)\`: Invalid status value

### Inventory Tracking
- \`ERR_UNAUTHORIZED (200)\`: Unauthorized access
- \`ERR_ITEM_NOT_FOUND (201)\`: Inventory item not found
- \`ERR_INSUFFICIENT_QUANTITY (202)\`: Insufficient quantity available
- \`ERR_INVALID_QUANTITY (203)\`: Invalid quantity value

### Robot Coordination
- \`ERR_UNAUTHORIZED (300)\`: Unauthorized access
- \`ERR_ROBOT_NOT_FOUND (301)\`: Robot not found
- \`ERR_INVALID_STATUS (302)\`: Invalid status
- \`ERR_TASK_NOT_FOUND (303)\`: Task not found

### Order Fulfillment
- \`ERR_UNAUTHORIZED (400)\`: Unauthorized access
- \`ERR_ORDER_NOT_FOUND (401)\`: Order not found
- \`ERR_INVALID_STATUS (402)\`: Invalid order status
- \`ERR_INSUFFICIENT_INVENTORY (403)\`: Insufficient inventory

### Performance Optimization
- \`ERR_UNAUTHORIZED (500)\`: Unauthorized access
- \`ERR_METRIC_NOT_FOUND (501)\`: Metric not found
- \`ERR_INVALID_VALUE (502)\`: Invalid metric value

## Architecture

The system follows a modular architecture where each contract handles a specific aspect of warehouse automation:

\`\`\`
┌─────────────────────────────────────────────────────────────┐
│                    Warehouse Automation Network             │
├─────────────────────────────────────────────────────────────┤
│  Operator Verification  │  Inventory Tracking  │  Robot     │
│  - Registration         │  - Real-time tracking│  Coordination│
│  - Verification         │  - Reservations      │  - Task mgmt │
│  - Performance scoring  │  - Location tracking │  - Status    │
├─────────────────────────────────────────────────────────────┤
│  Order Fulfillment     │  Performance Optimization          │
│  - Order processing    │  - Metrics tracking                │
│  - Item picking        │  - Efficiency scoring              │
│  - Status tracking     │  - Alert management                │
└─────────────────────────────────────────────────────────────┘
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Security Considerations

- All critical functions include proper authorization checks
- Input validation is performed on all user inputs
- State changes are atomic and consistent
- Error handling prevents unexpected contract states

## Future Enhancements

- Integration with IoT sensors for real-time data
- Machine learning for predictive maintenance
- Cross-warehouse coordination
- Advanced analytics and reporting
- Mobile applications for operators
