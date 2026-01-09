import 'Recipe.dart';

/// Model để lưu thông tin match giữa Recipe và Pantry
class RecipeMatch {
  final Recipe recipe;
  final double matchPercentage; // 0-100
  final List<String> missingIngredients; // Danh sách nguyên liệu thiếu
  final List<String> sufficientIngredients; // Danh sách nguyên liệu đủ

  RecipeMatch({
    required this.recipe,
    required this.matchPercentage,
    required this.missingIngredients,
    required this.sufficientIngredients,
  });

  /// Sắp xếp theo match percentage giảm dần
  static int compareByMatch(RecipeMatch a, RecipeMatch b) {
    return b.matchPercentage.compareTo(a.matchPercentage);
  }
}

