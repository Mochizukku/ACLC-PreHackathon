import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item.dart';

class SellerProductItem {
  final String id;
  String name;
  int stock;
  String imageUrl;
  double price;
  String description;
  bool isAvailable;
  List<String> addons;
  List<int>? imageBytes;

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'stock': stock,
        'imageUrl': imageUrl,
        'price': price,
        'description': description,
        'isAvailable': isAvailable,
        'addons': addons,
      };

  factory SellerProductItem.fromJson(Map<String, dynamic> json) =>
      SellerProductItem(
        id: json['id'] as String,
        name: json['name'] as String,
        stock: json['stock'] as int,
        imageUrl: json['imageUrl'] as String,
        price: (json['price'] as num?)?.toDouble() ?? 7.00,
        description: json['description'] as String? ?? '',
        isAvailable: json['isAvailable'] as bool? ?? true,
        addons: List<String>.from(json['addons'] as List? ?? []),
      );
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
  StoreRepository._internal();
  static final StoreRepository instance = StoreRepository._internal();

  // ── Active Seller Session ──
  String? _sellerEmail;
  String? get sellerEmail => _sellerEmail;

  String _applicantName = '';
  String get applicantName => _applicantName;

  String _contactNumber = '';
  String get contactNumber => _contactNumber;

  String _accountStatus = 'Active';
  String get accountStatus => _accountStatus;

  // Store status & Active Store Name
  bool _isStoreOpen = true;
  bool get isStoreOpen => _isStoreOpen;

  String _activeStoreName = '';
  String _activeStoreId = '';
  String get activeStoreName => _activeStoreName;
  String get activeStoreId => _activeStoreId;

  void setActiveStore(String storeName, {String storeId = ''}) {
    if (storeName.isNotEmpty) {
      _activeStoreName = storeName;
      _activeStoreId = storeId;
      notifyListeners();
    }
  }

  void toggleStoreStatus(bool isOpen) {
    _isStoreOpen = isOpen;
    _saveStoreOpenStatusToPrefs();
    notifyListeners();
  }

  // Moderation / Ban Tracking
  int _inappropriateCount = 0;
  bool _isBanned = false;
  int get inappropriateCount => _inappropriateCount;
  bool get isBanned => _isBanned;

  void recordInappropriateAttempt() {
    _inappropriateCount++;
    if (_inappropriateCount >= 3) _isBanned = true;
    notifyListeners();
  }

  void resetBanState() {
    _inappropriateCount = 0;
    _isBanned = false;
    notifyListeners();
  }

  // Products inventory — starts EMPTY per seller
  final List<SellerProductItem> _products = [];
  List<SellerProductItem> get products => _products;

  void notifyAll() => notifyListeners();

  // Customer Orders — starts EMPTY per seller
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

  // Convert seller products to MenuItem format for Customer Menu ordering screen
  List<MenuItem> getMenuItemsForActiveStore() {
    if (_products.isEmpty) return [];
    return _products.where((p) => p.isAvailable).map((p) {
      return MenuItem(
        id: p.id,
        name: p.name,
        description: p.description.isNotEmpty ? p.description : '${p.name} - Freshly prepared (${p.stock} available)',
        price: p.price,
        category: 'Main Menu',
        imageUrl: p.imageUrl,
        isAvailable: p.isAvailable && p.stock > 0,
      );
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SESSION INIT — called after successful OTP login
  // ─────────────────────────────────────────────────────────────────────────

  /// Initialise repository for a specific seller.
  Future<void> initForSeller({
    required String email,
    required String storeName,
    String storeId = '',
    String applicantName = '',
    String contactNumber = '',
    String status = 'Active',
  }) async {
    _sellerEmail = email.toLowerCase().trim();
    _activeStoreName = storeName;
    _activeStoreId = storeId;
    _applicantName = applicantName;
    _contactNumber = contactNumber;
    _accountStatus = status;
    _inappropriateCount = 0;
    _isBanned = false;

    // Clear previous session data
    _products.clear();
    _orders.clear();

    // Load saved products, profile, and store open state for this seller
    await _loadProductsFromPrefs();
    await _loadStoreOpenStatusFromPrefs();
    await _loadProfileFromPrefs();

    if (applicantName.isNotEmpty || contactNumber.isNotEmpty) {
      await _saveProfileToPrefs();
    }

    notifyListeners();
    debugPrint(
        '[StoreRepository] Session started for $_sellerEmail — ${_products.length} products loaded.');
  }

  /// Called on logout / session end — clears everything
  void clearSession() {
    _sellerEmail = null;
    _activeStoreName = '';
    _activeStoreId = '';
    _applicantName = '';
    _contactNumber = '';
    _accountStatus = 'Active';
    _isStoreOpen = true;
    _products.clear();
    _orders.clear();
    _inappropriateCount = 0;
    _isBanned = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCT & PROFILE PERSISTENCE (SharedPreferences per seller email)
  // ─────────────────────────────────────────────────────────────────────────

  String get _emailKeyPart =>
      (_sellerEmail ?? 'default').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

  String get _productsPrefKey => 'seller_products_$_emailKeyPart';
  String get _storeOpenPrefKey => 'seller_store_open_$_emailKeyPart';
  String get _profilePrefKey => 'seller_profile_$_emailKeyPart';

  Future<void> _loadStoreOpenStatusFromPrefs() async {
    if (_sellerEmail == null) return;
    try {
      try {
        SharedPreferences.setMockInitialValues({});
      } catch (_) {}
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_storeOpenPrefKey)) {
        _isStoreOpen = prefs.getBool(_storeOpenPrefKey) ?? true;
      }
    } catch (_) {}
  }

  Future<void> _saveStoreOpenStatusToPrefs() async {
    if (_sellerEmail == null) return;
    try {
      try {
        SharedPreferences.setMockInitialValues({});
      } catch (_) {}
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_storeOpenPrefKey, _isStoreOpen);
    } catch (_) {}
  }

  Future<void> _loadProfileFromPrefs() async {
    if (_sellerEmail == null) return;
    try {
      try {
        SharedPreferences.setMockInitialValues({});
      } catch (_) {}
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_profilePrefKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
        if (_applicantName.isEmpty) _applicantName = data['applicantName'] as String? ?? '';
        if (_contactNumber.isEmpty) _contactNumber = data['contactNumber'] as String? ?? '';
        if (data['storeName'] != null && (data['storeName'] as String).isNotEmpty) {
          _activeStoreName = data['storeName'] as String;
        }
      }
    } catch (_) {}
  }

  Future<void> _saveProfileToPrefs() async {
    if (_sellerEmail == null) return;
    try {
      try {
        SharedPreferences.setMockInitialValues({});
      } catch (_) {}
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'applicantName': _applicantName,
        'contactNumber': _contactNumber,
        'storeName': _activeStoreName,
        'storeId': _activeStoreId,
        'status': _accountStatus,
      };
      await prefs.setString(_profilePrefKey, jsonEncode(data));
    } catch (_) {}
  }

  Future<void> _loadProductsFromPrefs() async {
    try {
      try {
        SharedPreferences.setMockInitialValues({});
      } catch (_) {}
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_productsPrefKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        _products.addAll(list.map((e) => SellerProductItem.fromJson(e as Map<String, dynamic>)));
      }
    } catch (e) {
      debugPrint('[StoreRepository] Error loading products: $e');
    }
  }

  Future<void> _saveProductsToPrefs() async {
    if (_sellerEmail == null) return;
    try {
      try {
        SharedPreferences.setMockInitialValues({});
      } catch (_) {}
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_products.map((p) => p.toJson()).toList());
      await prefs.setString(_productsPrefKey, encoded);
    } catch (e) {
      debugPrint('[StoreRepository] Error saving products: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCT CRUD
  // ─────────────────────────────────────────────────────────────────────────

  void addProduct(String name, int stock, [String? imageUrl]) {
    _products.add(SellerProductItem(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      stock: stock,
      imageUrl: imageUrl ??
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
    ));
    _saveProductsToPrefs();
    notifyListeners();
  }

  void editProduct(String id, String name, int stock) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index].name = name;
      _products[index].stock = stock;
      _saveProductsToPrefs();
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    _saveProductsToPrefs();
    notifyListeners();
  }

  void restockProduct(String id, int addQuantity) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index].stock += addQuantity;
      _saveProductsToPrefs();
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ORDER MANAGEMENT
  // ─────────────────────────────────────────────────────────────────────────

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
      if (oldStatus == OrderStatus.pendingPayment &&
          (status == OrderStatus.paid ||
              status == OrderStatus.preparing ||
              status == OrderStatus.completed)) {
        _deductStockForOrder(_orders[index]);
      }
      notifyListeners();
    }
  }

  void _deductStockForOrder(CustomerOrder order) {
    for (final cartItem in order.items) {
      final itemName = cartItem.item.name.toLowerCase();
      final index = _products.indexWhere(
        (p) =>
            itemName.contains(p.name.toLowerCase()) ||
            p.name.toLowerCase().contains(itemName),
      );
      if (index != -1) {
        final current = _products[index].stock;
        final updated = (current - cartItem.quantity).clamp(0, 999);
        _products[index].stock = updated;
      }
    }
    _saveProductsToPrefs();
    notifyListeners();
  }
}
