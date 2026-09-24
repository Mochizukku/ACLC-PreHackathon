import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/seller_brand_header.dart';
import 'seller_home_screen.dart';

class SellerPinVerificationScreen extends StatefulWidget {
  final String email;

  const SellerPinVerificationScreen({
    super.key,
    this.email = 'sample@email.com',
  });

  @override
  State<SellerPinVerificationScreen> createState() =>
      _SellerPinVerificationScreenState();
}

class _SellerPinVerificationScreenState
    extends State<SellerPinVerificationScreen> {
  static const int _pinLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_pinLength, (_) => TextEditingController());
    _focusNodes = List.generate(_pinLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onVerify() {
    // Navigate to empty SellerHomeScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
      (route) => route.isFirst,
    );
  }

  void _onResendPin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PIN resent to ${widget.email}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Centered Brand Header
              const SellerBrandHeader(logoSize: 46, textWidth: 120),
              const SizedBox(height: 56),

              // Instruction text
              const Text(
                'Enter 6-digit PIN sent to',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),

              // Email target in blue
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E60D5),
                ),
              ),
              const SizedBox(height: 36),

              // 6 PIN Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_pinLength, (index) {
                  return SizedBox(
                    width: 44,
                    height: 52,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.backspace &&
                            _controllers[index].text.isEmpty &&
                            index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFC4C4C4),
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.black87,
                              width: 1.6,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < _pinLength - 1) {
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 44),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 72),

              // Resend PIN Footer
              GestureDetector(
                onTap: _onResendPin,
                child: const Text.rich(
                  TextSpan(
                    text: "Didn't Receive? ",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: 'Resend PIN',
                        style: TextStyle(
                          color: Color(0xFF1E60D5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
