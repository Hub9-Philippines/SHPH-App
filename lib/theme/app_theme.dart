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
          foregroundColor: Colors.white,
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
          foregroundColor: Colors.white,
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
      displayLarge: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 64,
      ),
      displayMedium: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 44,
      ),
      displaySmall: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36,
      ),
      headlineLarge: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28,
      ),
      headlineSmall: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleMedium: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleSmall: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      labelLarge: GoogleFonts.poppins(
        color: data.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      labelMedium: GoogleFonts.poppins(
        color: data.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      labelSmall: GoogleFonts.poppins(
        color: data.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.poppins(
        color: data.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    );
}

class AppThemeData {

  AppThemeData({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.alternate,
    required this.primaryText,
    required this.secondaryText,
    required this.primaryBackground,
    required this.secondaryBackground,
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

  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x140F1828),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Color(0x2E11264A),
      blurRadius: 26,
      offset: Offset(0, 10),
    ),
  ];

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
        'in_progress' || 'in progress' => (statusActive, statusActiveBg),
        'completed' => (statusCompleted, statusCompletedBg),
        'cancelled' => (statusCancelled, statusCancelledBg),
        'pending' => (statusPending, statusPendingBg),
        _ => (statusCompleted, statusCompletedBg),
      };

  factory AppThemeData.light() => AppThemeData(
      primary: const Color(0xFF368EFF),
      secondary: const Color(0xFF39D2C0),
      tertiary: const Color(0xFFEE8B60),
      alternate: const Color(0xFFE0E3E7),
      primaryText: const Color(0xFF14181B),
      secondaryText: const Color(0xFF57636C),
      primaryBackground: const Color(0xFFFFFFFF),
      secondaryBackground: const Color(0xFFF7F7F7),
      accent1: const Color(0x4C4B39EF),
      accent2: const Color(0x4D39D2C0),
      accent3: const Color(0x4DEE8B60),
      accent4: const Color(0xCCFFFFFF),
      success: const Color(0xFF249689),
      warning: const Color(0xFFF9CF58),
      error: const Color(0xFFFF5963),
      info: const Color(0xFFFFFFFF),
      iconBackground: const Color(0xFFE6F0FF),
      primaryLight: const Color(0xFFD4F0EF),
      primaryDark: const Color(0xFF49B8C4),
      primaryBrandText: const Color(0xFF0D6D78),
      surfaceAlt: const Color(0xFFF1F5F9),
      border: const Color(0xFFE2E8F0),
      textTertiary: const Color(0xFF94A3B8),
    );

  factory AppThemeData.dark() => AppThemeData(
      primary: const Color(0xFF368EFF),
      secondary: const Color(0xFF39D2C0),
      tertiary: const Color(0xFFEE8B60),
      alternate: const Color(0xFFE0E3E7),
      primaryText: const Color(0xFFFFFFFF),
      secondaryText: const Color(0xFF95A1AC),
      primaryBackground: const Color(0xFF1D2428),
      secondaryBackground: const Color(0xFF14181B),
      accent1: const Color(0x4C4B39EF),
      accent2: const Color(0x4D39D2C0),
      accent3: const Color(0x4DEE8B60),
      accent4: const Color(0xB2262D34),
      success: const Color(0xFF249689),
      warning: const Color(0xFFF9CF58),
      error: const Color(0xFFFF5963),
      info: const Color(0xFFFFFFFF),
      iconBackground: const Color(0xFFF34966),
      primaryLight: const Color(0xFF1A3D3C),
      primaryDark: const Color(0xFF49B8C4),
      primaryBrandText: const Color(0xFF63CBD6),
      surfaceAlt: const Color(0xFF2A2A3C),
      border: const Color(0xFF3A3A4E),
      textTertiary: const Color(0xFF94A3B8),
    );
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color alternate;
  final Color primaryText;
  final Color secondaryText;
  final Color primaryBackground;
  final Color secondaryBackground;
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
  TextStyle get displayLarge => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 64,
      );
  TextStyle get displayMedium => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 44,
      );
  TextStyle get displaySmall => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36,
      );
  TextStyle get headlineLarge => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      );
  TextStyle get headlineMedium => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28,
      );
  TextStyle get headlineSmall => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      );
  TextStyle get titleLarge => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      );
  TextStyle get titleMedium => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      );
  TextStyle get titleSmall => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      );
  TextStyle get bodyLarge => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      );
  TextStyle get bodyMedium => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      );
  TextStyle get bodySmall => GoogleFonts.poppins(
        color: primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      );
  TextStyle get labelLarge => GoogleFonts.poppins(
        color: secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      );
  TextStyle get labelMedium => GoogleFonts.poppins(
        color: secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      );
  TextStyle get labelSmall => GoogleFonts.poppins(
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
