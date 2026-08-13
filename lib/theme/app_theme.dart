import 'package:flutter/material.dart';

class AppTheme {
  static bool _darkMode = false;

  static bool get isDark => _darkMode;

  static void setDarkMode(bool dark) {
    _darkMode = dark;
  }

  // Light palette from serene_covenant_DESIGN.md
  static const Color _surfaceLight = Color(0xFFfcf9f8);
  static const Color _surfaceDimLight = Color(0xFFdcd9d9);
  static const Color _surfaceBrightLight = Color(0xFFfcf9f8);
  static const Color _surfaceContainerLowestLight = Color(0xFFffffff);
  static const Color _surfaceContainerLowLight = Color(0xFFf6f3f2);
  static const Color _surfaceContainerLight = Color(0xFFf0edec);
  static const Color _surfaceContainerHighLight = Color(0xFFebe7e7);
  static const Color _surfaceContainerHighestLight = Color(0xFFe5e2e1);
  static const Color _onSurfaceLight = Color(0xFF1c1b1b);
  static const Color _onSurfaceVariantLight = Color(0xFF414844);
  static const Color _inverseSurfaceLight = Color(0xFF313030);
  static const Color _inverseOnSurfaceLight = Color(0xFFf3f0ef);
  static const Color _outlineLight = Color(0xFF717973);
  static const Color _outlineVariantLight = Color(0xFFc1c8c2);
  static const Color _surfaceTintLight = Color(0xFF3f6653);
  static const Color _primaryLight = Color(0xFF012d1d);
  static const Color _onPrimaryLight = Color(0xFFffffff);
  static const Color _primaryContainerLight = Color(0xFF1b4332);
  static const Color _onPrimaryContainerLight = Color(0xFF86af99);
  static const Color _inversePrimaryLight = Color(0xFFa5d0b9);
  static const Color _secondaryLight = Color(0xFF57615c);
  static const Color _onSecondaryLight = Color(0xFFffffff);
  static const Color _secondaryContainerLight = Color(0xFFd8e2dc);
  static const Color _onSecondaryContainerLight = Color(0xFF5b6560);
  static const Color _tertiaryLight = Color(0xFF162b1a);
  static const Color _onTertiaryLight = Color(0xFFffffff);
  static const Color _tertiaryContainerLight = Color(0xFF2c412e);
  static const Color _onTertiaryContainerLight = Color(0xFF95ad95);
  static const Color _errorLight = Color(0xFFba1a1a);
  static const Color _onErrorLight = Color(0xFFffffff);
  static const Color _errorContainerLight = Color(0xFFffdad6);
  static const Color _onErrorContainerLight = Color(0xFF93000a);
  static const Color _primaryFixedLight = Color(0xFFc1ecd4);
  static const Color _primaryFixedDimLight = Color(0xFFa5d0b9);
  static const Color _onPrimaryFixedLight = Color(0xFF002114);
  static const Color _onPrimaryFixedVariantLight = Color(0xFF274e3d);
  static const Color _secondaryFixedLight = Color(0xFFdbe5df);
  static const Color _secondaryFixedDimLight = Color(0xFFbfc9c3);
  static const Color _onSecondaryFixedLight = Color(0xFF151d1a);
  static const Color _onSecondaryFixedVariantLight = Color(0xFF3f4945);
  static const Color _tertiaryFixedLight = Color(0xFFd0e9cf);
  static const Color _tertiaryFixedDimLight = Color(0xFFb4cdb4);
  static const Color _onTertiaryFixedLight = Color(0xFF0b2010);
  static const Color _onTertiaryFixedVariantLight = Color(0xFF364c39);
  static const Color _backgroundLight = Color(0xFFfcf9f8);
  static const Color _onBackgroundLight = Color(0xFF1c1b1b);
  static const Color _surfaceVariantLight = Color(0xFFe5e2e1);

