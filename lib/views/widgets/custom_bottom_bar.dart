import 'package:flutter/material.dart';

import '../core/utils/size_utils.dart';
import './custom_image_view.dart';
import '../theme/theme_helper.dart';
import '../theme/text_style_heaper.dart';

/**
 * CustomBottomBar - A customizable bottom navigation bar component
 * 
 * Features:
 * - Support for active/inactive states with gradient styling
 * - Badge notifications on tabs
 * - Flexible tab configuration
 * - Responsive design with proper scaling
 * 
 * @param bottomBarItemList List of bottom bar items to display
 * @param selectedIndex Currently selected tab index
 * @param onChanged Callback when tab is tapped, returns selected index
 */
class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({
    Key? key,
    required this.bottomBarItemList,
    required this.onChanged,
    this.selectedIndex = 0,
  }) : super(key: key);

  /// List of bottom bar items with their properties
  final List<CustomBottomBarItem> bottomBarItemList;

  /// Current selected index of the bottom bar
  final int selectedIndex;

  /// Callback function triggered when a bottom bar item is tapped
  final Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22.h, 8.h, 22.h, 8.h),
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        border: Border(
          top: BorderSide(
            color: appTheme.gray_100_01,
            width: 1.h,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(bottomBarItemList.length, (index) {
          final isSelected = selectedIndex == index;
          final item = bottomBarItemList[index];

          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              child: _buildBottomBarItem(item, isSelected),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBarItem(CustomBottomBarItem item, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48.h,
              height: 48.h,
              padding: EdgeInsets.all(12.h),
              decoration: isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(16.h),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF05DF72), Color(0xFF00C850)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appTheme.black_900_19,
                          offset: Offset(0, 2.h),
                          blurRadius: 4.h,
                        ),
                      ],
                    )
                  : null,
              child: CustomImageView(
                imagePath: item.icon,
                width: 20.h,
                height: 20.h,
              ),
            ),
            if (item.badgeCount != null && item.badgeCount! > 0)
              Positioned(
                top: -2.h,
                right: -2.h,
                child: Container(
                  width: 20.h,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: appTheme.red_500,
                    borderRadius: BorderRadius.circular(10.h),
                    border: Border.all(
                      color: appTheme.white_A700,
                      width: 2.h,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.badgeCount.toString(),
                      style: TextStyleHelper.instance.body12RegularInter,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          item.title,
          style: TextStyleHelper.instance.label11RegularInter.copyWith(
              color: isSelected ? Color(0xFF00A63D) : appTheme.blue_gray_300),
        ),
      ],
    );
  }
}

/// Item data model for custom bottom bar
class CustomBottomBarItem {
  CustomBottomBarItem({
    required this.icon,
    required this.title,
    required this.routeName,
    this.badgeCount,
  });

  /// Path to the icon image
  final String icon;

  /// Title text shown below the icon
  final String title;

  /// Route name for navigation
  final String routeName;

  /// Badge count for notifications (optional)
  final int? badgeCount;
}
