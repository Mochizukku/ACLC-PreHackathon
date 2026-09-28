import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminSyncService {
  AdminSyncService._internal();
  static final AdminSyncService instance = AdminSyncService._internal();

  /// Default Admin Server URL (can be customized via .env ADMIN_SERVER_URL)
  String get adminBaseUrl {
    String? envUrl;
    if (dotenv.isInitialized) {
      envUrl = dotenv.maybeGet('ADMIN_SERVER_URL');
    }
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    if (!kIsWeb && Platform.isAndroid) {
      // 10.0.2.2 is the special alias for localhost on Android emulator
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  /// Synchronize a new seller account request from the mobile app to the Admin Website
  Future<bool> submitSellerRequest({
    required String storeName,
    required String applicantName,
    required String email,
    required String contactNumber,
    required String reason,
  }) async {
    try {
      final uri = Uri.parse('$adminBaseUrl/api/requests');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);

      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;

      final payload = jsonEncode({
        'storeName': storeName,
        'applicantName': applicantName,
        'email': email,
        'contactNumber': contactNumber,
        'reason': reason,
      });

      request.write(payload);
      final response = await request.close();
      client.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('AdminSyncService: Seller request synchronized successfully to Admin Dashboard.');
        return true;
      }
    } catch (e) {
      debugPrint('AdminSyncService: Sync notice ($e). Offline fallback preserved.');
    }
    return false;
  }

  /// Checks with the Admin Website whether the seller's account is currently Active
  Future<bool?> isSellerAccountActive(String email) async {
    try {
      final uri = Uri.parse('$adminBaseUrl/api/accounts/check/${Uri.encodeComponent(email)}');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        client.close();
        if (data.containsKey('active')) {
          return data['active'] as bool;
        }
      }
      client.close();
    } catch (e) {
      debugPrint('AdminSyncService: Status check fallback ($e).');
    }
    return null;
  }
}
