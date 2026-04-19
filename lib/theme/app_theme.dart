import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central theme configuration for the La Rose app.
///
/// All color tokens, typography, spacing, and component styles are defined here.
/// No hex values should appear anywhere else in the codebase.
class AppTheme {
  AppTheme._();

  // ───────────────────────── Colors ─────────────────────────

  /// Single brand color used for all accent purposes.
  static const Color primary = Color(0xFFC8828E);

  /// Light mode app background.
  static const Color backgroundLight = Color(0xFFF8F6F6);

  /// Dark mode app background.
  static const Color backgroundDark = Color(0xFF221015);

  /// Card / app bar / bottom nav surface in light mode.
  static const Color surface = Color(0xFFFFFFFF);

  /// Card surface in dark mode (slate-800).
  static const Color surfaceDark = Color(0xFF1E293B);

  /// Bottom nav background in dark mode (slate-900).
  static const Color navDark = Color(0xFF0F172A);

  /// Primary body text in light mode (slate-900).
  static const Color textPrimary = Color(0xFF0F172A);

  /// Primary body text in dark mode (slate-100).
  static const Color textPrimaryDark = Color(0xFFF1F5F9);

  /// Inactive nav icons / placeholder text (slate-400).
  static const Color textMuted = Color(0xFF94A3B8);

  /// Inactive nav icons in dark mode (slate-500).
  static const Color textMutedDark = Color(0xFF64748B);

  /// Descriptions / secondary text in light mode (slate-600).
  static const Color textSubtle = Color(0xFF475569);

  /// Descriptions / secondary text in dark mode (slate-300).
  static const Color textSubtleDark = Color(0xFFCBD5E1);

  /// Product card subtitle text (slate-500).
  static const Color textSlate500 = Color(0xFF64748B);

  /// Card title text in light mode (slate-800).
  static const Color textSlate800 = Color(0xFF1E293B);

  // ───────────── Primary opacity variants ─────────────

  /// Card backgrounds, subtle tints — primary at 5%.
  static Color get primary5 => primary.withValues(alpha: 0.05);

  /// Icon container bg, category chip bg unselected, hover states — primary at 10%.
  static Color get primary10 => primary.withValues(alpha: 0.10);

  /// Philosophy section icon container — primary at 20%.
  static Color get primary20 => primary.withValues(alpha: 0.20);

  /// Button shadow — primary at 30%.
  static Color get primary30 => primary.withValues(alpha: 0.30);

  /// Search input focus ring — primary at 50%.
  static Color get primary50 => primary.withValues(alpha: 0.50);

  /// Search bar icon — primary at 60%.
  static Color get primary60 => primary.withValues(alpha: 0.60);

  /// Primary button hover state — primary at 90%.
  static Color get primary90 => primary.withValues(alpha: 0.90);

  // ───────────────── Border Radius ──────────────────

  /// Default corners — 8dp.
  static const double radiusDefault = 8.0;

  /// Large corners — 16dp (cards, icon containers).
  static const double radiusLg = 16.0;

  /// Extra-large corners — 24dp (cards `rounded-xl`, hero section).
  static const double radiusXl = 24.0;

  /// Full pill — 9999px (buttons, chips, nav FAB, badge).
  static const double radiusFull = 9999.0;

  // ───────────────── Spacing & Layout ──────────────────

  /// Screen horizontal padding — 16dp.
  static const double paddingHorizontal = 16.0;

  /// Card gap in horizontal scroll / grid — 16dp.
  static const double cardGap = 16.0;

  /// Section vertical padding — 24dp.
  static const double sectionPaddingVertical = 24.0;

  /// Card internal padding (home cards) — 16dp.
  static const double cardPadding = 16.0;

  /// Card internal padding (shop grid cards) — 12dp.
  static const double cardPaddingShop = 12.0;

  /// Hero min-height — 288dp.
  static const double heroMinHeight = 288.0;

  /// Hero internal padding — 24dp.
  static const double heroPadding = 24.0;

  /// Home product card width — 256dp.
  static const double homeCardWidth = 256.0;

  /// Home product card image height — 192dp.
  static const double homeCardImageHeight = 192.0;

  /// Primary pill button height — 48dp.
  static const double buttonHeight = 48.0;

  /// Primary pill button horizontal padding — 32dp.
  static const double buttonPaddingHorizontal = 32.0;