  // Dark palette (Material 3 dark scheme for a deep green/slate seed)
  static const Color _surfaceDark = Color(0xFF101413);
  static const Color _surfaceDimDark = Color(0xFF101413);
  static const Color _surfaceBrightDark = Color(0xFF363a38);
  static const Color _surfaceContainerLowestDark = Color(0xFF0b0f0e);
  static const Color _surfaceContainerLowDark = Color(0xFF181d1b);
  static const Color _surfaceContainerDark = Color(0xFF1c211f);
  static const Color _surfaceContainerHighDark = Color(0xFF272b29);
  static const Color _surfaceContainerHighestDark = Color(0xFF313634);
  static const Color _onSurfaceDark = Color(0xFFe3e1df);
  static const Color _onSurfaceVariantDark = Color(0xFFb9c5bd);
  static const Color _inverseSurfaceDark = Color(0xFFe3e1df);
  static const Color _inverseOnSurfaceDark = Color(0xFF313030);
  static const Color _outlineDark = Color(0xFF849088);
  static const Color _outlineVariantDark = Color(0xFF444d47);
  static const Color _surfaceTintDark = Color(0xFFa5d0b9);
  static const Color _primaryDark = Color(0xFFa5d0b9);
  static const Color _onPrimaryDark = Color(0xFF0a3827);
  static const Color _primaryContainerDark = Color(0xFF1b4332);
  static const Color _onPrimaryContainerDark = Color(0xFFc1ecd4);
  static const Color _inversePrimaryDark = Color(0xFF1b4332);
  static const Color _secondaryDark = Color(0xFFa5b5ad);
  static const Color _onSecondaryDark = Color(0xFF10211b);
  static const Color _secondaryContainerDark = Color(0xFF1f3b30);
  static const Color _onSecondaryContainerDark = Color(0xFFc1d1c8);
  static const Color _tertiaryDark = Color(0xFFb4cdb4);
  static const Color _onTertiaryDark = Color(0xFF203524);
  static const Color _tertiaryContainerDark = Color(0xFF2c412e);
  static const Color _onTertiaryContainerDark = Color(0xFFd0e9cf);
  static const Color _errorDark = Color(0xFFffb4ab);
  static const Color _onErrorDark = Color(0xFF690005);
  static const Color _errorContainerDark = Color(0xFF93000a);
  static const Color _onErrorContainerDark = Color(0xFFffdad6);
  static const Color _primaryFixedDark = Color(0xFFc1ecd4);
  static const Color _primaryFixedDimDark = Color(0xFFa5d0b9);
  static const Color _onPrimaryFixedDark = Color(0xFF002114);
  static const Color _onPrimaryFixedVariantDark = Color(0xFF274e3d);
  static const Color _secondaryFixedDark = Color(0xFFdbe5df);
  static const Color _secondaryFixedDimDark = Color(0xFFbfc9c3);
  static const Color _onSecondaryFixedDark = Color(0xFF151d1a);
  static const Color _onSecondaryFixedVariantDark = Color(0xFF3f4945);
  static const Color _tertiaryFixedDark = Color(0xFFd0e9cf);
  static const Color _tertiaryFixedDimDark = Color(0xFFb4cdb4);
  static const Color _onTertiaryFixedDark = Color(0xFF0b2010);
  static const Color _onTertiaryFixedVariantDark = Color(0xFF364c39);
  static const Color _backgroundDark = Color(0xFF101413);
  static const Color _onBackgroundDark = Color(0xFFe3e1df);
  static const Color _surfaceVariantDark = Color(0xFF444d47);

