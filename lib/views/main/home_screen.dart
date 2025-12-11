import 'package:flutter/material.dart';
import 'package:kitchen_assistant/views/theme/text_style_heaper.dart';
import 'package:kitchen_assistant/views/widgets/custom_image_view.dart';

import '../theme/theme_helper.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import 'widgets/ingredient_status_card.dart';
import 'widgets/recipe_card_item.dart';

class MyHome extends StatefulWidget {
  MyHome({super.key});
  final List<Map<String, dynamic>> ingredientStatusList = [
    {
      "count": "6",
      "label": "Tươi",
      "countColor": appTheme.green_A700,
    },
    {
      "count": "2",
      "label": "Sắp hết hạn",
      "countColor": appTheme.orange_700,
      "backgroundColor": appTheme.yellow_50,
    },
    {
      "count": "1",
      "label": "Hết hạn",
      "countColor": appTheme.red_A700,
      "backgroundColor": appTheme.red_50,
    },
  ];

  final List<Map<String, dynamic>> recipeList = [
    {
      "imagePath": ImageConstant.imgFreshGardenSalad,
      "rating": "95%",
      "title": "Salad",
      "cookingTime": "15 min",
    },
    {
      "imagePath": ImageConstant.imgHealthyBuddhaBowl,
      "rating": "87%",
      "title": "Thịt gà xào",
      "cookingTime": "25 min",
    },
    {
      "imagePath": ImageConstant.imgCreamyPastaPrimavera,
      "rating": "82%",
      "title": "Mỳ ý kem",
      "cookingTime": "30 min",
    },
  ];
  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF0FDF4),
                Color(0xFFFFFFFF),
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      _buildQuestion(context),
                      _buildRecipeList(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: appTheme.white_A700,
      padding: EdgeInsets.fromLTRB(10.h, 48.h, 10.h, 8.h),
      child: Column(
        children: [
          Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgCook,
                height: 76.h,
                width: 72.h,
              ),
              SizedBox(width: 12.h),
              Text(
                'Chào buổi sáng',
                style: TextStyleHelper.instance.headline24RegularInter
                    .copyWith(height: 1.21),
              )
            ],
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 3.h),
              child: Text(
                'Tình trạng nguyên liệu',
                style: TextStyleHelper.instance.body14RegularInter
                    .copyWith(height: 1.29),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.ingredientStatusList
                .map(
                  (item) => IngredientStatusCard(
                    count: item["count"],
                    label: item["label"],
                    countColor: item["countColor"],
                    backgroundColor:
                        item["backgroundColor"] ?? appTheme.gray_100,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    return Container(
    );
  }

  Widget _buildRecipeList(BuildContext context) {
    return Container(
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
    );
  }

}