# Product Requirement Document: QR Query (Q2) - QR-based Ordering System

**Product Name:** QR Query (Q2)  
**Document Type:** Product Requirement Document  
**Current Scope:** Single school, single seller/store  
**Status:** Draft

## 1. Product Overview

QR Query (Q2) is a QR-based ordering system designed for a school cafeteria. Customers can scan a QR code from their table, enter their name, browse the available menu, customize items, place an order, pay at the counter, and track the order until pickup.

The system provides separate interfaces and responsibilities for the **Customer**, **Seller**, and **Administrator**. The current deployment scope supports one school and one seller/store in accordance with the school's operating policy.

## 2. Problem Statement

Students in the school canteen often experience long queues and incorrect product orders. These issues can cause frustration, wasted time, and a poor dining experience, especially during peak hours.

The existing manual ordering process requires students to approach the counter to place orders and relies on verbal communication, making it more difficult to maintain accurate orders and efficiently manage customer demand.

Q2 addresses this by moving the ordering process to a digital system while retaining payment at the counter.

## 3. Scope

### 3.1 Current Scope

The system supports:

- One school
- One active seller/store
- QR codes placed at cafeteria tables
- Customer ordering without requiring a customer account
- Seller account managed by an administrator
- Menu and product management
- Inventory quantity management
- Order placement and tracking
- Manual payment confirmation at the counter
- Receipts after completed orders
- Order cancellation and refund handling
- Seller schedule management
- Administrative seller account management

### 3.2 Scope Constraints

- The current system does not support multiple active stores.
- A customer order is associated with the single active store.
- The initial payment method is payment at the counter.
- Customer accounts are not required for placing orders.
- Electronic payment processing is not currently defined.

## 4. User Roles

### 4.1 Customer

The customer is a student or other cafeteria customer who uses the ordering interface to:

- Scan the store QR code
- Enter their name
- Browse and search the menu
- Customize products
- Add products to a cart
- Submit an order
- Pay at the counter
- View order status
- Receive notification when the order is ready
- View the receipt after completing the purchase
- Start another order using the same customer name

### 4.2 Seller

The seller operates the cafeteria/store and can:

- Manage store information
- Manage products, prices, descriptions, images, and quantities
- Manage product availability
- Manage store schedule
- View incoming orders
- Confirm customer payments
- Prepare orders
- Change order status
- Cancel orders with a visible reason
- Handle product unavailability during preparation
- Complete orders after customer pickup
- View transaction history and store/order information

### 4.3 Administrator

The administrator manages the seller account and can:

- Review seller account requests
- Communicate with prospective sellers through the account-request process
- Create and manage the seller account
- Deactivate the seller account when applicable conditions are met
- Monitor seller-related system information

## 5. Goals & Success Metrics

### 5.1 Goals

1. Reduce customer queue wait times.
2. Decrease order inaccuracies.
3. Improve the overall dining experience.
4. Increase customer satisfaction.
5. Provide sellers with a more organized method of receiving and processing orders.

### 5.2 Success Metrics

1. **Average Queue Wait Time** - Measure the time customers spend waiting to place an order compared with the existing manual process.
2. **Order Accuracy Rate** - Measure the proportion of orders prepared without customer-reported ordering errors.
3. **Customer Satisfaction** - Measure customer feedback regarding the ordering experience.
4. **User Adoption Rate** - Measure the proportion of customers using Q2 for supported cafeteria orders.

Specific target values should be established during system validation and deployment planning.

## 6. User Stories

### 6.1 Customer Stories

1. **As a customer**, I want to scan a QR code at my table so that I can access the cafeteria menu without first going to the counter.
2. **As a customer**, I want to enter my name so that the seller can identify my order.
3. **As a customer**, I want to browse, search, and filter menu items so that I can find products efficiently.
4. **As a customer**, I want to customize my order so that I can select available add-ons, removals, substitutions, and special instructions.
5. **As a customer**, I want to review my order before submitting it so that I can verify the items and total.
6. **As a customer**, I want to pay at the counter and have the seller confirm the payment so that my order can proceed to preparation.
7. **As a customer**, I want to track my order status so that I know whether it is pending payment, being prepared, ready, or completed.
8. **As a customer**, I want to receive a notification when my order is ready so that I know when to collect it.
9. **As a customer**, I want to see the reason when the seller cancels my order so that I understand what happened.
10. **As a customer**, I want to view my receipt after completing my purchase so that I can review what I ordered.
11. **As a customer**, I want to start a new order after completing an order without re-entering my name.

