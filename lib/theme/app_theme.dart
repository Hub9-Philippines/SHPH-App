import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = '__theme_mode__';

// ignore: avoid_classes_with_only_static_members
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

  static TextTheme _buildTextTheme(AppThemeData data, Brightness brightness) =>
      TextTheme(
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
  });

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
