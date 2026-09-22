import 'dart:async';
import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the 3 loading dots
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Navigate to role selection after splash display
    _navigationTimer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const RoleSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Q2 QR Logo Emblem
              Image.asset(
                'assets/images/q2_logo_cropped.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if cropped asset not found
                  return Image.asset(
                    'lib/img/White BG.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  );
                },
              ),

              const SizedBox(height: 18),

              // "QR Query" Typography
              Image.asset(
                'assets/images/q2_text_cropped.png',
                width: 170,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'QR Query',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: Colors.black,
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // 3 Animated Loading Dots (Matching Figma Screenshot)
              AnimatedBuilder(
                animation: _dotController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      // Stagger wave across dots
                      final double offset = index * 0.28;
                      final double rawValue = (_dotController.value - offset) % 1.0;
                      final double normalized = rawValue < 0 ? rawValue + 1.0 : rawValue;

                      // Sine wave for smooth bounce/opacity
                      final double scale = 0.85 + 0.35 * (1.0 - (normalized - 0.5).abs() * 2);

                      // Colors from dark to light corresponding to screenshot
                      final Color dotColor = _getDotColor(index, normalized);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 8 * scale,
                        height: 8 * scale,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),

              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDotColor(int index, double progress) {
    // Screenshot baseline colors:
    // Dot 0: Black (#111111)
    // Dot 1: Medium Gray (#666666)
    // Dot 2: Light Gray (#A5A5A5)
    final baseShades = [
      const Color(0xFF111111),
      const Color(0xFF666666),
      const Color(0xFFA5A5A5),
    ];

    // Smooth wave pulse through shades
    if (progress > 0.3 && progress < 0.7) {
      return Colors.black;
    }
    return baseShades[index];
  }
}
