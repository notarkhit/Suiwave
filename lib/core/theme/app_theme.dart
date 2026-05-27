import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Suiwave design tokens and theme builder.
///
/// Color strategy: dark-first Material 3 with a default seed of [_kSeedColor].
/// Per-track dynamic color replaces this seed at runtime via [buildDynamicTheme].
class AppTheme {
  AppTheme._();

  static const Color _kSeedColor = Color(0xFFED5564);
  static const Color _kSurface = Color(0xFF0D0D0D);
  static const Color _kSurfaceContainer = Color(0xFF181818);
  static const Color _kSurfaceContainerHigh = Color(0xFF222222);

  // ---------------------------------------------------------------------------
  // Border radii — no capsules unless semantically correct
  // ---------------------------------------------------------------------------
  static const double radiusArtwork = 8.0;
  static const double radiusCard = 12.0;
  static const double radiusSheet = 16.0;
  static const double radiusSmall = 6.0;

  static BorderRadius get artworkRadius =>
      BorderRadius.circular(radiusArtwork);
  static BorderRadius get cardRadius => BorderRadius.circular(radiusCard);
  static BorderRadius get sheetRadius => const BorderRadius.only(
        topLeft: Radius.circular(radiusSheet),
        topRight: Radius.circular(radiusSheet),
      );

  // ---------------------------------------------------------------------------
  // Theme builders
  // ---------------------------------------------------------------------------

  static ThemeData darkTheme({Color? seedColor}) {
    final seed = seedColor ?? _kSeedColor;
    final cs = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      surface: _kSurface,
      surfaceContainer: _kSurfaceContainer,
      surfaceContainerHigh: _kSurfaceContainerHigh,
      onSurface: Colors.white,
      onSurfaceVariant: Colors.white60,
    );

    return _base(cs);
  }

  static ThemeData pureBlackTheme({Color? seedColor}) {
    final seed = seedColor ?? _kSeedColor;
    final cs = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      surface: Colors.black,
      surfaceContainer: const Color(0xFF111111),
      surfaceContainerHigh: const Color(0xFF1A1A1A),
      onSurface: Colors.white,
      onSurfaceVariant: Colors.white60,
    );

    return _base(cs);
  }

  static ThemeData _base(ColorScheme cs) {
    final textTheme = GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
          fontSize: 57, fontWeight: FontWeight.w400, color: Colors.white),
      displayMedium: GoogleFonts.nunito(
          fontSize: 45, fontWeight: FontWeight.w400, color: Colors.white),
      displaySmall: GoogleFonts.nunito(
          fontSize: 36, fontWeight: FontWeight.w400, color: Colors.white),
      headlineLarge: GoogleFonts.nunito(
          fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
      headlineMedium: GoogleFonts.nunito(
          fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
      headlineSmall: GoogleFonts.nunito(
          fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
      titleLarge: GoogleFonts.nunito(
          fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.1),
      titleSmall: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.1),
      bodyLarge: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
      bodyMedium: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
      bodySmall: GoogleFonts.nunito(
          fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white54),
      labelLarge: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: GoogleFonts.nunito(
          fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
      labelSmall: GoogleFonts.nunito(
          fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white54),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: cs.surface,
      // Navigation bar — no capsule indicator, sharp/square style
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withValues(alpha: 0.15),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? cs.primary : Colors.white54,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? cs.primary : Colors.white54,
            size: 22,
          );
        }),
        height: 64,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Dividers
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 0.5,
      ),
      // List tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        subtitleTextStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white54,
        ),
        iconColor: Colors.white70,
      ),
      // Icon buttons — no container background
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.08),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSmall),
            ),
          ),
        ),
      ),
      // Cards
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        margin: EdgeInsets.zero,
      ),
      // Bottom sheets
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: sheetRadius),
        elevation: 0,
      ),
      // Sliders
      sliderTheme: SliderThemeData(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.primary.withValues(alpha: 0.25),
        thumbColor: cs.primary,
        overlayColor: cs.primary.withValues(alpha: 0.12),
      ),
      // Search bar
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(cs.surfaceContainer),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.nunito(fontSize: 15, color: Colors.white),
        ),
        hintStyle: WidgetStateProperty.all(
          GoogleFonts.nunito(fontSize: 15, color: Colors.white38),
        ),
      ),
    );
  }
}
