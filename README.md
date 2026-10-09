# QR Query (Q2)

QR Query (Q2) is a QR-based ordering system designed for a school cafeteria. It allows customers to scan a QR code from a cafeteria table, browse the available menu, place an order, and track the order until pickup.

The system provides separate functions for **Customers**, **Sellers**, and **Administrators**.

The project is currently being developed as a **system prototype** and **demonstration**. Due to the limited development time, the current implementation focuses on demonstrating the **intended application flow**, **user experience**, and **interaction between system roles** rather than implementing the complete backend functionality.

## Project Scope

The current system is designed for:

* One school
* One active cafeteria seller/store
* QR codes placed at cafeteria tables
* Customer ordering without requiring an account
* Seller-managed products and inventory
* Manual payment confirmation at the counter
* Order tracking and notifications
* Receipt and transaction history
* Administrator-managed seller accounts

For the current demo, these features are represented primarily through **predefined data**, **interface screens**, **navigation**, and **simulated actions**.

## Main Components

### Customer

Customers can:

* Scan the cafeteria QR code
* Enter their name
* Browse, search, and filter the menu
* Customize products
* Add items to a cart
* Submit an order
* Pay at the counter
* Track order status
* Receive notification when the order is ready
* View the completed order receipt
* Start another order using the same customer name

The current prototype focuses on showing the complete customer journey from scanning the QR code to completing an order.

### Seller

Sellers can:

* Manage store information
* Manage products and prices
* Manage product quantities and availability
* Manage store schedules
* View incoming orders
* Confirm payments
* Update order status
* Handle order cancellation
* Manage product unavailability during preparation
* View transaction history

For the current demo, seller actions may use simulated or predefined data to demonstrate the expected workflow.

### Administrator

Administrators can:

* Manage seller accounts
* Review seller requests
* Create seller accounts
* Deactivate seller accounts when applicable

These functions are presented as part of the proposed administrator workflow and may not include full backend account management in the current prototype.

## Demo Approach

The current development priority is to produce a **presentable demonstration of how Q2 would work as a complete system**.

The prototype focuses on: 

* User interface and screen design
* Navigation between screens
* Customer, seller, and administrator workflows
* Simulated system states
* Sample products, orders, and transactions
* Demonstrating the intended user experience

Full backend functionality, persistent data storage, real authentication, live notifications, and other system integrations are outside the immediate demo scope.

The objective is to demonstrate the **system concept and application flow** clearly before implementing the complete functionality.

## Documentation

Detailed system requirements and behavior are documented in:

* [Product Requirement Document (PRD)](PRD.md)

Additional project documentation will be added as the system develops.

## Project Status

The project is currently under development.

The current version is intended for demonstrating the proposed system flow. Full functionality may be implemented in a later development stage as time and project requirements allow.

## Purpose

Q2 aims to provide a more organized and efficient way for students to order from the school cafeteria while helping sellers manage incoming orders, inventory, and transaction workflows.

## Run Locally

### For Customer/Seller

Requires the Flutter SDK and a configured target device, emulator, or desktop platform.

```sh
flutter pub get
flutter run
```

Run test using: 

```sh
flutter test
``` 

### For Admin

Get the admin directory with the simple command using:

```sh
cd admin_web
```

Open a server with: 

```sh
node server.js
```

## Project Structure

For Customers/Sellers: 

- `lib/screens/splash_screen.dart`: application splash screen.
- `lib/screens/role_selection.dart`: role selection for seller and customer users.
- `lib/screens/customer/`: customer qr scanner, dashboard, menu ordering, checkout, status, and finished order with summary.
- `lib/screens/seller/`: seller login/register, home screen, profile screen, order screen, product screen, incoming/pending orders and order/payment confirmation. 
- `lib/screens/banned_screen.dart`: banned customers for sellers to each store.
- `lib/data/sample_menu.dart`: order samples, food images, sample pricing, and product description.
- `lib/models/menu_item.dart`: order status demonstration with order details.
- `lib/services/`: application backend-database connection, customer addons and seller authentication.
- `lib/theme/`: application color screen theme palette.
- `lib/utils/content_filter/dart`: restricted words for customer naming.

For Testing: 

- `test/connected_customer_seller_test.dart`:  handles customer and seller interaction.
- `test/seller_auth_service_test.dart`: seller authentication for logging in.
- `test/seller_flow_test.dart`: seller dashboard, profile, order, and products flow.
- `test/seller_pin_verification_screen_test.dart`: seller verification confirmation through PIN.
- `test/widget_test.dart`: splash screen response.

For Admin: 

- `admin_web/public/index.html`: 