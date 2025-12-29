class Recipe {
  final String id;
  final String recipeName;
  final String description;
  final int prepTime;
  final int cookTime;
  final int servings;
  final int calories;
  final String difficulty;
  final String recipeImage;
  final String videoUrl;
  final String cookingSteps;
  final String householdId;

  Recipe({
    required this.id,
    required this.recipeName,
    required this.description,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.calories,
    required this.difficulty,
    required this.recipeImage,
    required this.videoUrl,
    required this.cookingSteps,
    required this.householdId,
  });

  factory Recipe.fromFirestore(String id, Map<String, dynamic> data) {
    return Recipe(
      id: id,
      recipeName: data['recipe_name'] ?? '',
      description: data['description'] ?? '',
      prepTime: data['prep_time'] ?? 0,
      cookTime: data['cook_time'] ?? 0,
      servings: data['servings'] ?? 1,
      calories: data['calories'] ?? 0,
      difficulty: data['difficulty'] ?? 'Easy',
      recipeImage: data['recipe_image'] ?? '',
      videoUrl: data['video_url'] ?? '',
      cookingSteps: data['cooking_steps'] ?? '',
      householdId: data['household_id'] ?? '',
    );
  }
}