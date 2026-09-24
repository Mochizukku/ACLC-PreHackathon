import 'package:flutter/material.dart';

class SellerBrandHeader extends StatelessWidget {
  final double logoSize;
  final double textWidth;

  const SellerBrandHeader({
    super.key,
    this.logoSize = 40,
    this.textWidth = 110,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/q2_logo_cropped.png',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(
            Icons.qr_code_2_rounded,
            size: logoSize,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 10),
        Image.asset(
          'assets/images/q2_text_cropped.png',
          width: textWidth,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Text(
            'QR Query',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
