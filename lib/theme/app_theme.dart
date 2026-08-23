import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = '__theme_mode__';

class AppTheme {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(_themeModeKey);
    return darkMode == null
        ? ThemeMode.light
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      _prefs?.remove(_themeModeKey);
    } else {
      _prefs?.setBool(_themeModeKey, mode == ThemeMode.dark);
    }
  }

  static AppThemeData of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppThemeData.dark()
        : AppThemeData.light();
  }

  static ThemeData lightTheme() {
    final data = AppThemeData.light();
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: false,
      colorScheme: ColorScheme.light(
        primary: data.primary,
        secondary: data.secondary,
        tertiary: data.tertiary,
        error: data.error,
        surface: data.primaryBackground,
        onSurface: data.primaryText,
      ),
      scaffoldBackgroundColor: data.primaryBackground,
      textTheme: _buildTextTheme(data, Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: data.primaryBackground,
        foregroundColor: data.primaryText,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: data.primaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: data.primary,
          foregroundColor: data.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: data.secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.alternate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.alternate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.error),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final data = AppThemeData.dark();
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: false,
      colorScheme: ColorScheme.dark(
        primary: data.primary,
        secondary: data.secondary,
        tertiary: data.tertiary,
        error: data.error,
        surface: data.primaryBackground,
        onSurface: data.primaryText,
      ),
      scaffoldBackgroundColor: data.primaryBackground,
      textTheme: _buildTextTheme(data, Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: data.primaryBackground,
        foregroundColor: data.primaryText,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: data.primaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: data.primary,
          foregroundColor: data.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: data.secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.alternate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.alternate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.error),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(AppThemeData data, Brightness brightness) => TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 64,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 44,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        color: data.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        color: data.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        color: data.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        color: data.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    );
}

class AppThemeData {

  AppThemeData({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.tertiary,
    required this.alternate,
    required this.primaryText,
    required this.secondaryText,
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.bgPage,
    required this.accent1,
    required this.accent2,
    required this.accent3,
    required this.accent4,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.iconBackground,
    required this.primaryLight,
    required this.primaryDark,
    required this.primaryBrandText,
    required this.surfaceAlt,
    required this.border,
    required this.textTertiary,
  });

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 16;
  static const double radiusCard = 24;
  static const double radiusPill = 9999;

  // Tab-screen layout grid (Explore / Bookings / Messages): 16px horizontal
  // margins and card insets, 24px between standalone page blocks, 12px
  // carousel gutters. Use these instead of raw spacing literals so the
  // screens cannot drift apart again.
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;

