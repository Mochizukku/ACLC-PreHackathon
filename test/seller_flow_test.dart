import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:q2_app/screens/seller/seller_access_screen.dart';
import 'package:q2_app/screens/seller/seller_sign_in_screen.dart';
import 'package:q2_app/screens/seller/seller_pin_verification_screen.dart';
import 'package:q2_app/screens/seller/seller_account_request_screen.dart';
import 'package:q2_app/screens/seller/seller_request_confirmation_screen.dart';
import 'package:q2_app/screens/seller/seller_home_screen.dart';

void main() {
  testWidgets('Seller Access to Sign In to PIN Verification to Seller Home flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SellerAccessScreen(),
      ),
    );

    // Verify SellerAccessScreen UI
    expect(find.text('Seller Access'), findsOneWidget);
    expect(find.text('Access your Store'), findsOneWidget);
    expect(find.text('Register your Store'), findsOneWidget);

    // Tap "Access your Store"
    await tester.tap(find.text('Access your Store'));
    await tester.pumpAndSettle();

    // Verify SellerSignInScreen UI
    expect(find.byType(SellerSignInScreen), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Remember Me'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);

    // Tap "SIGN IN"
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();

    // Verify SellerPinVerificationScreen UI
    expect(find.byType(SellerPinVerificationScreen), findsOneWidget);
    expect(find.text('Enter 6-digit PIN sent to'), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
    expect(find.textContaining('Resend PIN'), findsOneWidget);

    // Tap "Verify"
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    // Verify SellerHomeScreen UI (empty seller home page)
    expect(find.byType(SellerHomeScreen), findsOneWidget);
    expect(find.text('Seller Home'), findsOneWidget);
  });

  testWidgets('Seller Access to Account Request to Confirmation flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SellerAccessScreen(),
      ),
    );

    // Tap "Register your Store"
    await tester.tap(find.text('Register your Store'));
    await tester.pumpAndSettle();

    // Verify SellerAccountRequestScreen UI
    expect(find.byType(SellerAccountRequestScreen), findsOneWidget);
    expect(find.text('Store Name'), findsOneWidget);
    expect(find.text('Applicant Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contact Number'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);

    // Scroll to and tap "Submit"
    await tester.ensureVisible(find.text('Submit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Verify SellerRequestConfirmationScreen UI
    expect(find.byType(SellerRequestConfirmationScreen), findsOneWidget);
    expect(find.text('Thank you for making a request'), findsOneWidget);
    expect(find.text('Go back to Choices'), findsOneWidget);

    // Tap "Go back to Choices"
    await tester.tap(find.text('Go back to Choices'));
    await tester.pumpAndSettle();

    // Verifies back at SellerAccessScreen
    expect(find.byType(SellerAccessScreen), findsOneWidget);
  });
}
