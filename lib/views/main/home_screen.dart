import 'package:flutter/material.dart';
import '../theme/theme_helper.dart';
import '../core/utils/image_constant.dart';
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
      body: Container(
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
          )
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeaderSection(context),
                    _buildQuestionSection(context),
                    _buildRecipeListSection(context),
                  ],
                ),
              )
            )
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }
}

Widget _buildHeaderSection(BuildContext context) {
  return Container(
  );
}
Widget _buildQuestionSection(BuildContext context) {
  return Container(
  );
}
Widget _buildRecipeListSection(BuildContext context) {
  return Container(
  );
}
Widget _buildBottomNavigation(BuildContext context) {
  return Container(
  );
}