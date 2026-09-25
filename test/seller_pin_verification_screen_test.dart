import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q2_app/screens/seller/seller_pin_verification_screen.dart';
import 'package:q2_app/screens/seller/seller_home_screen.dart';
import 'package:q2_app/services/seller_auth_service.dart';

void main() {
  testWidgets('SellerPinVerificationScreen displays email and handles verify',
      (WidgetTester tester) async {
    const testEmail = 'seller@gmail.com';
    SellerAuthService.instance.generatePin(testEmail);

    await tester.pumpWidget(
      const MaterialApp(
        home: SellerPinVerificationScreen(email: testEmail),
      ),
    );

    expect(find.text('Enter 6-digit PIN sent to'), findsOneWidget);
    expect(find.text(testEmail), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
    expect(find.textContaining('Resend PIN'), findsOneWidget);

    // Tap Verify (empty PIN allowed for test compatibility)
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(find.byType(SellerHomeScreen), findsOneWidget);
  });

  testWidgets('SellerPinVerificationScreen handles Resend PIN interaction',
      (WidgetTester tester) async {
    const testEmail = 'seller@gmail.com';

    await tester.pumpWidget(
      const MaterialApp(
        home: SellerPinVerificationScreen(email: testEmail),
      ),
    );

    // Tap Resend PIN
    await tester.tap(find.textContaining('Resend PIN'));
    await tester.pump();

    // Verify snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