### 6.2 Seller Stories

1. **As a seller**, I want to manage my store information so that customers see current store details.
2. **As a seller**, I want to add, edit, and remove products so that the menu remains current.
3. **As a seller**, I want to manage product quantities so that unavailable products cannot continue to be ordered.
4. **As a seller**, I want products to become unavailable when their remaining quantity reaches zero.
5. **As a seller**, I want to manage my store schedule so that customers know when ordering is available.
6. **As a seller**, I want to receive and view incoming orders so that I can prepare them accurately.
7. **As a seller**, I want to confirm payments so that paid orders can proceed to preparation.
8. **As a seller**, I want to update order status so that customers can track their orders.
9. **As a seller**, I want to cancel an order with a reason so that customers are informed when an order cannot continue.
10. **As a seller**, I want to mark a product unavailable during preparation when stock is insufficient so that the order and receipt reflect the actual items provided.
11. **As a seller**, I want to view transaction history so that completed and cancelled orders can be reviewed.
12. **As a seller**, I want to mark an order completed after pickup so that the order lifecycle is finalized.

### 6.3 Administrator Stories

1. **As an administrator**, I want to manage seller accounts so that only authorized sellers can operate the store.
2. **As an administrator**, I want to review seller requests so that seller access can be approved appropriately.
3. **As an administrator**, I want to send the seller request process through email so that prospective sellers can complete the required information.
4. **As an administrator**, I want to deactivate a seller account when defined administrative conditions are met.

## 7. Core System Workflows

### 7.1 Customer Ordering Workflow

1. Customer chooses the **Customer** option.
2. Customer chooses **Scan QR**.
3. Customer scans the QR code available at a cafeteria table.
4. System identifies the active store.
5. Customer enters their name; name is required.
6. Customer browses, searches, and filters the menu.
7. Customer selects products and applies available customizations.
8. Customer adds the selected products to the cart.
9. Customer proceeds to checkout.
10. System displays an order summary and total.
11. Customer confirms the checkout/order.
12. Order is created with **Pending Payment** status.
13. Customer pays at the counter.
14. Seller confirms the payment.
15. Order changes to **Paid**.
16. Seller prepares the order.
17. Order changes to **Ready for Pickup** when preparation is complete.
18. Customer receives the ready notification.
19. Customer picks up the order.
20. Seller marks the order **Completed**.
21. Customer can view the receipt, exit the application, or start a new order using the same customer name.

### 7.2 Seller Order Workflow

1. Seller receives a new order.
2. Seller checks the order and confirms the customer's payment.
3. Order becomes **Paid**.
4. Seller changes the order to **Preparing**.
5. Seller prepares the requested products.
6. If an ordered product is unavailable during preparation, the seller marks that product unavailable for the order.
7. The affected product line appears on the receipt with no charge (zero price).
8. The corresponding product amount is recorded for refund handling after preparation.
9. Seller marks the order **Ready for Pickup**.
10. Customer collects the order.
11. Seller marks the order **Completed**.
12. Completed and cancelled orders remain available through transaction history.

### 7.3 Seller Cancellation Workflow

A seller may cancel an order when the order cannot continue. A cancellation must include a reason visible to the customer.

Example reasons include:

- Insufficient payment
- Customer refuses to pay
- Other seller-defined cancellation reasons

### 7.4 Customer Cancellation Workflow

- Before the checkout/order is confirmed, the customer may change their decision and leave without completing the order.
- After the checkout/order is confirmed, the customer cannot directly cancel the order through the customer interface.
- The customer must ask the seller to cancel the confirmed order.

### 7.5 Seller Registration and Account Workflow

1. A prospective seller requests an account from the administrator.
2. The administrator sends an automated email containing a dedicated website.
3. The website provides the required seller questionnaire.
4. The completed questionnaire is returned to the administrator.
5. The administrator reviews and confirms the request.
6. The administrator creates the seller account when approved.
7. The approved seller can access the seller dashboard.

