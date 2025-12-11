import 'package:flutter/material.dart';
import '../theme/theme_helper.dart';
import '../core/utils/size_utils.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline28RegularInter => TextStyle(
        fontSize: 28.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: appTheme.teal_900,
      );

  TextStyle get headline24RegularInter => TextStyle(
        fontSize: 24.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body15RegularInter => TextStyle(
        fontSize: 15.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: appTheme.gray_900,
      );

  TextStyle get body14RegularInter => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: appTheme.blue_gray_500,
      );

  TextStyle get body14SemiBoldInter => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: appTheme.gray_900,
      );

  TextStyle get body14BoldInter => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: appTheme.green_A700_01,
      );

  TextStyle get body12RegularInter => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: appTheme.white_A700,
      );

  // Label Styles
  // Small text styles for labels, captions, and hints

  TextStyle get label11RegularInter => TextStyle(
        fontSize: 11.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      );
}
