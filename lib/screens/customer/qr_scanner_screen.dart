import 'package:flutter/material.dart';
import 'customer_name_screen.dart';
import 'menu_ordering_screen.dart';
import 'order_summary_screen.dart';
import 'waiting_status_screen.dart';
import 'order_finished_screen.dart';
import '../../models/menu_item.dart';

class QrScannerScreen extends StatefulWidget {
  final Function(String tableNumber)? onTableScanned;
  final VoidCallback? onBack;

  const QrScannerScreen({
    super.key,
    this.onTableScanned,
    this.onBack,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerLaserController;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerLaserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerLaserController.dispose();
    super.dispose();
  }

  void _onSampleQRScanned([String tableNumber = 'Table #04']) {
    if (widget.onTableScanned != null) {
      widget.onTableScanned!(tableNumber);
    } else {
      // Step 1: Customer Name & Avatar Input Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CustomerNameScreen(
            tableNumber: tableNumber,
            onNameSubmitted: (customerName) {
              _navigateToMenuOrdering(customerName, tableNumber);
            },
            onRescan: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }
  }

  void _navigateToMenuOrdering(String customerName, String tableNumber) {
    // Step 2: Menu Ordering Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MenuOrderingScreen(
          customerName: customerName,
          tableNumber: tableNumber,
          onChangeTable: () {
            Navigator.of(context).pop();
          },
          onProceedToCheckout: (cartItems, orderType) {
            _navigateToCheckout(customerName, tableNumber, orderType, cartItems);
          },
        ),
      ),
    );
  }

  void _navigateToCheckout(String customerName, String tableNumber, String orderType, List<CartItem> cartItems) {
    // Step 3: Order Summary & Checkout Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderSummaryScreen(
          customerName: customerName,
          tableNumber: tableNumber,
          orderType: orderType,
          cartItems: cartItems,
          onBackToMenu: () {
            Navigator.of(context).pop();
          },
          onOrderPlaced: (placedOrder) {
            _navigateToWaitingTracker(placedOrder);
          },
        ),
      ),
    );
  }

  void _navigateToWaitingTracker(CustomerOrder placedOrder) {
    // Step 4: Live Order Waiting & Status Screen (Pending -> Paid -> Preparing -> Ready)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WaitingStatusScreen(
          order: placedOrder,
          onCancelRequested: () {
            Navigator.of(context).pop();
          },
          onOrderCompleted: () {
            _navigateToOrderFinished(placedOrder);
          },
        ),
      ),
    );
  }

  void _navigateToOrderFinished(CustomerOrder completedOrder) {
    // Step 5: Order Finished Screen (Receipt, Notification, Start New Order / End Session)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OrderFinishedScreen(
          order: completedOrder,
          onStartNewOrder: () {
            // Start a new order with same customer or table
            _navigateToMenuOrdering(completedOrder.customerName, completedOrder.tableNumber);
          },
          onEndSession: () {
            // End session and return to Landing / Role Selection screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: < Scanner (Matching 3rd Picture)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack ?? () => Navigator.of(context).pop(),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Scanner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Camera View Finder & Sample QR Code (Matching 3rd Picture)
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer White Rounded Corner Brackets (Matching 3rd Picture)
                  CustomPaint(
                    size: const Size(270, 270),
                    painter: _ScannerBracketPainter(),
                  ),

                  // Inner Sample QR Code Box (Matching 3rd Picture)
                  GestureDetector(
                    onTap: () => _onSampleQRScanned('Table #04'),
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          if (_isTorchOn)
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Sample',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'QR code',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '(Tap to scan)',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // Animated Laser Scanner Line
                          AnimatedBuilder(
                            animation: _scannerLaserController,
                            builder: (context, child) {
                              return Positioned(
                                top: 10 + (_scannerLaserController.value * 165),
                                child: Container(
                                  width: 170,
                                  height: 2,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Align QR code inside the frame to scan',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const Spacer(flex: 3),

            // Bottom Torch Button (Matching 3rd Picture)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isTorchOn = !_isTorchOn;
                });
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(
                    color: _isTorchOn ? Colors.white : Colors.white54,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _isTorchOn ? Icons.flashlight_on_rounded : Icons.flashlight_on_outlined,
                  color: _isTorchOn ? Colors.white : Colors.white70,
                  size: 28,
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the 4 thick white rounded corner brackets (Matching 3rd Picture)
class _ScannerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    const double cornerSize = 40.0;
    const double radius = 16.0;

    // Top-Left Corner Bracket
    final pathTL = Path()
      ..moveTo(0, cornerSize)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(cornerSize, 0);
    canvas.drawPath(pathTL, paint);

    // Top-Right Corner Bracket
    final pathTR = Path()
      ..moveTo(size.width - cornerSize, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, cornerSize);
    canvas.drawPath(pathTR, paint);

    // Bottom-Left Corner Bracket
    final pathBL = Path()
      ..moveTo(0, size.height - cornerSize)
      ..lineTo(0, size.height - radius)
      ..quadraticBezierTo(0, size.height, radius, size.height)
      ..lineTo(cornerSize, size.height);
    canvas.drawPath(pathBL, paint);

    // Bottom-Right Corner Bracket
    final pathBR = Path()
      ..moveTo(size.width - cornerSize, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, size.height - cornerSize);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
