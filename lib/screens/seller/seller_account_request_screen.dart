import 'package:flutter/material.dart';
import 'widgets/seller_brand_header.dart';
import 'seller_request_confirmation_screen.dart';
import '../banned_screen.dart';
import '../../services/store_repository.dart';
import '../../utils/content_filter.dart';
import '../../services/firebase_sync_service.dart';

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

  String? _storeNameError;
  String? _applicantNameError;
  String? _emailError;
  String? _contactNumberError;
  String? _reasonError;

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
    // Check ban state first
    if (StoreRepository.instance.isBanned) {
      _navigateToBannedScreen();
      return;
    }

    setState(() {
      _storeNameError = _storeNameController.text.trim().isEmpty
          ? 'Complete the specified field'
          : null;
      _applicantNameError = _applicantNameController.text.trim().isEmpty
          ? 'Complete the specified field'
          : null;
      _emailError = _emailController.text.trim().isEmpty
          ? 'Complete the specified field'
          : null;
      _contactNumberError = _contactNumberController.text.trim().isEmpty
          ? 'Complete the specified field'
          : null;
      _reasonError = _reasonController.text.trim().isEmpty
          ? 'Complete the specified field'
          : null;
    });

    final hasEmptyField = _storeNameError != null ||
        _applicantNameError != null ||
        _emailError != null ||
        _contactNumberError != null ||
        _reasonError != null;

    if (hasEmptyField) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complete the specified field'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check content moderation on Reason field
    final reasonText = _reasonController.text.trim();
    final filterError = ContentFilter.validate(reasonText);

    if (filterError != null) {
      // Inappropriate message detected! Increment strike count in StoreRepository
      StoreRepository.instance.recordInappropriateAttempt();
      final currentStrikes = StoreRepository.instance.inappropriateCount;

      if (StoreRepository.instance.isBanned) {
        _navigateToBannedScreen();
        return;
      }

      setState(() {
        _reasonError =
            'Inappropriate content detected. Warning: $currentStrikes/3 strikes. 3 strikes will ban your access.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Inappropriate message detected! Warning $currentStrikes/3 strikes. Reaching 3 strikes will ban your access.',
          ),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // If all fields are non-empty and clean, submit request & proceed
    final newRequest = StoreAccountRequest(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      storeName: _storeNameController.text.trim(),
      applicantName: _applicantNameController.text.trim(),
      email: _emailController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
      reason: _reasonController.text.trim(),
      submittedAt: DateTime.now(),
    );
    FirebaseSyncService.instance.syncStoreRequest(newRequest);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SellerRequestConfirmationScreen(),
      ),
    );
  }

  void _navigateToBannedScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const BannedScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (StoreRepository.instance.isBanned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToBannedScreen();
      });
    }

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
                errorText: _storeNameError,
                onChanged: (_) {
                  if (_storeNameError != null) {
                    setState(() => _storeNameError = null);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Applicant Name Field
              _buildFieldLabel('Applicant Name'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _applicantNameController,
                hintText: 'Enter your full name',
                errorText: _applicantNameError,
                onChanged: (_) {
                  if (_applicantNameError != null) {
                    setState(() => _applicantNameError = null);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Email Field
              _buildFieldLabel('Email'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _emailController,
                hintText: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Contact Number Field
              _buildFieldLabel('Contact Number'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _contactNumberController,
                hintText: 'Enter your phone number',
                keyboardType: TextInputType.phone,
                errorText: _contactNumberError,
                onChanged: (_) {
                  if (_contactNumberError != null) {
                    setState(() => _contactNumberError = null);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Reason Field
              _buildFieldLabel('Why are you requesting a\nseller account?'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _reasonController,
                hintText: 'Explain briefly...',
                maxLines: 4,
                errorText: _reasonError,
                onChanged: (_) {
                  if (_reasonError != null) {
                    setState(() => _reasonError = null);
                  }
                },
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
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        errorText: errorText,
        errorMaxLines: 3,
        errorStyle: TextStyle(fontSize: 12, color: Colors.red.shade700),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: errorText != null ? Colors.red.shade400 : const Color(0xFFC4C4C4),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: errorText != null ? Colors.red.shade700 : Colors.black87,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