The automated questionnaire website and email workflow is a planned system capability and may be implemented as the account-registration process is finalized.

## 8. Functional Requirements

### FR-01. Seller Account Management

- Sellers shall request access through the administrator.
- The administrator shall create the seller account after approval.
- Sellers shall only access their authorized seller dashboard.
- The administrator shall be able to manage the seller account.
- The administrator shall be able to deactivate the seller account under defined conditions.

### FR-02. Store Management

- The seller shall manage store information.
- The seller shall manage store operating schedule.
- The system shall support one active store under the current school scope.

### FR-03. QR Code Access

- The system shall provide a single static QR code for the active store.
- The same store QR code is placed across cafeteria tables as an easy way for customers to access the store menu without approaching the counter.
- The store QR code remains permanent and valid throughout the seller's operational lifetime, resetting/invalidating only if the seller's account is deactivated by an administrator.
- Customers may scan the table QR code directly through the app or device camera.

### FR-04. Customer Identification

- Customers shall not be required to create an account to place an order.
- Customers shall enter a name before browsing or ordering.
- The entered customer name shall be associated with the order.
- A completed customer session may start another order using the same customer name.

### FR-05. Menu Access

- The system shall display product names, descriptions, prices, images, and availability.
- Customers shall be able to search for products.
- Customers shall be able to filter products.

### FR-06. Product Customization

- The system shall support available product customization options.
- Customization may include add-ons, removals, substitutions, and special instructions.
- The final order total shall reflect applicable product/customization prices.

### FR-07. Cart and Checkout

- Customers shall be able to add products to a cart.
- Customers shall be able to review and modify the cart before checkout confirmation.
- The system shall display the order summary and total before confirmation.
- Once the customer confirms checkout, the order shall be created as **Pending Payment**.

### FR-08. Payment

- Customers shall pay at the seller's counter.
- The seller shall confirm whether payment has been received.
- After confirmation, the order shall change from **Pending Payment** to **Paid**.
- Manual payment may include giving change where applicable.
- Electronic payment processing is not included in the current payment scope.

### FR-09. Order Status and Tracking

The primary order lifecycle shall use these statuses:

1. **Pending Payment**
2. **Paid**
3. **Preparing**
4. **Ready for Pickup**
5. **Completed**
6. **Cancelled**

- The seller shall control order status changes.
- Customers shall be able to view the current status of their order.
- The system shall notify customers when an order becomes **Ready for Pickup**.

### FR-10. Order Cancellation

- A customer may leave an order before checkout confirmation without creating a confirmed order.
- A confirmed customer order cannot be directly cancelled by the customer.
- A customer requesting cancellation after confirmation must contact the seller.
- A seller may cancel an order and must provide a customer-visible reason.

### FR-11. Inventory and Availability

- The seller shall define product quantities.
- Product inventory shall be decremented in real-time immediately upon payment confirmation by the seller (transition from **Pending Payment** to **Paid**), not at initial checkout creation.
- When a product's remaining quantity reaches zero, the system shall mark the product unavailable in real-time.
- Unavailable products shall immediately cease to be presented as orderable.
- The seller shall be able to manage product information, quantities, and restock levels in real-time.

### FR-12. Product Unavailability During Preparation

- The seller shall be able to mark an ordered product unavailable if stock is insufficient during preparation.
- The affected product shall remain visible on the order/receipt as unavailable.
- The unavailable product shall carry no charge or a zero price on the receipt.
- The corresponding amount shall be recorded for refund handling after preparation.

### FR-13. Receipt

- The system shall make the receipt available after the order is completed.
- The customer shall be able to choose to view the receipt.
- The receipt shall reflect final fulfilled products and any unavailable product adjustments.
- Completed transactions shall remain available in the seller's transaction history.

### FR-14. Seller Dashboard

The seller dashboard shall provide access to:

- Store information
- Store schedule
- Product management
- Product pricing
- Product availability/quantity
- Incoming orders
- Order status management
- Transaction history
- Relevant store/order statistics