  static const double containerNarrow = 560;
  static const double containerReadable = 760;
  static const double containerWide = 1100;
  static const double containerDashboard = 1200;

  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x0F10264A),
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1211264A),
      blurRadius: 16,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x140F1828),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x2E11264A),
      blurRadius: 26,
      offset: Offset(0, 10),
    ),
  ];

  static const Color star = Color(0xFFFFC107);

  // Profile/Settings menu accents (tinted-icon rows). Single source so both
  // screens share one dual-tone icon system and dark mode stays consistent.
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentSlate = Color(0xFF64748B);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentPurple = Color(0xFF7C5CFC);
  static const Color accentYellow = Color(0xFFF59E0B);
  static const Color accentTeal = Color(0xFF0D9488);
  static const Color accentSky = Color(0xFF0EA5E9);
  static const Color accentNavy = Color(0xFF1E3A8A);
  static const Color accentBlueGray = Color(0xFF475569);
  static const Color destructiveCrimson = Color(0xFFE11D48);

  // Booking lifecycle action colors (list cards, tracking, confirmation).
  // Primary actions use royal blue; success/complete states use brand teal;
  // destructive/cancel affordances use soft red (distinct from `error`,
  // which stays reserved for form/validation errors). Pending/warning
  // highlights reuse [accentYellow] (amber #F59E0B).
  static const Color actionPrimary = accentNavy;
  static const Color successTeal = Color(0xFF0D808A);
  static const Color destructiveSoft = Color(0xFFEF4444);

  // Brand gradients owned by the theme (white text sits on both, identical
  // across light/dark by design).
  static const List<Color> profileHeroGradient = [
    Color(0xFF0D808A),
    Color(0xFF26C6DA),
  ];
  static const List<Color> settingsBannerGradient = [
    Color(0xFF17212B),
    Color(0xFF23384D),
    Color(0xFF2F5368),
  ];

  // Marketing surface colors (Explore banners/badges) — single source so
  // dark mode and future campaign swaps stay centralized.
  static const List<Color> promoGradient = [
    Color(0xFF1C6DD0),
    Color(0xFF368EFF),
  ];
  static const Color promoCta = Color(0xFF0F3D91);
  static const List<Color> referralGradient = [
    Color(0xFF5B2E91),
    Color(0xFF7C4DBE),
  ];
  static const Color ratingBadgeGreen = Color(0xFF16A34A);
  static const Color ratingBadgeGreenBg = Color(0xFFE7F6EC);

  // Status pill colors (matching web --shph-status-* tokens)
  static const Color statusConfirmed = Color(0xFF0D6D78);
  static const Color statusConfirmedBg = Color(0xFFD4F0EF);
  static const Color statusActive = Color(0xFF166534);
  static const Color statusActiveBg = Color(0xFFE7F6EC);
  static const Color statusCompleted = Color(0xFF475569);
  static const Color statusCompletedBg = Color(0xFFEEF1F5);
  static const Color statusCancelled = Color(0xFFB91C1C);
  static const Color statusCancelledBg = Color(0xFFFDE9E9);
  static const Color statusPending = Color(0xFF92400E);
  static const Color statusPendingBg = Color(0xFFFDF0DD);

  static (Color text, Color bg) statusColors(String status) => switch (status) {
        'confirmed' => (statusConfirmed, statusConfirmedBg),
        'en_route' || 'arrived' || 'in_progress' || 'in progress' || 'on_site' =>
            (statusActive, statusActiveBg),
        'completed' => (statusCompleted, statusCompletedBg),
        'cancelled' || 'disputed' => (statusCancelled, statusCancelledBg),
        'pending' || 'inquiry' || 'searching' => (statusPending, statusPendingBg),
        _ => (statusCompleted, statusCompletedBg),
      };

  factory AppThemeData.light() => AppThemeData(
      primary: const Color(0xFF1E3A8A),
      onPrimary: const Color(0xFFFFFFFF),
      secondary: const Color(0xFF39D2C0),
      tertiary: const Color(0xFFEE8B60),
      alternate: const Color(0xFFE0E3E7),
      primaryText: const Color(0xFF0F172A),
      secondaryText: const Color(0xFF64748B),
      primaryBackground: const Color(0xFFFFFFFF),
      secondaryBackground: const Color(0xFFF7F7F7),
      bgPage: const Color(0xFFF8FAFC),
      accent1: const Color(0x4C4B39EF),
      accent2: const Color(0x4D39D2C0),
      accent3: const Color(0x4DEE8B60),
      accent4: const Color(0xCCFFFFFF),
      success: const Color(0xFF249689),
      warning: const Color(0xFFF9CF58),
      error: const Color(0xFFDC2626),
      info: const Color(0xFF1E3A8A),
      iconBackground: const Color(0xFFD4F0EF),
      primaryLight: const Color(0xFFD4F0EF),
      primaryDark: const Color(0xFF49B8C4),
      primaryBrandText: const Color(0xFF0D6D78),
      surfaceAlt: const Color(0xFFF1F5F9),
      border: const Color(0xFFE2E8F0),
      textTertiary: const Color(0xFF94A3B8),
    );

  factory AppThemeData.dark() => AppThemeData(
      primary: const Color(0xFF1E3A8A),
      onPrimary: const Color(0xFFFFFFFF),
      secondary: const Color(0xFF39D2C0),
      tertiary: const Color(0xFFEE8B60),
      alternate: const Color(0xFFE0E3E7),
      primaryText: const Color(0xFFFFFFFF),
      secondaryText: const Color(0xFF95A1AC),
      primaryBackground: const Color(0xFF1D2428),
      secondaryBackground: const Color(0xFF14181B),
      bgPage: const Color(0xFF0F172A),
      accent1: const Color(0x4C4B39EF),
      accent2: const Color(0x4D39D2C0),
      accent3: const Color(0x4DEE8B60),
      accent4: const Color(0xB2262D34),
      success: const Color(0xFF249689),
      warning: const Color(0xFFF9CF58),
      error: const Color(0xFFDC2626),
      info: const Color(0xFF1E3A8A),
      iconBackground: const Color(0xFFF34966),
      primaryLight: const Color(0xFF1A3D3C),
      primaryDark: const Color(0xFF49B8C4),
      primaryBrandText: const Color(0xFF63CBD6),
      surfaceAlt: const Color(0xFF2A2A3C),
      border: const Color(0xFF3A3A4E),
      textTertiary: const Color(0xFF94A3B8),
    );
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color tertiary;
  final Color alternate;
  final Color primaryText;
  final Color secondaryText;
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color bgPage;
  final Color accent1;
  final Color accent2;
  final Color accent3;
  final Color accent4;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color iconBackground;
  final Color primaryLight;
  final Color primaryDark;
  final Color primaryBrandText;
  final Color surfaceAlt;
  final Color border;
  final Color textTertiary;

  // Typography getters for compatibility with FlutterFlow theme
  TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 64,
      );
  TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 44,
      );
  TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36,
      );
  TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      );
  TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28,
      );
  TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      );
  TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      );
  TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      );
  TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      );
  TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      );
  TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      );
  TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        color: primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      );
  TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        color: secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      );
  TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        color: secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      );
  TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        color: secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12,
  );
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    final resolvedFont = useGoogleFonts && fontFamily != null
        ? GoogleFonts.getFont(
            fontFamily,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
          )
        : font;

    return resolvedFont != null
        ? resolvedFont.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}
