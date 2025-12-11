import 'package:flutter/material.dart';
import 'package:kitchen_assistant/views/widgets/custom_image_view.dart';
import 'package:kitchen_assistant/views/theme/theme_helper.dart';
import 'package:kitchen_assistant/views/theme/text_style_heaper.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;          // Mục đang được chọn
  final Function(int) onTap;       // Callback khi bấm vào item

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.h),
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        boxShadow: [
          BoxShadow(
            color: appTheme.black_900_19,
            blurRadius: 8.h,
            offset: Offset(0, -2.h),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(index: 0, label: 'Trang chủ', icon: Icons.home_rounded),
          _navItem(index: 1, label: 'Kho nguyên liệu', asset: ImageConstant.imgNavKhoNguynLiu),
          _navItem(index: 2, label: 'Mua sắm', asset: ImageConstant.imgNavMuaSm),
          _navItem(index: 3, label: 'Lập kế hoạch', asset: ImageConstant.imgNavLpKHoch),
          Stack(
            children: [
              _navItem(index: 4, label: 'Thông báo', asset: ImageConstant.imgNavThngBo),
              Positioned(
                top: 2.h,
                right: 4.h,
                child: _notificationDot(),
              )
            ],
          ),
        ],
      ),
    );
  }
  Widget _navItem({
    required int index,
    required String label,
    String? asset,
    IconData? icon,
  }) {
    final bool isActive = index == currentIndex;
    final Color color = isActive ? appTheme.green_A700 : appTheme.blue_gray_300_01;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon != null
              ? Icon(icon, color: color, size: 26.h)
              : CustomImageView(
                  imagePath: asset ?? ImageConstant.imgImageNotFound,
                  width: 26.h,
                  height: 26.h,
                  color: color,
                ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyleHelper.instance.label11RegularInter
                .copyWith(color: color),
          ),
          if (isActive)
            Container(
              margin: EdgeInsets.only(top: 6.h),
              width: 24.h,
              height: 3.h,
              decoration: BoxDecoration(
                color: appTheme.green_A400,
                borderRadius: BorderRadius.circular(6.h),
              ),
            ),
        ],
      ),
    );
  }
  Widget _notificationDot() {
    return Container(
      width: 8.h,
      height: 8.h,
      decoration: BoxDecoration(
        color: appTheme.red_500,
        shape: BoxShape.circle,
      ),
    );
  }
}
