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

    // Pulse wave animation for the 3 loading dots
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Navigate to role selection screen matching 2nd picture
    _navigationTimer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const RoleSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
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

              // Q2 Emblem Logo (Matching 1st Picture)
              Image.asset(
                'assets/images/q2_logo_cropped.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const _Q2LogoEmblemWidget(size: 130);
                },
              ),

              const SizedBox(height: 18),

              // "QR Query" Typography (Matching 1st Picture)
              Image.asset(
                'assets/images/q2_text_cropped.png',
                width: 170,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'QR Query',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.black,
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // 3 Animated Loading Dots (Matching 1st Picture)
              AnimatedBuilder(
                animation: _dotController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final double offset = index * 0.28;
                      final double rawValue = (_dotController.value - offset) % 1.0;
                      final double normalized = rawValue < 0 ? rawValue + 1.0 : rawValue;
                      final double scale = 0.85 + 0.35 * (1.0 - (normalized - 0.5).abs() * 2);
                      final Color dotColor = _getDotColor(index, normalized);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 9 * scale,
                        height: 9 * scale,
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
    final baseShades = [
      const Color(0xFF111111),
      const Color(0xFF666666),
      const Color(0xFFA5A5A5),
    ];
    if (progress > 0.3 && progress < 0.7) {
      return Colors.black;
    }
    return baseShades[index];
  }
}

/// Precise custom widget matching Q2 Emblem from reference pictures
class _Q2LogoEmblemWidget extends StatelessWidget {
  final double size;
  const _Q2LogoEmblemWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(size * 0.16),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        padding: EdgeInsets.all(size * 0.1),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: size * 0.25,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: size * 0.24,
                height: size * 0.24,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
