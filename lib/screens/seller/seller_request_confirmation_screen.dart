import 'package:flutter/material.dart';
import 'widgets/seller_brand_header.dart';

class SellerRequestConfirmationScreen extends StatelessWidget {
  const SellerRequestConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Brand header
              const SellerBrandHeader(logoSize: 46, textWidth: 120),
              const SizedBox(height: 48),

              // Title
              const Text(
                'Account Request',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),

              const Spacer(flex: 2),

              // Thank you message
              const Text(
                'Thank you for making a request',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Sub-message
              Text(
                'A message will be sent in your email for 3 -14 business days',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // "Go back to Choices" Button
              OutlinedButton(
                onPressed: () {
                  // Navigate back to Role Selection (or Seller Access)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFC4C4C4), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Go back to Choices',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
