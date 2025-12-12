import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_image_view.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final List<Map<String, dynamic>> _ingredientStatusList = [
    {"count": "6", "label": "Tươi", "countColor": Color(0xFF00A63D)},
    {
      "count": "2",
      "label": "Sắp hết hạn",
      "countColor": Color(0xFFD08700),
      "backgroundColor": Color(0xFFFDFBE8),
    },
    {
      "count": "1",
      "label": "Hết hạn",
      "countColor": Color(0xFFE7000A),
      "backgroundColor": Color(0xFFFEF2F2),
    },
  ];

  final List<Map<String, dynamic>> _recipeList = [
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

  int _currentIndex = 0;

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
              colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF)],
              stops: [0.0, 1.0],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _Header(ingredientStatusList: _ingredientStatusList),
                      const _Question(),
                      _RecipeList(recipeList: _recipeList),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.ingredientStatusList});

  final List<Map<String, dynamic>> ingredientStatusList;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.fromLTRB(10, 48, 10, 8),
      child: Column(
        children: [
          Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgCook,
                height: 76,
                width: 72,
              ),
              const SizedBox(width: 12),
              Text(
                'Chào buổi sáng',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  height: 1.21,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Text(
                'Tình trạng nguyên liệu',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  color: Color(0xFF697282),
                  height: 1.29,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ingredientStatusList
                .map(
                  (item) => _IngredientStatusCard(
                    count: item["count"],
                    label: item["label"],
                    countColor: item["countColor"],
                    backgroundColor:
                        item["backgroundColor"] ?? const Color(0xFFF0FDF4),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn muốn nấu gì hôm nay?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Color(0xFF101727),
                  height: 1.29,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
          Text(
            'Các gợi ý khác',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              color: Color(0xFF00C850),
              height: 1.29,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeList extends StatelessWidget {
  const _RecipeList({required this.recipeList});

  final List<Map<String, dynamic>> recipeList;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (int i = 0; i < recipeList.length; i++) ...[
            _RecipeCardItem(
              imagePath: recipeList[i]["imagePath"],
              rating: recipeList[i]["rating"],
              title: recipeList[i]["title"],
              cookingTime: recipeList[i]["cookingTime"],
            ),
            if (i < recipeList.length - 1) const SizedBox(height: 12),
          ]
        ],
      ),
    );
  }
}

class _IngredientStatusCard extends StatelessWidget {
  const _IngredientStatusCard({
    required this.count,
    required this.label,
    required this.countColor,
    required this.backgroundColor,
  });

  final String count;
  final String label;
  final Color countColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
              color: Color(0xFF495565),
              height: 1.27,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCardItem extends StatelessWidget {
  const _RecipeCardItem({
    required this.imagePath,
    required this.rating,
    required this.title,
    required this.cookingTime,
    this.onTap,
  });

  final String imagePath;
  final String rating;
  final String title;
  final String cookingTime;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFFF2F4F6), width: 1),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0x19000000),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            _RecipeImage(imagePath: imagePath, rating: rating),
            const SizedBox(width: 12),
            _RecipeDetails(title: title, cookingTime: cookingTime),
          ],
        ),
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  const _RecipeImage({required this.imagePath, required this.rating});

  final String imagePath;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomImageView(
          imagePath: imagePath,
          width: 96,
          height: 96,
          radius: BorderRadius.circular(16),
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00C850),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              rating,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
                color: Color(0xFFFFFFFF),
                height: 1.36,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipeDetails extends StatelessWidget {
  const _RecipeDetails({required this.title, required this.cookingTime});

  final String title;
  final String cookingTime;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
              color: Color(0xFF101727),
              height: 1.27,
            ),
          ),
          const SizedBox(height: 34),
          Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgSvg,
                width: 12,
                height: 12,
              ),
              const SizedBox(width: 4),
              Text(
                cookingTime,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  color: Color(0xFF697282),
                  height: 1.27,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}