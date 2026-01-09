import 'package:cloud_firestore/cloud_firestore.dart';

// 1. Enum độ khó (Để code chặt chẽ hơn là dùng String lỏng lẻo)
enum Difficulty { easy, medium, hard }

// Hàm chuyển đổi từ String sang Enum và ngược lại
Difficulty _parseDifficulty(String value) {
  switch (value.toLowerCase()) {
    case 'dễ': return Difficulty.easy;
    case 'trung bình': return Difficulty.medium;
    case 'khó': return Difficulty.hard;
    default: return Difficulty.medium; // Mặc định nếu lỗi
  }
}

String _difficultyToString(Difficulty difficulty) {
  switch (difficulty) {
    case Difficulty.easy: return 'dễ';
    case Difficulty.medium: return 'trung bình';
    case Difficulty.hard: return 'khó';
  }
}

// ---------------------------------------------------------------------------

// 2. Class Nguyên Liệu (IngredientRequirement)
class IngredientRequirement {
  final String id;
  final String name;
  final double amount; // Dùng double để chứa số lẻ (ví dụ 0.5 kg)
  final String unit;

  IngredientRequirement({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
  });

  // Đọc từ JSON
  factory IngredientRequirement.fromJson(Map<String, dynamic> json) {
    return IngredientRequirement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
    );
  }

  // Ghi ra JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }
}

// ---------------------------------------------------------------------------

// 3. Class Danh Mục (RecipeCategories)
class RecipeCategories {
  final String cuisine;   // vietnam, a, au...
  final String mealTime;  // sang, trua, toi...
  final String cookTime;  // 20den35
  final int servings;     // 4

  RecipeCategories({
    required this.cuisine,
    required this.mealTime,
    required this.cookTime,
    required this.servings,
  });

  factory RecipeCategories.fromJson(Map<String, dynamic> json) {
    return RecipeCategories(
      cuisine: json['cuisine'] ?? 'vietnam',
      mealTime: json['meal_time'] ?? '',
      cookTime: json['cook_time'] ?? '',
      servings: (json['servings'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cuisine': cuisine,
      'meal_time': mealTime,
      'cook_time': cookTime,
      'servings': servings,
    };
  }
}

// ---------------------------------------------------------------------------

// 4. Class Chính (Recipe)
class Recipe {
  final String recipeId;
  final String recipeName;
  final String description;
  final Difficulty difficulty;
  final RecipeCategories categories;
  final int calories;
  final int prepTime; // Phút
  final String? recipeImage; // Có thể null
  final String? videoUrl;    // Có thể null
  final List<IngredientRequirement> ingredientsRequirements;
  final List<String> steps;
  
  // Thêm biến để hỗ trợ AI generate nếu cần sau này
  final bool isAiGenerated; 

  Recipe({
    required this.recipeId,
    required this.recipeName,
    required this.description,
    required this.difficulty,
    required this.categories,
    required this.calories,
    required this.prepTime,
    this.recipeImage,
    this.videoUrl,
    required this.ingredientsRequirements,
    required this.steps,
    this.isAiGenerated = false,
  });

  // --- Factory: Đọc dữ liệu từ Firebase Firestore ---
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipe_id'] ?? '',
      recipeName: json['recipe_name'] ?? 'Món chưa đặt tên',
      description: json['description'] ?? '',
      
      // Xử lý Enum độ khó
      difficulty: _parseDifficulty(json['difficulty'] ?? 'trung bình'),
      
      // Xử lý Object con Categories
      categories: RecipeCategories.fromJson(json['categories'] ?? {}),
      
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      prepTime: (json['prep_time'] as num?)?.toInt() ?? 0,
      
      recipeImage: json['recipe_image'],
      videoUrl: json['video_url'],
      
      // Xử lý List Object Nguyên liệu
      ingredientsRequirements: (json['ingredients_requirements'] as List<dynamic>?)
          ?.map((e) => IngredientRequirement.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
          
      // Xử lý List String Các bước
      steps: (json['steps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      
      isAiGenerated: json['is_ai_generated'] ?? false,
    );
  }
  
  // Factory phụ để đọc từ DocumentSnapshot của Firebase tiện lợi hơn
  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Gán ID của document vào model luôn nếu recipe_id trong data bị rỗng
    data['recipe_id'] = data['recipe_id'] ?? doc.id; 
    return Recipe.fromJson(data);
  }

  // --- Method: Chuyển đổi thành JSON để lưu xuống Database ---
  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'recipe_name': recipeName,
      'description': description,
      'difficulty': _difficultyToString(difficulty), // Chuyển Enum về String
      'categories': categories.toJson(), // Gọi hàm toJson của con
      'calories': calories,
      'prep_time': prepTime,
      'recipe_image': recipeImage,
      'video_url': videoUrl,
      'ingredients_requirements': ingredientsRequirements.map((e) => e.toJson()).toList(),
      'steps': steps,
      'is_ai_generated': isAiGenerated,
      
      // Lưu thêm trường này để tìm kiếm như đã bàn ở các phần trước
      'search_keywords': ingredientsRequirements.map((e) => e.id).toList(), 
    };
  }
}