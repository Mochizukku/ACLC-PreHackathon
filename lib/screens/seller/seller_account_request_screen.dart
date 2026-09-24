import 'package:flutter/material.dart';
import 'widgets/seller_brand_header.dart';
import 'seller_request_confirmation_screen.dart';

class SellerAccountRequestScreen extends StatefulWidget {
  const SellerAccountRequestScreen({super.key});

  @override
  State<SellerAccountRequestScreen> createState() =>
      _SellerAccountRequestScreenState();
}

class _SellerAccountRequestScreenState
    extends State<SellerAccountRequestScreen> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _applicantNameController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _storeNameController.dispose();
    _applicantNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SellerRequestConfirmationScreen(),
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
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Centered Brand Header
              const Center(
                child: SellerBrandHeader(logoSize: 44, textWidth: 115),
              ),
              const SizedBox(height: 28),

              // Title
              const Center(
                child: Text(
                  'Account Request',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Store Name Field
              _buildFieldLabel('Store Name'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _storeNameController,
                hintText: 'Enter store name',
              ),
              const SizedBox(height: 14),

              // Applicant Name Field
              _buildFieldLabel('Applicant Name'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _applicantNameController,
                hintText: 'Enter your full name',
              ),
              const SizedBox(height: 14),

              // Email Field
              _buildFieldLabel('Email'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _emailController,
                hintText: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // Contact Number Field
              _buildFieldLabel('Contact Number'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _contactNumberController,
                hintText: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // Reason Field
              _buildFieldLabel('Why are you requesting a\nseller account?'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _reasonController,
                hintText: 'Explain briefly...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.25,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFC4C4C4), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.black87, width: 1.2),
        ),
      ),
    );
  }
}
