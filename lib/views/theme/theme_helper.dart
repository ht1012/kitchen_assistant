import 'package:flutter/material.dart';

String _appTheme = "lightCode";
LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors()
  };

  // A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme
  };

  /// Changes the app theme to [_newTheme].
  void changeTheme(String _newTheme) {
    _appTheme = _newTheme;
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get teal_900 => Color(0xFF075B33);
  Color get blue_gray_500 => Color(0xFF697282);
  Color get green_A700 => Color(0xFF00A63D);
  Color get blue_gray_700 => Color(0xFF495565);
  Color get gray_100 => Color(0xFFF0FDF4);
  Color get orange_700 => Color(0xFFD08700);
  Color get yellow_50 => Color(0xFFFDFBE8);
  Color get red_A700 => Color(0xFFE7000A);
  Color get red_50 => Color(0xFFFEF2F2);
  Color get white_A700 => Color(0xFFFFFFFF);
  Color get gray_900 => Color(0xFF101727);
  Color get green_A700_01 => Color(0xFF00C850);
  Color get gray_100_01 => Color(0xFFF2F4F6);
  Color get black_900_19 => Color(0x19000000);
  Color get blue_gray_300 => Color(0xFF99A1AE);
  Color get green_A400 => Color(0xFF05DF72);
  Color get blue_gray_300_01 => Color(0xFF99A1AF);
  Color get red_500 => Color(0xFFFA2B36);

  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get greyCustom => Colors.grey;

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
}
