import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────
// ShashinMori M3 Expressive Theme
// Inspired by Google Photos with enchanted forest aesthetics
// ─────────────────────────────────────────────────────────

const _seed = Color(0xFF2E7D32);

ThemeData lightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
    primary: const Color(0xFF2E7D32),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFA5D6A7),
    onPrimaryContainer: const Color(0xFF002106),
    secondary: const Color(0xFF52634F),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFD5E8CF),
    onSecondaryContainer: const Color(0xFF101F10),
    tertiary: const Color(0xFFF9A825),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFFFE082),
    onTertiaryContainer: const Color(0xFF3E2E00),
    surface: const Color(0xFFFAFDF7),
    onSurface: const Color(0xFF1A1C18),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF5F8F0),
    surfaceContainer: const Color(0xFFEFF2EA),
    surfaceContainerHigh: const Color(0xFFE9ECE5),
    surfaceContainerHighest: const Color(0xFFE3E7DF),
    error: const Color(0xFFBA1A1A),
    outline: const Color(0xFF73796E),
    outlineVariant: const Color(0xFFC3C8BB),
  );

  final textTheme = _buildTextTheme(Brightness.light);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 80,
      elevation: 0,
      backgroundColor: colorScheme.surfaceContainer,
      indicatorColor: colorScheme.primaryContainer,
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(size: 24, color: colorScheme.onSurface),
      ),
      labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.primaryContainer,
      selectedIconTheme:
          IconThemeData(color: colorScheme.onPrimaryContainer),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.primaryContainer,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      extendedTextStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        side: BorderSide(color: colorScheme.outline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor:
          WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      showDragHandle: true,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: colorScheme.surfaceContainerHighest,
      color: colorScheme.primary,
    ),
  );
}

ThemeData darkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
    primary: const Color(0xFF81C784),
    onPrimary: const Color(0xFF003910),
    primaryContainer: const Color(0xFF005319),
    onPrimaryContainer: const Color(0xFFA5D6A7),
    secondary: const Color(0xFFBACCB4),
    onSecondary: const Color(0xFF253423),
    secondaryContainer: const Color(0xFF3B4B38),
    onSecondaryContainer: const Color(0xFFD5E8CF),
    tertiary: const Color(0xFFFFD54F),
    onTertiary: const Color(0xFF3E2E00),
    tertiaryContainer: const Color(0xFF5C4500),
    onTertiaryContainer: const Color(0xFFFFE082),
    surface: const Color(0xFF111512),
    onSurface: const Color(0xFFE1E4DC),
    surfaceContainerLowest: const Color(0xFF0C0F0C),
    surfaceContainerLow: const Color(0xFF191D18),
    surfaceContainer: const Color(0xFF1D211C),
    surfaceContainerHigh: const Color(0xFF282B26),
    surfaceContainerHighest: const Color(0xFF333630),
    error: const Color(0xFFFFB4AB),
    outline: const Color(0xFF8D9387),
    outlineVariant: const Color(0xFF434840),
  );

  final textTheme = _buildTextTheme(Brightness.dark);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 80,
      elevation: 0,
      backgroundColor: colorScheme.surfaceContainer,
      indicatorColor: colorScheme.primaryContainer,
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(size: 24, color: colorScheme.onSurface),
      ),
      labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.primaryContainer,
      selectedIconTheme:
          IconThemeData(color: colorScheme.onPrimaryContainer),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.primaryContainer,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      extendedTextStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        side: BorderSide(color: colorScheme.outline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor:
          WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      showDragHandle: true,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: colorScheme.surfaceContainerHighest,
      color: colorScheme.primary,
    ),
  );
}

TextTheme _buildTextTheme(Brightness brightness) {
  final base = brightness == Brightness.light
      ? ThemeData.light().textTheme
      : ThemeData.dark().textTheme;

  return GoogleFonts.outfitTextTheme(base).copyWith(
    displayLarge: GoogleFonts.bricolageGrotesque(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.bricolageGrotesque(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    displaySmall: GoogleFonts.bricolageGrotesque(
      fontSize: 36,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: GoogleFonts.bricolageGrotesque(
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: GoogleFonts.bricolageGrotesque(
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.bricolageGrotesque(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: GoogleFonts.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500),
  );
}
