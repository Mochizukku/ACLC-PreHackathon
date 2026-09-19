import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QrScannerScreen extends StatefulWidget {
  final Function(String tableNumber) onTableScanned;
  final VoidCallback onBack;

  const QrScannerScreen({
    super.key,
    required this.onTableScanned,
    required this.onBack,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerScan(String table) {
    widget.onTableScanned(table);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Camera Simulation Feed
          Positioned.fill(
            child: Container(
              color: const Color(0xFF11141A),
              child: Center(
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 200,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),

          // Flash Light effect overlay
          if (_isFlashOn)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.08),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                // Top Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                      const Text(
                        'Scan Table QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isFlashOn = !_isFlashOn;
                          });
                        },
                        icon: Icon(
                          _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          color: _isFlashOn ? AppTheme.primaryGold : Colors.white70,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Scanner Reticle Target Frame
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Scanner Box Frame
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.primaryOrange, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      // Animated Laser Scanner Line
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Positioned(
                            top: 20 + (_animationController.value * 210),
                            child: Container(
                              width: 230,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppTheme.accentTeal,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentTeal.withOpacity(0.8),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Corner Highlights
                      Positioned(
                        top: 12,
                        left: 12,
                        child: const Icon(Icons.qr_code_rounded, color: Colors.white38, size: 30),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Point camera at the QR code on your cafeteria table',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const Spacer(),

                // Demo Quick Test Table Scan Shortcuts
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBgElevated.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.touch_app_rounded, size: 16, color: AppTheme.primaryGold),
                          SizedBox(width: 6),
                          Text(
                            'Simulate Scan (Tap Demo Table):',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTableButton('Table #04', () => _triggerScan('Table #04')),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTableButton('Table #08', () => _triggerScan('Table #08')),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTableButton('Table #12', () => _triggerScan('Table #12')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
        foregroundColor: Colors.white,
        elevation: 0,
        side: const BorderSide(color: AppTheme.primaryOrange, width: 1),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
