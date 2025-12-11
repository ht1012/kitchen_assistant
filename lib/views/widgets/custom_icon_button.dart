import 'package:flutter/material.dart';

import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import './custom_image_view.dart';
import '../theme/theme_helper.dart';


/**
 * A customizable icon button widget with gradient background, shadow effects, and rounded corners.
 * 
 * @param iconPath - Path to the icon image (required)
 * @param onTap - Callback function when button is tapped
 * @param width - Width of the button
 * @param height - Height of the button  
 * @param padding - Internal padding of the button
 * @param borderRadius - Border radius for rounded corners
 * @param gradientColors - List of colors for gradient background
 * @param shadowColor - Color of the drop shadow
 * @param shadowBlurRadius - Blur radius of the shadow
 * @param shadowOffset - Offset of the shadow
 * @param iconWidth - Width of the icon
 * @param iconHeight - Height of the icon
 */
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    required this.iconPath,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.gradientColors,
    this.shadowColor,
    this.shadowBlurRadius,
    this.shadowOffset,
    this.iconWidth,
    this.iconHeight,
  }) : super(key: key);

  /// Path to the icon image
  final String iconPath;

  /// Callback function when button is tapped
  final VoidCallback? onTap;

  /// Width of the button
  final double? width;

  /// Height of the button
  final double? height;

  /// Internal padding of the button
  final EdgeInsetsGeometry? padding;

  /// Border radius for rounded corners
  final double? borderRadius;

  /// List of colors for gradient background
  final List<Color>? gradientColors;

  /// Color of the drop shadow
  final Color? shadowColor;

  /// Blur radius of the shadow
  final double? shadowBlurRadius;

  /// Offset of the shadow
  final Offset? shadowOffset;

  /// Width of the icon
  final double? iconWidth;

  /// Height of the icon
  final double? iconHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 48.h,
      height: height ?? 48.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ??
              [
                Color(0xFF05DF72),
                appTheme.green_A700_01,
              ],
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? Color(0x19000000),
            blurRadius: shadowBlurRadius ?? 4.h,
            offset: shadowOffset ?? Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: appTheme.transparentCustom,
        borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
          child: Container(
            padding: padding ?? EdgeInsets.all(12.h),
            child: CustomImageView(
              imagePath: iconPath,
              width: iconWidth ?? 24.h,
              height: iconHeight ?? 24.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
