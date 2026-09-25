import 'package:flutter/material.dart';

/// AppTheme strictly enforcing Black, White, and Gray monochrome color spectrum.
class AppTheme {
  // Monochrome Color Palette
  static const Color pureBlack = Color(0xFF000000);
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color cardBg = Color(0xFF141414);
  static const Color cardBgElevated = Color(0xFF1E1E1E);
  static const Color grayBorder = Color(0xFF2A2A2A);
  
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color grayLight = Color(0xFFE0E0E0);
  static const Color grayMuted = Color(0xFF999999);
  static const Color grayDark = Color(0xFF444444);

  // Backward compatibility alias constants mapped to Monochrome
  static const Color primaryOrange = pureWhite; // Clean high-contrast White primary
  static const Color primaryGold = grayLight;
  static const Color accentTeal = grayLight;
  static const Color statusGreen = pureWhite;
  static const Color statusAmber = grayMuted;
  static const Color statusRed = Color(0xFF555555);
  static const Color textMain = pureWhite;
  static const Color textMuted = grayMuted;

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: pureWhite,
      secondary: grayLight,
      surface: cardBg,
      onSurface: pureWhite,
      onPrimary: pureBlack,
      error: grayLight,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: pureWhite,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: pureWhite),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: pureWhite,
        foregroundColor: pureBlack,
        elevation: 2,
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
    border: Border.all(color: grayBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration monochromeGradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF222222), Color(0xFF111111)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: grayBorder),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration orangeGradientDecoration = monochromeGradientDecoration;
}