  static Color get surface => _darkMode ? _surfaceDark : _surfaceLight;
  static Color get surfaceDim => _darkMode ? _surfaceDimDark : _surfaceDimLight;
  static Color get surfaceBright => _darkMode ? _surfaceBrightDark : _surfaceBrightLight;
  static Color get surfaceContainerLowest => _darkMode ? _surfaceContainerLowestDark : _surfaceContainerLowestLight;
  static Color get surfaceContainerLow => _darkMode ? _surfaceContainerLowDark : _surfaceContainerLowLight;
  static Color get surfaceContainer => _darkMode ? _surfaceContainerDark : _surfaceContainerLight;
  static Color get surfaceContainerHigh => _darkMode ? _surfaceContainerHighDark : _surfaceContainerHighLight;
  static Color get surfaceContainerHighest => _darkMode ? _surfaceContainerHighestDark : _surfaceContainerHighestLight;
  static Color get onSurface => _darkMode ? _onSurfaceDark : _onSurfaceLight;
  static Color get onSurfaceVariant => _darkMode ? _onSurfaceVariantDark : _onSurfaceVariantLight;
  static Color get inverseSurface => _darkMode ? _inverseSurfaceDark : _inverseSurfaceLight;
  static Color get inverseOnSurface => _darkMode ? _inverseOnSurfaceDark : _inverseOnSurfaceLight;
  static Color get outline => _darkMode ? _outlineDark : _outlineLight;
  static Color get outlineVariant => _darkMode ? _outlineVariantDark : _outlineVariantLight;
  static Color get surfaceTint => _darkMode ? _surfaceTintDark : _surfaceTintLight;
  static Color get primary => _darkMode ? _primaryDark : _primaryLight;
  static Color get onPrimary => _darkMode ? _onPrimaryDark : _onPrimaryLight;
  static Color get primaryContainer => _darkMode ? _primaryContainerDark : _primaryContainerLight;
  static Color get onPrimaryContainer => _darkMode ? _onPrimaryContainerDark : _onPrimaryContainerLight;
  static Color get inversePrimary => _darkMode ? _inversePrimaryDark : _inversePrimaryLight;
  static Color get secondary => _darkMode ? _secondaryDark : _secondaryLight;
  static Color get onSecondary => _darkMode ? _onSecondaryDark : _onSecondaryLight;
  static Color get secondaryContainer => _darkMode ? _secondaryContainerDark : _secondaryContainerLight;
  static Color get onSecondaryContainer => _darkMode ? _onSecondaryContainerDark : _onSecondaryContainerLight;
  static Color get tertiary => _darkMode ? _tertiaryDark : _tertiaryLight;
  static Color get onTertiary => _darkMode ? _onTertiaryDark : _onTertiaryLight;
  static Color get tertiaryContainer => _darkMode ? _tertiaryContainerDark : _tertiaryContainerLight;
  static Color get onTertiaryContainer => _darkMode ? _onTertiaryContainerDark : _onTertiaryContainerLight;
  static Color get error => _darkMode ? _errorDark : _errorLight;
  static Color get onError => _darkMode ? _onErrorDark : _onErrorLight;
  static Color get errorContainer => _darkMode ? _errorContainerDark : _errorContainerLight;
  static Color get onErrorContainer => _darkMode ? _onErrorContainerDark : _onErrorContainerLight;
  static Color get primaryFixed => _darkMode ? _primaryFixedDark : _primaryFixedLight;
  static Color get primaryFixedDim => _darkMode ? _primaryFixedDimDark : _primaryFixedDimLight;
  static Color get onPrimaryFixed => _darkMode ? _onPrimaryFixedDark : _onPrimaryFixedLight;
  static Color get onPrimaryFixedVariant => _darkMode ? _onPrimaryFixedVariantDark : _onPrimaryFixedVariantLight;
  static Color get secondaryFixed => _darkMode ? _secondaryFixedDark : _secondaryFixedLight;
  static Color get secondaryFixedDim => _darkMode ? _secondaryFixedDimDark : _secondaryFixedDimLight;
  static Color get onSecondaryFixed => _darkMode ? _onSecondaryFixedDark : _onSecondaryFixedLight;
  static Color get onSecondaryFixedVariant => _darkMode ? _onSecondaryFixedVariantDark : _onSecondaryFixedVariantLight;
  static Color get tertiaryFixed => _darkMode ? _tertiaryFixedDark : _tertiaryFixedLight;
  static Color get tertiaryFixedDim => _darkMode ? _tertiaryFixedDimDark : _tertiaryFixedDimLight;
  static Color get onTertiaryFixed => _darkMode ? _onTertiaryFixedDark : _onTertiaryFixedLight;
  static Color get onTertiaryFixedVariant => _darkMode ? _onTertiaryFixedVariantDark : _onTertiaryFixedVariantLight;
  static Color get background => _darkMode ? _backgroundDark : _backgroundLight;
  static Color get onBackground => _darkMode ? _onBackgroundDark : _onBackgroundLight;
  static Color get surfaceVariant => _darkMode ? _surfaceVariantDark : _surfaceVariantLight;

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: dark ? _primaryDark : _primaryLight,
        onPrimary: dark ? _onPrimaryDark : _onPrimaryLight,
        primaryContainer: dark ? _primaryContainerDark : _primaryContainerLight,
        onPrimaryContainer: dark ? _onPrimaryContainerDark : _onPrimaryContainerLight,
        secondary: dark ? _secondaryDark : _secondaryLight,
        onSecondary: dark ? _onSecondaryDark : _onSecondaryLight,
        secondaryContainer: dark ? _secondaryContainerDark : _secondaryContainerLight,
        onSecondaryContainer: dark ? _onSecondaryContainerDark : _onSecondaryContainerLight,
        tertiary: dark ? _tertiaryDark : _tertiaryLight,
        onTertiary: dark ? _onTertiaryDark : _onTertiaryLight,
        tertiaryContainer: dark ? _tertiaryContainerDark : _tertiaryContainerLight,
        onTertiaryContainer: dark ? _onTertiaryContainerDark : _onTertiaryContainerLight,
        error: dark ? _errorDark : _errorLight,
        onError: dark ? _onErrorDark : _onErrorLight,
        errorContainer: dark ? _errorContainerDark : _errorContainerLight,
        onErrorContainer: dark ? _onErrorContainerDark : _onErrorContainerLight,
        surface: dark ? _surfaceDark : _surfaceLight,
        onSurface: dark ? _onSurfaceDark : _onSurfaceLight,
        surfaceContainerLowest: dark ? _surfaceContainerLowestDark : _surfaceContainerLowestLight,
        surfaceContainerLow: dark ? _surfaceContainerLowDark : _surfaceContainerLowLight,
        surfaceContainer: dark ? _surfaceContainerDark : _surfaceContainerLight,
        surfaceContainerHigh: dark ? _surfaceContainerHighDark : _surfaceContainerHighLight,
        surfaceContainerHighest: dark ? _surfaceContainerHighestDark : _surfaceContainerHighestLight,
        onSurfaceVariant: dark ? _onSurfaceVariantDark : _onSurfaceVariantLight,
        outline: dark ? _outlineDark : _outlineLight,
        outlineVariant: dark ? _outlineVariantDark : _outlineVariantLight,
        inverseSurface: dark ? _inverseSurfaceDark : _inverseSurfaceLight,
        inversePrimary: dark ? _inversePrimaryDark : _inversePrimaryLight,
        surfaceTint: dark ? _surfaceTintDark : _surfaceTintLight,
        primaryFixed: dark ? _primaryFixedDark : _primaryFixedLight,
        primaryFixedDim: dark ? _primaryFixedDimDark : _primaryFixedDimLight,
        onPrimaryFixed: dark ? _onPrimaryFixedDark : _onPrimaryFixedLight,
        onPrimaryFixedVariant: dark ? _onPrimaryFixedVariantDark : _onPrimaryFixedVariantLight,
        secondaryFixed: dark ? _secondaryFixedDark : _secondaryFixedLight,
        secondaryFixedDim: dark ? _secondaryFixedDimDark : _secondaryFixedDimLight,
        onSecondaryFixed: dark ? _onSecondaryFixedDark : _onSecondaryFixedLight,
        onSecondaryFixedVariant: dark ? _onSecondaryFixedVariantDark : _onSecondaryFixedVariantLight,
        tertiaryFixed: dark ? _tertiaryFixedDark : _tertiaryFixedLight,
        tertiaryFixedDim: dark ? _tertiaryFixedDimDark : _tertiaryFixedDimLight,
        onTertiaryFixed: dark ? _onTertiaryFixedDark : _onTertiaryFixedLight,
        onTertiaryFixedVariant: dark ? _onTertiaryFixedVariantDark : _onTertiaryFixedVariantLight,
      ),
      scaffoldBackgroundColor: dark ? _surfaceDark : _surfaceLight,
      textTheme: _buildTextTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(dark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(dark),
      dividerColor: dark ? _outlineVariantDark : _outlineVariantLight,
    );
  }

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 48,
        fontWeight: FontWeight.w600,
        height: 56 / 48,
        letterSpacing: -0.02,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.01,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 32 / 24,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        letterSpacing: 0.01,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: 0.01,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.05,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        letterSpacing: 0.01,
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(bool dark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: dark ? _surfaceContainerLowDark : _surfaceContainerLowLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dark ? _primaryContainerDark : _primaryContainerLight, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(bool dark) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: dark ? _primaryContainerDark : _primaryContainerLight,
        foregroundColor: dark ? _onPrimaryDark : _onPrimaryLight,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(bool dark) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: dark ? _onSurfaceDark : _onSurfaceLight,
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: dark ? _outlineVariantDark : _outlineVariantLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static BoxShadow get ambientShadow => BoxShadow(
    color: const Color(0xFF000000).withValues(alpha: _darkMode ? 0.18 : 0.04),
    blurRadius: 30,
    offset: const Offset(0, 10),
  );
}