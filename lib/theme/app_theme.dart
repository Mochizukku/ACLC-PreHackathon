import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color primaryGold = Color(0xFFFFB800);
  static const Color darkBg = Color(0xFF0F1015);
  static const Color cardBg = Color(0xFF1B1D26);
  static const Color cardBgElevated = Color(0xFF262936);
  static const Color accentTeal = Color(0xFF00E5FF);
  static const Color statusGreen = Color(0xFF00E676);
  static const Color statusAmber = Color(0xFFFFAB00);
  static const Color statusRed = Color(0xFFFF3D00);
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9E9EA9);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primaryOrange,
      secondary: primaryGold,
      surface: cardBg,
      error: statusRed,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textMain,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: textMain),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration orangeGradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFFF6B00), Color(0xFFFF9100)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: const Color(0x59FF6B00),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
