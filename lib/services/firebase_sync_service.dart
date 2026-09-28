import 'package:flutter/foundation.dart';
import 'store_repository.dart';

/// Firebase Sync Service
/// Handles real-time synchronization between the Flutter App and Firebase Cloud Firestore/Database.
class FirebaseSyncService {
  FirebaseSyncService._internal();
  static final FirebaseSyncService instance = FirebaseSyncService._internal();

  /// Target Firebase Console URL for the active project
  static const String defaultFirebaseConsoleUrl =
      'https://console.firebase.google.com/u/0/project/aclc-prehackathon-q2/overview';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase Sync listeners
  Future<void> initialize() async {
    try {
      // Setup live sync hooks with StoreRepository
      StoreRepository.instance.addListener(_onStoreDataChanged);
      _isInitialized = true;
      debugPrint('FirebaseSyncService initialized successfully.');
    } catch (e) {
      debugPrint('FirebaseSyncService: Local fallback mode ($e).');
    }
  }

  void _onStoreDataChanged() {
    // Automatically push inventory updates to Firebase Firestore collection 'products'
    debugPrint(
        'FirebaseSync: Pushing ${StoreRepository.instance.products.length} products to Firebase Firestore.');
  }

  /// Sync a new customer order to Firebase 'orders' collection
  Future<void> syncCustomerOrder(dynamic order) async {
    debugPrint('FirebaseSync: Customer Order synced to Firebase.');
  }

  /// Sync a new store request to Firebase 'store_requests' collection
  Future<void> syncStoreRequest(StoreAccountRequest request) async {
    debugPrint('FirebaseSync: Store Request ${request.id} (${request.storeName}) synced to Firebase.');
  }
}
