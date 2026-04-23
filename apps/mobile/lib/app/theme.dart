import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// COP17 brand tokens — derived from unccdcop17.org.
///
/// Narrative: "The Land of the Eternal Blue Sky" — deep teal of the UNCCD
/// logo paired with a cyan sky accent; warm sand for accents drawn from
/// the Gobi dunes / steppe. Manrope typography, soft rounded surfaces.
class CopColors {
  // ─── Brand primaries ────────────────────────────────────────
  /// Logo teal — headings, primary surfaces, tier "blue-zone" accents.
  static const primary = Color(0xFF14464F);

  /// "Eternal Blue Sky" cyan — highlight, active state, accent fills.
  static const sky = Color(0xFF05B6C4);

  /// Warm dune accent — attention grabbing without losing UN gravitas.
  static const sand = Color(0xFFF5D9A8);

  // ─── Neutrals ───────────────────────────────────────────────
  static const ink = Color(0xFF1F2937);
  static const inkMuted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const bg = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF3F4F6);

  // ─── Semantic ──────────────────────────────────────────────
  static const success = Color(0xFF059669);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);
  static const info = sky;

  // ─── Tier accent palette ───────────────────────────────────
  // Each tier maps to a distinct, brand-consistent accent.
  static const tierGreen = Color(0xFF059669); // Green Zone — access-all
  static const tierBlue = Color(0xFF05B6C4);  // Blue Zone — delegate/press
  static const tierVip = Color(0xFF8B5CF6);   // VIP
  static const tierExhibitor = Color(0xFFD97706); // Exhibitor
  static const tierPress = Color(0xFF0369A1); // Press
}

class CopRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;
}

class CopSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Legacy aliases kept so existing widgets compile; prefer `CopColors.*`.
const kTierGreen = CopColors.tierGreen;
const kTierBlue = CopColors.tierBlue;
const kTierVip = CopColors.tierVip;
const kTierExhibitor = CopColors.tierExhibitor;

ThemeData buildCop17Theme() {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: CopColors.primary,
    primary: CopColors.primary,
    onPrimary: Colors.white,
    secondary: CopColors.sky,
    onSecondary: Colors.white,
    tertiary: CopColors.sand,
    surface: CopColors.surface,
    onSurface: CopColors.ink,
    error: CopColors.danger,
  );

  final text = GoogleFonts.manropeTextTheme().apply(
    bodyColor: CopColors.ink,
    displayColor: CopColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: baseScheme,
    scaffoldBackgroundColor: CopColors.bg,
    textTheme: text.copyWith(
      displayLarge: text.displayLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineLarge: text.headlineLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
      headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: CopColors.surface,
      foregroundColor: CopColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: CopColors.ink,
        letterSpacing: -0.2,
      ),
    ),

    cardTheme: CardThemeData(
      color: CopColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CopRadius.lg),
        side: const BorderSide(color: CopColors.border),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CopColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CopRadius.md)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CopColors.primary,
        side: const BorderSide(color: CopColors.border),
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CopRadius.md)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CopColors.primary,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CopColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: GoogleFonts.manrope(color: CopColors.inkMuted),
      hintStyle: GoogleFonts.manrope(color: CopColors.inkMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CopRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CopRadius.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CopRadius.md),
        borderSide: const BorderSide(color: CopColors.sky, width: 1.5),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: CopColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      indicatorColor: CopColors.sky.withValues(alpha: 0.12),
      labelTextStyle: WidgetStatePropertyAll(GoogleFonts.manrope(
        fontSize: 11, fontWeight: FontWeight.w600, color: CopColors.inkMuted,
      )),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
        color: s.contains(WidgetState.selected) ? CopColors.primary : CopColors.inkMuted,
      )),
    ),

    dividerTheme: const DividerThemeData(color: CopColors.border, space: 1, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: CopColors.surfaceAlt,
      labelStyle: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CopRadius.pill),
        side: BorderSide.none,
      ),
    ),
  );
}

/// Convenience gradient — used on splash + zone headers.
const copBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [CopColors.primary, Color(0xFF0A7A8A), CopColors.sky],
);

/// Map a tier string to its accent color.
Color tierColor(String tier) => switch (tier) {
      'blue' => CopColors.tierBlue,
      'vip' => CopColors.tierVip,
      'exhibitor' => CopColors.tierExhibitor,
      'press' => CopColors.tierPress,
      _ => CopColors.tierGreen,
    };

String tierEmoji(String tier) => switch (tier) {
      'blue' => '🔵',
      'vip' => '💎',
      'exhibitor' => '🏢',
      'press' => '📰',
      _ => '🟢',
    };

String tierLabel(String tier) => switch (tier) {
      'blue' => 'Blue Zone',
      'vip' => 'VIP',
      'exhibitor' => 'Exhibitor',
      'press' => 'Press',
      _ => 'Green Zone',
    };
