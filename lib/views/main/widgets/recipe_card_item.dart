import 'package:flutter/material.dart';

import '../../core/utils/image_constant.dart';
import '../../core/utils/size_utils.dart';
import '../../theme/theme_helper.dart';
import '../../theme/text_style_heaper.dart';
import '../../widgets/custom_image_view.dart';
class RecipeCardItem extends StatelessWidget {
  final String imagePath;
  final String rating;
  final String title;
  final String cookingTime;
  final VoidCallback? onTap;

  RecipeCardItem({
    Key? key,
    required this.imagePath,
    required this.rating,
    required this.title,
    required this.cookingTime,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          border: Border.all(color: appTheme.gray_100_01, width: 1.h),
          borderRadius: BorderRadius.circular(24.h),
          boxShadow: [
            BoxShadow(
              color: appTheme.black_900_19,
              offset: Offset(0, 1.h),
              blurRadius: 2.h,
            ),
          ],
        ),
        child: Row(
          children: [
            _buildRecipeImage(),
            SizedBox(width: 12.h),
            _buildRecipeDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage() {
    return Stack(
      children: [
        CustomImageView(
          imagePath: imagePath,
          width: 96.h,
          height: 96.h,
          radius: BorderRadius.circular(16.h),
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 8.h,
          right: 8.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.h),
            decoration: BoxDecoration(
              color: appTheme.green_A700_01,
              borderRadius: BorderRadius.circular(10.h),
            ),
            child: Text(
              rating,
              style: TextStyleHelper.instance.label11RegularInter
                  .copyWith(color: appTheme.white_A700, height: 1.36),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyleHelper.instance.body15RegularInter
                .copyWith(height: 1.27),
          ),
          SizedBox(height: 34.h),
          Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgSvg,
                width: 12.h,
                height: 12.h,
              ),
              SizedBox(width: 4.h),
              Text(
                cookingTime,
                style: TextStyleHelper.instance.label11RegularInter
                    .copyWith(color: appTheme.blue_gray_500, height: 1.27),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
