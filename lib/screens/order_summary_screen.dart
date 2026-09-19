import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../theme/app_theme.dart';

class OrderSummaryScreen extends StatelessWidget {
  final String customerName;
  final String tableNumber;
  final String orderType;
  final List<CartItem> cartItems;
  final Function(CustomerOrder order) onOrderPlaced;
  final VoidCallback onBackToMenu;

  const OrderSummaryScreen({
    super.key,
    required this.customerName,
    required this.tableNumber,
    required this.orderType,
    required this.cartItems,
    required this.onOrderPlaced,
    required this.onBackToMenu,
  });

  double get _subtotal {
    double total = 0.0;
    for (var item in cartItems) {
      total += item.totalPrice;
    }
    return total;
  }

  double get _taxAndFee => 0.0; // School cafeteria tax exempt / bundled

  double get _grandTotal => _subtotal + _taxAndFee;

  void _placeOrder() {
    final newOrder = CustomerOrder(
      orderId: (100 + (DateTime.now().millisecondsSinceEpoch % 899)).toString(),
      customerName: customerName,
      tableNumber: tableNumber,
      items: cartItems,
      subtotal: _subtotal,
      taxAndFee: _taxAndFee,
      totalAmount: _grandTotal,
      orderTime: DateTime.now(),
      orderType: orderType,
      status: OrderStatus.pendingPayment,
    );
    onOrderPlaced(newOrder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBackToMenu,
        ),
        title: const Text('Order Summary & Checkout'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table & Customer Card Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: AppTheme.cardDecoration,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.table_restaurant_rounded, color: AppTheme.primaryOrange, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tableNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardBgElevated,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Text(
                                  orderType.toUpperCase(),
                                  style: const TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customer: $customerName',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'ORDER ITEMS',
                style: TextStyle(
                  color: AppTheme.primaryGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),

              // Itemized List Card
              Container(
                decoration: AppTheme.cardDecoration,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (int i = 0; i < cartItems.length; i++) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${cartItems[i].quantity}x',
                                style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItems[i].item.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                if (cartItems[i].selectedCustomizations.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      cartItems[i].selectedCustomizations.map((c) => c.option.name).join(', '),
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                    ),
                                  ),
                                if (cartItems[i].specialInstructions.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      'Note: "${cartItems[i].specialInstructions}"',
                                      style: const TextStyle(color: AppTheme.primaryGold, fontSize: 11, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '₱${cartItems[i].totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      if (i < cartItems.length - 1)
                        const Divider(color: Colors.white10, height: 20),
                    ],

                    const Divider(color: Colors.white10, height: 24),

                    // Bill Summary Breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                        Text('₱${_subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Convenience & Service Fee', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                        const Text('FREE (₱0.00)', style: TextStyle(color: AppTheme.statusGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        Text(
                          '₱${_grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.primaryGold, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Notice Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.payment_rounded, color: AppTheme.primaryGold, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method: Pay at Counter',
                            style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'After placing order, show your order ticket # to the cashier to pay and start kitchen prep.',
                            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Order Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    shadowColor: AppTheme.primaryOrange.withOpacity(0.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'PLACE ORDER NOW',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
