import 'package:flutter/material.dart';
import '../../models/menu_item.dart';

class OrderFinishedScreen extends StatelessWidget {
  final CustomerOrder order;
  final VoidCallback onStartNewOrder;
  final VoidCallback onEndSession;

  const OrderFinishedScreen({
    super.key,
    required this.order,
    required this.onStartNewOrder,
    required this.onEndSession,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Success Icon Badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ORDER FINISHED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Thank you for dining with us! Your order has been completed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 28),

              // Digital Receipt Ticket Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Branding Header
                    Center(
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'CAMPUS CAFETERIA HUB',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Official Digital Receipt',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white12, height: 28),

                    // Order Metadata
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ORDER NUMBER', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('#${order.orderId}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('TABLE NUMBER', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(order.tableNumber, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CUSTOMER NAME', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(order.customerName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('DATE & TIME', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(
                              '${order.orderTime.hour.toString().padLeft(2, '0')}:${order.orderTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white12, height: 28),

                    // Items Breakdown
                    const Text('FULFILLED ITEMS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    const SizedBox(height: 10),
                    for (var item in order.items) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.item.name}',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '₱${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Divider(color: Colors.white12, height: 28),

                    // Payment Badge & Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('PAID AT COUNTER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('TOTAL PAID', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(
                              '₱${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Barcode / QR Simulation for verification
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.black),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Scan barcode for refund / receipt verification',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons: 1) START NEW ORDER, 2) END SESSION
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onStartNewOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('START NEW ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: onEndSession,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.exit_to_app_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('END SESSION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
