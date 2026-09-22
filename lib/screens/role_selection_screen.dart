import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Brand header
              Row(
                children: [
                  Image.asset(
                    'assets/images/q2_logo_cropped.png',
                    width: 44,
                    height: 44,
                    errorBuilder: (_, _, _) => const Icon(Icons.qr_code, size: 40),
                  ),
                  const SizedBox(width: 12),
                  Image.asset(
                    'assets/images/q2_text_cropped.png',
                    width: 110,
                    errorBuilder: (_, _, _) => const Text(
                      'QR Query',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              const Text(
                'Welcome to Q2',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fast, seamless cafeteria ordering from your table.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const Spacer(),

              // Role cards
              _RoleCard(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Customer',
                subtitle: 'Scan table QR code to view menu & order',
                isPrimary: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not finished!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _RoleCard(
                icon: Icons.storefront_outlined,
                title: 'Seller Portal',
                subtitle: 'Manage menu, orders & live inventory',
                isPrimary: false,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seller Portal coming up!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              // const SizedBox(height: 14),

              // _RoleCard(
              //   icon: Icons.admin_panel_settings_outlined,
              //   title: 'Administrator',
              //   subtitle: 'Approve & oversee cafeteria store accounts',
              //   isPrimary: false,
              //   onTap: () {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(
              //         content: Text('Admin Console coming up!'),
              //         duration: Duration(seconds: 2),
              //       ),
              //    );
              //  },
              // ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? Colors.black : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary ? Colors.black : Colors.grey.shade300,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withAlpha(30)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: isPrimary ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isPrimary ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isPrimary ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isPrimary ? Colors.white70 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
