import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../data/sample_menu.dart';

class SellerProductItem {
  final String id;
  String name;
  int stock;
  String imageUrl;
  double price;
  String description;
  bool isAvailable;
  List<String> addons; // List of add-on names or product IDs
  List<int>? imageBytes; // Raw bytes when seller uploads a local image

  SellerProductItem({
    required this.id,
    required this.name,
    required this.stock,
    required this.imageUrl,
    this.price = 7.00,
    this.description = '',
    this.isAvailable = true,
    this.addons = const [],
    this.imageBytes,
  });
}

enum AccountRequestStatus { pending, approved, rejected }

class StoreAccountRequest {
  final String id;
  final String storeName;
  final String applicantName;
  final String email;
  final String contactNumber;
  final String reason;
  final DateTime submittedAt;
  AccountRequestStatus status;
  String? rejectionReason;

  StoreAccountRequest({
    required this.id,
    required this.storeName,
    required this.applicantName,
    required this.email,
    required this.contactNumber,
    required this.reason,
    required this.submittedAt,
    this.status = AccountRequestStatus.pending,
    this.rejectionReason,
  });
}

class StoreRepository extends ChangeNotifier {
  StoreRepository._internal() {
    _initDefaultProducts();
  }
  static final StoreRepository instance = StoreRepository._internal();

  // Store status
  bool _isStoreOpen = true;
  bool get isStoreOpen => _isStoreOpen;

  void toggleStoreStatus(bool isOpen) {
    _isStoreOpen = isOpen;
    notifyListeners();
  }

  // Moderation / Ban Tracking
  int _inappropriateCount = 0;
  bool _isBanned = false;

  int get inappropriateCount => _inappropriateCount;
  bool get isBanned => _isBanned;

  void recordInappropriateAttempt() {
    _inappropriateCount++;
    if (_inappropriateCount >= 3) {
      _isBanned = true;
    }
    notifyListeners();
  }

  void resetBanState() {
    _inappropriateCount = 0;
    _isBanned = false;
    notifyListeners();
  }

  // Products inventory
  final List<SellerProductItem> _products = [];
  // Exposed as mutable so SellerEditProductScreen can mutate fields directly.
  List<SellerProductItem> get products => _products;

  /// Call this after directly mutating a product's fields to push updates to listeners.
  void notifyAll() => notifyListeners();

  void _initDefaultProducts() {
    _products.addAll([
      SellerProductItem(
        id: 'p1',
        name: 'Siomai',
        stock: 30,
        imageUrl: 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?auto=format&fit=crop&w=600&q=80',
      ),
      SellerProductItem(
        id: 'p2',
        name: 'Chicken Cutlet',
        stock: 17,
        imageUrl: 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?auto=format&fit=crop&w=600&q=80',
      ),
      SellerProductItem(
        id: 'p3',
        name: 'Siopao Asado',
        stock: 12,
        imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=600&q=80',
      ),
      SellerProductItem(
        id: 'p4',
        name: 'Bagnet',
        stock: 5,
        imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80',
      ),
      SellerProductItem(
        id: 'p5',
        name: 'Gyoza',
        stock: 8,
        imageUrl: 'https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?auto=format&fit=crop&w=600&q=80',
      ),
      SellerProductItem(
        id: 'p6',
        name: 'Bicol Express',
        stock: 12,
        imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=600&q=80',
      ),
    ]);
  }

  void addProduct(String name, int stock, [String? imageUrl]) {
    _products.add(
      SellerProductItem(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        stock: stock,
        imageUrl: imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
      ),
    );
    notifyListeners();
  }

  void editProduct(String id, String name, int stock) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index].name = name;
      _products[index].stock = stock;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void restockProduct(String id, int addQuantity) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index].stock += addQuantity;
      notifyListeners();
    }
  }

  // Customer Orders State
  final List<CustomerOrder> _orders = [];
  List<CustomerOrder> get allOrders => List.unmodifiable(_orders);

  List<CustomerOrder> get incomingOrders =>
      _orders.where((o) => o.status == OrderStatus.pendingPayment).toList();

  List<CustomerOrder> get pendingOrders => _orders
      .where((o) =>
          o.status == OrderStatus.paid ||
          o.status == OrderStatus.preparing ||
          o.status == OrderStatus.readyForPickup)
      .toList();

  List<CustomerOrder> get finishedOrders => _orders
      .where((o) =>
          o.status == OrderStatus.completed ||
          o.status == OrderStatus.cancelled)
      .toList();

  void addOrder(CustomerOrder order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status, {String? reason}) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final oldStatus = _orders[index].status;
      _orders[index].status = status;
      if (reason != null) {
        _orders[index].cancellationReason = reason;
      }

      // If transition from pendingPayment to paid (or completed), deduct stock
      if (oldStatus == OrderStatus.pendingPayment &&
          (status == OrderStatus.paid || status == OrderStatus.preparing || status == OrderStatus.completed)) {
        _deductStockForOrder(_orders[index]);
      }

      notifyListeners();
    }
  }

  void _deductStockForOrder(CustomerOrder order) {
    for (final cartItem in order.items) {
      final itemName = cartItem.item.name.toLowerCase();
      // Find matching product in seller inventory by partial/exact name match
      final index = _products.indexWhere(
        (p) => itemName.contains(p.name.toLowerCase()) || p.name.toLowerCase().contains(itemName),
      );
      if (index != -1) {
        final current = _products[index].stock;
        final updated = (current - cartItem.quantity).clamp(0, 999);
        _products[index].stock = updated;
      }
    }
    notifyListeners();
  }
}
