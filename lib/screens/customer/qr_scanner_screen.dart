import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'customer_name_screen.dart';
import 'menu_ordering_screen.dart';
import 'order_summary_screen.dart';
import 'waiting_status_screen.dart';
import 'order_finished_screen.dart';
import '../../models/menu_item.dart';
import '../../services/store_repository.dart';

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
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isTorchOn = false;
  bool _isProcessingScan = false;

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
    _cameraController.dispose();
    super.dispose();
  }

  void _onQRBarcodeScanned(String rawData) {
    if (_isProcessingScan) return;
    _isProcessingScan = true;

    String storeName = "Kent's Campus Diner";
    String tableNumber = "Table #04";

    try {
      if (rawData.startsWith('{')) {
        final data = jsonDecode(rawData);
        if (data['storeName'] != null) {
          storeName = data['storeName'];
        }
      } else if (rawData.contains(':')) {
        final parts = rawData.split(':');
        if (parts.length >= 3) {
          storeName = parts[2];
        }
      }
    } catch (_) {}

    // Active store set in StoreRepository
    StoreRepository.instance.setActiveStore(storeName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📷 Scanned Store: $storeName ($tableNumber)'),
        backgroundColor: Colors.green.shade800,
        duration: const Duration(seconds: 2),
      ),
    );

    _onSampleQRScanned(tableNumber, storeName);
  }

  void _onSampleQRScanned([String tableNumber = 'Table #04', String storeName = "Kent's Campus Diner"]) {
    StoreRepository.instance.setActiveStore(storeName);

    if (widget.onTableScanned != null) {
      widget.onTableScanned!(tableNumber);
    } else {
      // Step 1: Customer Name & Avatar Input Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CustomerNameScreen(
            tableNumber: tableNumber,
            onNameSubmitted: (customerName, customerId) {
              _navigateToMenuOrdering(customerName, customerId, tableNumber);
            },
            onRescan: () {
              _isProcessingScan = false;
              Navigator.of(context).pop();
            },
          ),
        ),
      ).then((_) => _isProcessingScan = false);
    }
  }

  void _navigateToMenuOrdering(String customerName, String customerId, String tableNumber) {
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
            _navigateToCheckout(customerName, customerId, tableNumber, orderType, cartItems);
          },
        ),
      ),
    );
  }

  void _navigateToCheckout(String customerName, String customerId, String tableNumber, String orderType, List<CartItem> cartItems) {
    // Step 3: Order Summary & Checkout Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderSummaryScreen(
          customerName: customerName,
          customerId: customerId,
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
            _navigateToMenuOrdering(completedOrder.customerName, completedOrder.customerId, completedOrder.tableNumber);
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

            const Spacer(flex: 1),

            // Live Camera Scanner View
            Center(
              child: SizedBox(
                width: 270,
                height: 270,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Live Camera Feed
                      MobileScanner(
                        controller: _cameraController,
                        onDetect: (capture) {
                          final barcode = capture.barcodes.firstOrNull;
                          if (barcode?.rawValue != null) {
                            _onQRBarcodeScanned(barcode!.rawValue!);
                          }
                        },
                      ),

                      // Animated Red Laser Line Overlay
                      AnimatedBuilder(
                        animation: _scannerLaserController,
                        builder: (context, child) {
                          return Positioned(
                            top: 10 + (_scannerLaserController.value * 245),
                            child: Container(
                              width: 250,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.85),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Corner Bracket Overlay
                      CustomPaint(
                        size: const Size(270, 270),
                        painter: _ScannerBracketPainter(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Align QR code inside the frame to scan',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 10),

            // Demo Mode buttons (for testing without physical QR)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.white30, size: 14),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: Text(
                      'No QR code? Tap a store below to demo:',
                      style: TextStyle(color: Colors.white30, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  "Kent's Campus Diner",
                  "Kent's Crispy Chicken & Snacks",
                  "Campus Cafeteria Hub (Main)",
                  "Kape & Pastry Corner",
                ].map((storeName) {
                  return GestureDetector(
                    onTap: () => _onSampleQRScanned('Table #04', storeName),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        storeName,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Spacer(flex: 1),

            // Bottom Torch Button
            GestureDetector(
              onTap: () {
                setState(() {
                  _isTorchOn = !_isTorchOn;
                });
                _cameraController.toggleTorch();
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
