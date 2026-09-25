import 'package:flutter_test/flutter_test.dart';
import 'package:q2_app/services/seller_auth_service.dart';

void main() {
  group('SellerAuthService Tests', () {
    final authService = SellerAuthService.instance;

    setUp(() {
      authService.clearPin();
    });

    test('generatePin creates a 6-digit numeric PIN', () {
      final pin = authService.generatePin('seller@example.com');
      expect(pin.length, 6);
      expect(int.tryParse(pin), isNotNull);
      expect(authService.activePin, pin);
      expect(authService.activeEmail, 'seller@example.com');
    });

    test('verifyPin validates matching active PIN', () {
      final pin = authService.generatePin('seller@example.com');
      expect(
        authService.verifyPin(enteredPin: pin, email: 'seller@example.com'),
        isTrue,
      );
    });

    test('verifyPin accepts 6-digit test PIN in debug mode as configured', () {
      authService.generatePin('seller@example.com');
      // In debug mode, any 6-digit numeric PIN is allowed
      expect(
        authService.verifyPin(enteredPin: '123456', email: 'seller@example.com'),
        isTrue,
      );
    });

    test('verifyPin rejects non-6-digit PINs', () {
      authService.generatePin('seller@example.com');
      expect(
        authService.verifyPin(enteredPin: '12', email: 'seller@example.com'),
        isFalse,
      );
      expect(
        authService.verifyPin(enteredPin: 'abcdef', email: 'seller@example.com'),
        isFalse,
      );
    });

    test('isPinExpired returns false immediately after generation', () {
      authService.generatePin('seller@example.com');
      expect(authService.isPinExpired(), isFalse);
    });

    test('clearPin resets active state', () {
      authService.generatePin('seller@example.com');
      authService.clearPin();
      expect(authService.activePin, isNull);
      expect(authService.activeEmail, isNull);
    });
  });
}
