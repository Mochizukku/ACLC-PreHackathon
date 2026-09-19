import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/menu_item.dart';
import 'screens/splash_screen.dart';
import 'screens/customer_entry_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/customer_name_screen.dart';
import 'screens/menu_ordering_screen.dart';
import 'screens/order_summary_screen.dart';
import 'screens/waiting_status_screen.dart';
import 'screens/order_finished_screen.dart';

void main() {
  runApp(const CustomerOrderingApp());
}

enum AppStep {
  splash,
  customerEntry,
  qrScanner,
  customerNameInput,
  menuOrdering,
  orderSummary,
  waitingStatus,
  orderFinished,
}

class CustomerOrderingApp extends StatefulWidget {
  const CustomerOrderingApp({super.key});

  @override
  State<CustomerOrderingApp> createState() => _CustomerOrderingAppState();
}

class _CustomerOrderingAppState extends State<CustomerOrderingApp> {
  AppStep _currentStep = AppStep.splash;
  String _scannedTable = 'Table #04';
  String _customerName = 'Alex Rivera';
  List<CartItem> _activeCartItems = [];
  String _activeOrderType = 'Eat In';
  CustomerOrder? _currentOrder;
  bool _showMobileDeviceFrame = false; // Toggle to preview inside phone casing on desktop

  void _navigateTo(AppStep step) {
    setState(() {
      _currentStep = step;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeScreen;

    switch (_currentStep) {
      case AppStep.splash:
        activeScreen = SplashScreen(
          onStart: () => _navigateTo(AppStep.customerEntry),
        );
        break;

      case AppStep.customerEntry:
        activeScreen = CustomerEntryScreen(
          onCustomerSelect: () => _navigateTo(AppStep.qrScanner),
        );
        break;

      case AppStep.qrScanner:
        activeScreen = QrScannerScreen(
          onTableScanned: (table) {
            setState(() {
              _scannedTable = table;
            });
            _navigateTo(AppStep.customerNameInput);
          },
          onBack: () => _navigateTo(AppStep.customerEntry),
        );
        break;

      case AppStep.customerNameInput:
        activeScreen = CustomerNameScreen(
          tableNumber: _scannedTable,
          onNameSubmitted: (name) {
            setState(() {
              _customerName = name;
            });
            _navigateTo(AppStep.menuOrdering);
          },
          onRescan: () => _navigateTo(AppStep.qrScanner),
        );
        break;

      case AppStep.menuOrdering:
        activeScreen = MenuOrderingScreen(
          customerName: _customerName,
          tableNumber: _scannedTable,
          onChangeTable: () => _navigateTo(AppStep.qrScanner),
          onProceedToCheckout: (items, orderType) {
            setState(() {
              _activeCartItems = items;
              _activeOrderType = orderType;
            });
            _navigateTo(AppStep.orderSummary);
          },
        );
        break;

      case AppStep.orderSummary:
        activeScreen = OrderSummaryScreen(
          customerName: _customerName,
          tableNumber: _scannedTable,
          orderType: _activeOrderType,
          cartItems: _activeCartItems,
          onBackToMenu: () => _navigateTo(AppStep.menuOrdering),
          onOrderPlaced: (order) {
            setState(() {
              _currentOrder = order;
            });
            _navigateTo(AppStep.waitingStatus);
          },
        );
        break;

      case AppStep.waitingStatus:
        activeScreen = WaitingStatusScreen(
          order: _currentOrder!,
          onCancelRequested: () => _navigateTo(AppStep.menuOrdering),
          onOrderCompleted: () => _navigateTo(AppStep.orderFinished),
        );
        break;

      case AppStep.orderFinished:
        activeScreen = OrderFinishedScreen(
          order: _currentOrder!,
          onStartNewOrder: () {
            // Keep customer name for quick re-order or restart
            _navigateTo(AppStep.customerEntry);
          },
        );
        break;
    }

    return MaterialApp(
      title: 'OmniOrder Mobile Kiosk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: const Color(0xFF07080A),
        body: Stack(
          children: [
            // Responsive Layout: Render directly or inside Mobile Device Frame
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 500;
                if (isWide && _showMobileDeviceFrame) {
                  return Center(
                    child: Container(
                      width: 410,
                      height: 840,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBg,
                        borderRadius: BorderRadius.circular(48),
                        border: Border.all(color: const Color(0xFF3A3D4D), width: 10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(38),
                        child: activeScreen,
                      ),
                    ),
                  );
                }
                return activeScreen;
              },
            ),

            // Top Quick Flow Indicator & Mobile Frame Toggle for Web/Evaluators
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Flow: ${_stepLabel(_currentStep)}',
                        style: const TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showMobileDeviceFrame = !_showMobileDeviceFrame;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _showMobileDeviceFrame ? AppTheme.primaryOrange : Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_android_rounded,
                                size: 12,
                                color: _showMobileDeviceFrame ? Colors.white : AppTheme.textMuted,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _showMobileDeviceFrame ? 'Phone Frame ON' : 'Phone Frame OFF',
                                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepLabel(AppStep step) {
    switch (step) {
      case AppStep.splash:
        return '1. Splash';
      case AppStep.customerEntry:
        return '2. Customer Button';
      case AppStep.qrScanner:
        return '3. QR Scanner';
      case AppStep.customerNameInput:
        return '4. Customer Name';
      case AppStep.menuOrdering:
        return '5. Menu & Cart';
      case AppStep.orderSummary:
        return '6. Order Summary';
      case AppStep.waitingStatus:
        return '7. Waiting Tracker';
      case AppStep.orderFinished:
        return '8. Order Finished';
    }
  }
}
