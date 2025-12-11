import 'package:flutter/material.dart';

import '../../core/utils/size_utils.dart';
import '../../theme/theme_helper.dart';
import '../../theme/text_style_heaper.dart';
class IngredientStatusCard extends StatelessWidget {
  final String count;
  final String label;
  final Color countColor;
  final Color backgroundColor;

  IngredientStatusCard({
    Key? key,
    required this.count,
    required this.label,
    required this.countColor,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124.h,
      padding: EdgeInsets.symmetric(horizontal: 28.h, vertical: 10.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Column(
        spacing: 4.h,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyleHelper.instance.headline24RegularInter
                .copyWith(height: 1.25),
          ),
          Text(
            label,
            style: TextStyleHelper.instance.label11RegularInter
                .copyWith(color: appTheme.blue_gray_700, height: 1.27),
          ),
        ],
      ),
    );
  }
}
