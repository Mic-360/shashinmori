import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _primary = Color(0xFF1B3A2D);
const _surface = Color(0xFFF5F0E8);
const _accent = Color(0xFFC9A84C);
const _background = Color(0xFFFAFAF7);
const _error = Color(0xFFB03A2E);
const _darkSurface = Color(0xFF1E241F);
const _darkBackground = Color(0xFF111512);

ThemeData lightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _primary,
    primary: _primary,
    secondary: _accent,
    surface: _surface,
    error: _error,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(surface: _surface),
    scaffoldBackgroundColor: _background,
    textTheme: GoogleFonts.dmSansTextTheme().copyWith(
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: _primary,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: _primary,
      ),
      titleLarge: GoogleFonts.cormorantGaramond(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: _primary,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

ThemeData darkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _primary,
    primary: _accent,
    secondary: _accent,
    surface: _darkSurface,
    error: _error,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(surface: _darkSurface),
    scaffoldBackgroundColor: _darkBackground,
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: _surface,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: _surface,
      ),
      titleLarge: GoogleFonts.cormorantGaramond(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: _surface,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1B221D),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