  /// App bar icon button size — 40dp.
  static const double appBarIconSize = 40.0;

  /// Add/favorite button size (shop grid) — 32dp.
  static const double actionButtonSize = 32.0;

  // ───────────────── Typography helpers ──────────────────

  /// Returns a [TextStyle] using Plus Jakarta Sans from Google Fonts.
  static TextStyle _plusJakarta({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// App bar title "La Rose" — 24sp, bold (home) / extrabold (shop).
  static TextStyle appBarTitle({bool isShop = false, Color? color}) =>
      _plusJakarta(
        fontSize: 24,
        fontWeight: isShop ? FontWeight.w800 : FontWeight.w700,
        color: color ?? primary,
        letterSpacing: -0.5,
      );

  /// Script wordmark style for the "La Rose" brand label.
  static TextStyle brandWordmark({Color? color, double fontSize = 34}) =>
      GoogleFonts.greatVibes(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color ?? primary,
        height: 1.0,
      );

  /// Hero heading — 30sp, bold, white.
  static TextStyle heroHeading() => _plusJakarta(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
  );

  /// Section headers — 18sp, bold.
  static TextStyle sectionHeader({Color? color}) => _plusJakarta(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.5,
  );

  /// Section "View All" link — 14sp, semibold, primary.
  static TextStyle viewAllLink() =>
      _plusJakarta(fontSize: 14, fontWeight: FontWeight.w600, color: primary);

  /// Category chip text — 14sp, medium.
  static TextStyle categoryChip({Color? color}) =>
      _plusJakarta(fontSize: 14, fontWeight: FontWeight.w500, color: color);

  /// Product card title — 14sp, bold.
  static TextStyle productCardTitle({Color? color}) =>
      _plusJakarta(fontSize: 14, fontWeight: FontWeight.w700, color: color);

  /// Product card subtitle — 10sp, regular, slate-500.
  static TextStyle productCardSubtitle({Color? color}) => _plusJakarta(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: color ?? textSlate500,
  );

  /// Product price (home) — 18sp, bold, primary.
  static TextStyle productPriceHome() =>
      _plusJakarta(fontSize: 18, fontWeight: FontWeight.w700, color: primary);

  /// Product price (shop) — default size (14sp), bold, primary.
  static TextStyle productPriceShop() =>
      _plusJakarta(fontSize: 14, fontWeight: FontWeight.w700, color: primary);

  /// Occasion label — 11sp, medium.
  static TextStyle occasionLabel({Color? color}) =>
      _plusJakarta(fontSize: 11, fontWeight: FontWeight.w500, color: color);

  /// Nav tab label — 10sp, bold (active) / medium (inactive).
  static TextStyle navLabel({bool active = false, Color? color}) =>
      _plusJakarta(
        fontSize: 10,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        color: color,
      );

  /// Special offer tag — 12sp, bold, uppercase, widest tracking, primary.
  static TextStyle specialOfferTag() => _plusJakarta(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: primary,
    letterSpacing: 2.0,
  );

  /// Body / description text — 14sp, regular, leading-relaxed.
  static TextStyle bodyText({Color? color}) => _plusJakarta(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.625,
  );

  /// Primary pill button text — 16sp, bold, white.
  static TextStyle buttonText() => _plusJakarta(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // ───────────────── ThemeData builders ──────────────────

  /// Light theme for the app.
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primary,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: appBarTitle(),
        iconTheme: const IconThemeData(color: primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: const StadiumBorder(),
          elevation: 4,
          shadowColor: primary30,
          textStyle: buttonText(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide(color: primary50, width: 2),
        ),
        hintStyle: _plusJakarta(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: BorderSide(color: primary5),
        ),
        elevation: 1,
        shadowColor: Colors.black12,
      ),
    );
  }

  /// Dark theme for the app.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSurface: textPrimaryDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: appBarTitle(),
        iconTheme: const IconThemeData(color: primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: navDark,
        selectedItemColor: primary,
        unselectedItemColor: textMutedDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: const StadiumBorder(),
          elevation: 4,
          shadowColor: primary30,
          textStyle: buttonText(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide(color: primary50, width: 2),
        ),
        hintStyle: _plusJakarta(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textMutedDark,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: BorderSide(color: primary5),
        ),
        elevation: 1,
        shadowColor: Colors.black26,
      ),
    );
  }
}