### FR-15. Administrator Dashboard

The administrator interface shall provide seller account management, including:

- Seller request review
- Seller account creation
- Seller account management
- Seller account deactivation
- Administrative monitoring information

## 9. Business Rules

1. The system operates with one active seller/store under the current school policy.
2. A single static QR code identifies the active store.
3. The same static store QR code is placed across cafeteria tables for easy customer ordering without queuing at the counter; it remains permanent and does not reset unless the seller account is deactivated by an administrator.
4. A customer name is required before an order can be created.
5. Customers do not need an account to place an order.
6. An order is not considered paid until the seller confirms payment.
7. Only the seller may advance an order through its operational statuses.
8. A seller cancellation must include a reason visible to the customer.
9. A customer cannot directly cancel a confirmed order; the customer must request cancellation from the seller.
10. Product quantity is decremented in real-time immediately upon seller payment confirmation (Paid status).
11. A product becomes unavailable when its remaining quantity reaches zero.
12. If a product becomes unavailable during preparation, the product remains listed on the receipt with no charge and is recorded for refund handling after preparation.
13. An order becomes completed only after the customer has picked it up and the seller marks it completed.
14. A completed order can be followed by a new order using the same customer name.
15. Administrator-controlled seller deactivation may occur under defined conditions, including prolonged inactivity or health and safety violations.

## 10. Non-Functional Requirements

### 10.1 Performance

- The system should support multiple concurrent customers during normal school operating periods without significant lag.
- Order placement and status updates should complete within a practical response time suitable for active cafeteria use.
- Performance should remain acceptable during expected peak ordering periods.

Specific performance targets should be established through testing.

### 10.2 Security

- The system shall restrict seller functions to authorized seller accounts.
- Administrative functions shall be restricted to authorized administrators.
- Customers shall not be able to access another customer's private order information through normal application functions.
- Seller and administrative data shall be protected against unauthorized access.
- Data handling shall comply with applicable privacy and data protection requirements for the system's deployment region.

### 10.3 Usability

- The customer interface should be minimal, intuitive, and easy to navigate.
- The ordering process should require as few unnecessary steps as practical.
- The system shall provide clear instructions and understandable error messages.
- Order status and payment state shall be clearly displayed.

### 10.4 Scalability

- The current system is scoped for one school and one active seller/store.
- The design should avoid unnecessarily preventing future expansion to additional stores or schools.

### 10.5 Reliability

- The system should remain available during normal cafeteria operating periods.
- System data should be backed up.
- Recovery procedures should be defined for data loss or service interruption.

## 11. Data and Transaction Requirements

The system should maintain records necessary to support:

- Seller account information
- Store information
- Product information
- Product quantities
- Store schedule
- Customer name associated with an order
- Order items and quantities
- Order customizations
- Order totals
- Payment confirmation state
- Order status history
- Cancellation reasons
- Unavailable product adjustments
- Refund records
- Receipts
- Seller transaction history

## 12. Notifications

- Customers shall receive real-time notifications when their order is ready for pickup via both in-app status alerts and device/phone push notifications.
- Customer-facing order tracking shall reflect status changes in real-time (Pending Payment -> Paid -> Preparing -> Ready for Pickup -> Completed).
- Cancellation reasons and unavailable product adjustments shall be delivered and displayed to the customer in real-time.

## 13. Open Questions

1. What exact conditions and approval rules should apply to seller account requests?
2. What exact conditions should allow an administrator to deactivate a seller account beyond prolonged inactivity and health/safety violations?
3. What is the exact process for recording and settling refunds for unavailable products when payment is made manually?
4. What specific customer satisfaction method will be used to calculate the satisfaction metric?
5. What target values should be used for response time, queue reduction, order accuracy, and adoption?
6. What data retention period should apply to completed and cancelled transactions?
7. What exact privacy and data protection requirements apply to the school's deployment region?
8. What additional administrative monitoring or reporting should be included in the administrator dashboard?

## 14. Planned Future Capabilities

The following capabilities may be added as the system develops:

- Automated seller-request email and questionnaire workflow
- Electronic payment methods
- Expanded administrative reporting and analytics
- Support for additional stores or schools
