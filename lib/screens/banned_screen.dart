import 'package:flutter/material.dart';
import '../services/store_repository.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Warning Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade600, width: 2),
                ),
                child: Icon(
                  Icons.block_rounded,
                  size: 50,
                  color: Colors.red.shade500,
                ),
              ),
              const SizedBox(height: 28),

              // Title
              const Text(
                'ACCOUNT FLAGGED & BANNED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                'Access to this application has been suspended because inappropriate language was submitted 3 times.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'If you believe this is a mistake, please contact customer support or administrator.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),

              const Spacer(),

              // Demo Reset Button
              OutlinedButton.icon(
                onPressed: () {
                  StoreRepository.instance.resetBanState();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset Ban (Demo Only)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade300,
                  side: BorderSide(color: Colors.grey.shade700),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
