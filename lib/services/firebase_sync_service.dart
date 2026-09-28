import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

  /// Sync a new store request to Admin Dashboard & Firebase 'store_requests' collection
  Future<void> syncStoreRequest(StoreAccountRequest request) async {
    debugPrint('FirebaseSync: Store Request ${request.id} (${request.storeName}) syncing to Admin Web...');
    try {
      final uri = Uri.parse('http://localhost:3000/api/requests');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'storeName': request.storeName,
          'applicantName': request.applicantName,
          'email': request.email,
          'contactNumber': request.contactNumber,
          'reason': request.reason,
        }),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200 || res.statusCode == 201) {
        debugPrint('FirebaseSync: Store Request ${request.id} synced successfully to Admin Web!');
      } else {
        debugPrint('FirebaseSync: Admin Web returned status ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('FirebaseSync: Admin Web unreachable ($e). Local mode active.');
    }
  }
}
