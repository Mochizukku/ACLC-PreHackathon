import 'package:flutter/material.dart';
import 'widgets/seller_app_bar.dart';
import 'widgets/seller_bottom_nav_bar.dart';
import 'tabs/seller_home_tab.dart';
import 'tabs/seller_orders_tab.dart';
import 'tabs/seller_products_tab.dart';

class SellerHomeScreen extends StatefulWidget {
  final int initialTabIndex;

  const SellerHomeScreen({super.key, this.initialTabIndex = 0});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SellerAppBar(
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have no new notifications.')),
          );
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SellerHomeTab(
            onNavigateToOrders: () => _onTabSelected(1),
            onNavigateToProducts: () => _onTabSelected(2),
          ),
          const SellerOrdersTab(),
          const SellerProductsTab(),
        ],
      ),
      bottomNavigationBar: SellerBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
