import 'package:flutter/material.dart';
import 'widgets/seller_brand_header.dart';
import 'seller_pin_verification_screen.dart';

class SellerSignInScreen extends StatefulWidget {
  const SellerSignInScreen({super.key});

  @override
  State<SellerSignInScreen> createState() => _SellerSignInScreenState();
}

class _SellerSignInScreenState extends State<SellerSignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    final email = _emailController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SellerPinVerificationScreen(
          email: email.isNotEmpty ? email : 'sample@email.com',
        ),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Centered Brand Header
              const Center(
                child: SellerBrandHeader(logoSize: 46, textWidth: 120),
              ),
              const SizedBox(height: 64),

              // Email Label
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Email Input Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFC4C4C4), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Colors.black87, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Remember Me Checkbox Row
              GestureDetector(
                onTap: () {
                  setState(() {
                    _rememberMe = !_rememberMe;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (val) {
                          setState(() {
                            _rememberMe = val ?? false;
                          });
                        },
                        activeColor: Colors.black,
                        checkColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF757575), width: 1.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Remember Me',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // SIGN IN Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _onSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
