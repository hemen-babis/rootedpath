import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const seed = Color(0xFF7B1E22);
  static const gold = Color(0xFFB08900);

  static ThemeData light(Locale locale) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(secondary: gold, tertiary: gold),
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: _textThemeFor(locale, Brightness.light),
    );
  }

  static ThemeData dark(Locale locale) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(secondary: gold, tertiary: gold),
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: _textThemeFor(locale, Brightness.dark),
    );
  }

  static TextTheme _textThemeFor(Locale locale, Brightness b) {
    final base = (b == Brightness.dark ? ThemeData.dark() : ThemeData.light()).textTheme;
    final code = locale.languageCode.toLowerCase();
    // Ethiopic scripts → Abyssinica SIL; else Poppins
    if (code == 'am' || code == 'ti' || code == 'om') {
      return GoogleFonts.abyssinicaSilTextTheme(base);
    }
    return GoogleFonts.poppinsTextTheme(base);
  }
}
