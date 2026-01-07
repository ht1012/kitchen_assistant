import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Recipe.dart';
import '../models/RecipeMatch.dart';
import '../models/virtualPantry/ingredient_model.dart';
import 'dart:convert'; // <--- QUAN TRỌNG: Để dùng được jsonDecode
class SmartRecipeProvider {
  final db = FirebaseFirestore.instance;
  // Hàm lọc theo bộ lọc (Filters)
  Future<List<Recipe>> getRecipesByFilters(Map<String, dynamic> filters) async {
    Query query = db.collection('recipes');

    // 1. Áp dụng các điều kiện lọc
    // Lưu ý: Key của filters phải khớp với tên trường trong Firestore (categories.xxx)
    if (filters['cuisine'] != null) {
      query = query.where('categories.cuisine', isEqualTo: filters['cuisine']);
    }
    if (filters['meal_time'] != null) {
      query = query.where('categories.meal_time', isEqualTo: filters['meal_time']);
    }

    if (filters['cook_time'] != null) {
      query = query.where('categories.cook_time', isEqualTo: filters['cook_time']);
    }


    // 2. Xử lý bộ lọc KHẨU PHẦN ĂN (Range Query)
    // Giả sử filters['servings'] nhận vào chuỗi từ UI: "1 người", "2-4 người", "> 5 người"
    if (filters['servings'] != null) {
      String servingOption = filters['servings'];

      if (servingOption == '1 người') {
        // Tìm chính xác món cho 1 người
        query = query.where('categories.servings', isEqualTo: 1);
      } 
      else if (servingOption == '2-4 người') {
        // Tìm món trong khoảng 2 đến 4
        query = query
            .where('categories.servings', isGreaterThanOrEqualTo: 2)
            .where('categories.servings', isLessThanOrEqualTo: 4);
      } 
      else if (servingOption.contains('> 5 người')) {
        // Tìm món cho 5 người trở lên
        query = query.where('categories.servings', isGreaterThanOrEqualTo: 5);
      }
    }
    // 2. Thực thi query
    try {
      final snapshot = await query.get();
      return snapshot.docs.map((d) => Recipe.fromFirestore(d)).toList();
    } catch (e) {
      print("Lỗi Query: $e");
      return [];
    }
  }
  Future<List<Recipe>> getRecipesForIngredient(String ingredientName) async {
    // BƯỚC 1: Tìm trong Database trước (Ưu tiên tốc độ, miễn phí)
    final snapshot = await db.collection('recipes')
        .where('search_keywords', arrayContains: ingredientName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      print("✅ Tìm thấy trong DB!");
      return snapshot.docs.map((d) => Recipe.fromJson(d.data())).toList();
    }

    // BƯỚC 2: Nếu DB rỗng -> Gọi AI (Chậm hơn chút, tốn phí nhỏ)
    print("🤖 DB chưa có, đang gọi AI sáng tạo...");
    return await _generateRecipeFromAI(ingredientName);
  }

  Future<List<Recipe>> _generateRecipeFromAI(String ingredient) async {
    // Khởi tạo model Gemini
    final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');

    // Prompt yêu cầu trả về JSON chuẩn Schema của bạn
    final prompt = [Content.text('''
      Tôi có nguyên liệu: "$ingredient". 
      Hãy tạo 1 công thức nấu ăn Việt Nam phù hợp.
      Yêu cầu: Trả về JSON thuần túy, không markdown.
      Cấu trúc JSON bắt buộc phải khớp mẫu này:
      {
        "name": "Tên món",
        "ingredients_requirements": [{"id": "...", "amount": 0, "unit": "..."}],
        "steps": ["..."],
        "tags": {...}
      }
    ''')];

    try {
      final response = await model.generateContent(prompt);
      final jsonString = response.text!.replaceAll('```json', '').replaceAll('```', '');
      
      // Parse JSON thành Object Recipe
      // 2. Decode và ép kiểu an toàn
      final Map<String, dynamic> recipeData = Map<String, dynamic>.from(jsonDecode(jsonString));

      // 3. Bổ sung các trường hệ thống mà AI không biết
      final String newId = DateTime.now().millisecondsSinceEpoch.toString();
      recipeData['recipe_id'] = newId; 
      recipeData['is_ai_generated'] = true;
      // Thêm search_keywords để lần sau tìm là thấy ngay
      recipeData['search_keywords'] = [ingredient]; 
      recipeData['created_at'] = FieldValue.serverTimestamp();

      // 4. Tạo đối tượng Recipe từ dữ liệu đã bổ sung
      Recipe newRecipe = Recipe.fromJson(recipeData);

      // BƯỚC 3: Lưu vào DB để làm giàu dữ liệu cho lần sau (Cache)
      // Thêm trường 'is_ai_generated': true để sau này dễ quản lý
     await db.collection('recipes').doc(newId).set(recipeData);

      return [newRecipe];
    } catch (e) {
      print("❌ Lỗi AI: $e");
      return []; // Fallback cuối cùng nếu AI cũng lỗi
    }
  }

  /// So sánh nguyên liệu trong kho với công thức và trả về danh sách RecipeMatch
  /// [pantryIngredients]: Danh sách nguyên liệu trong kho
  /// [filters]: Bộ lọc tùy chọn (cuisine, meal_time, cook_time, servings)
  /// [minMatchPercentage]: Phần trăm match tối thiểu để hiển thị (mặc định 50%)
  Future<List<RecipeMatch>> getRecipesByPantry(
    List<Ingredient> pantryIngredients, {
    Map<String, dynamic>? filters,
    double minMatchPercentage = 80.0,
  }) async {
    // 1. Lấy tất cả công thức (có thể áp dụng filter)
    List<Recipe> allRecipes;
    if (filters != null && filters.isNotEmpty) {
      allRecipes = await getRecipesByFilters(filters);
    } else {
      // Lấy tất cả công thức nếu không có filter
      final snapshot = await db.collection('recipes').get();
      allRecipes = snapshot.docs.map((d) => Recipe.fromFirestore(d)).toList();
    }

    // 2. Tạo map từ tên nguyên liệu trong kho (normalized) để tìm kiếm nhanh
    // Map theo cả tên và ID để match linh hoạt hơn
    final Map<String, Ingredient> pantryMapByName = {};
    final Map<String, Ingredient> pantryMapById = {};
    
    for (var ingredient in pantryIngredients) {
      final normalizedName = _normalizeIngredientName(ingredient.name);
      
      // Map theo tên (normalized)
      if (pantryMapByName.containsKey(normalizedName)) {
        // Cộng dồn số lượng nếu trùng tên
        final existing = pantryMapByName[normalizedName]!;
        pantryMapByName[normalizedName] = Ingredient(
          id: existing.id,
          name: existing.name,
          quantity: existing.quantity + ingredient.quantity,
          unit: existing.unit,
          expirationDate: existing.expirationDate,
          imageUrl: existing.imageUrl,
          categoryId: existing.categoryId,
          categoryName: existing.categoryName,
          householdId: existing.householdId,
        );
      } else {
        pantryMapByName[normalizedName] = ingredient;
      }
      
      // Map theo ID (nếu có)
      if (ingredient.id.isNotEmpty) {
        pantryMapById[ingredient.id] = ingredient;
      }
    }

    // 3. So sánh từng công thức với kho
    List<RecipeMatch> matches = [];
    for (var recipe in allRecipes) {
      final match = _calculateRecipeMatch(recipe, pantryMapByName, pantryMapById);
      if (match.matchPercentage >= minMatchPercentage) {
        matches.add(match);
      }
    }

    // 4. Sắp xếp theo match percentage giảm dần
    matches.sort(RecipeMatch.compareByMatch);

    return matches;
  }

  /// Tính toán độ phù hợp giữa công thức và kho
  RecipeMatch _calculateRecipeMatch(
    Recipe recipe,
    Map<String, Ingredient> pantryMapByName,
    Map<String, Ingredient> pantryMapById,
  ) {
    if (recipe.ingredientsRequirements.isEmpty) {
      return RecipeMatch(
        recipe: recipe,
        matchPercentage: 0.0,
        missingIngredients: [],
        sufficientIngredients: [],
      );
    }

    List<String> sufficientIngredients = [];
    List<String> missingIngredients = [];

    int totalIngredients = recipe.ingredientsRequirements.length;

    for (var required in recipe.ingredientsRequirements) {
      Ingredient? pantryIngredient;
      
      // Ưu tiên tìm theo ID trước (chính xác hơn)
      if (required.id.isNotEmpty && pantryMapById.containsKey(required.id)) {
        pantryIngredient = pantryMapById[required.id];
      } else {
        // Nếu không tìm thấy theo ID, tìm theo tên (normalized)
        final normalizedName = _normalizeIngredientName(required.id);
        pantryIngredient = pantryMapByName[normalizedName];
      }

      if (pantryIngredient == null) {
        // Không có trong kho
        missingIngredients.add(required.name);
      } else {
        // Có trong kho, kiểm tra số lượng
        final requiredAmount = required.amount;
        final availableAmount = pantryIngredient.quantity;

        // Chuyển đổi đơn vị và so sánh số lượng
        final convertedAmount = _convertUnit(
          availableAmount,
          pantryIngredient.unit,
          required.unit,
        );

        if (convertedAmount >= requiredAmount) {
          // Đủ số lượng
          sufficientIngredients.add(required.name);
        } else {
          // Thiếu số lượng
          missingIngredients.add(required.name);
        }
      }
    }

    // Tính phần trăm match
    final exactScore = sufficientIngredients.length;
    final matchPercentage = (exactScore / totalIngredients) * 100;

    return RecipeMatch(
      recipe: recipe,
      matchPercentage: matchPercentage.clamp(0.0, 100.0),
      missingIngredients: missingIngredients,
      sufficientIngredients: sufficientIngredients,
    );
  }

  /// Chuyển đổi đơn vị (ví dụ: kg -> g, l -> ml)
  double _convertUnit(double amount, String fromUnit, String toUnit) {
    if (fromUnit.toLowerCase() == toUnit.toLowerCase()) {
      return amount;
    }

    // Chuyển về cùng đơn vị cơ bản
    final fromLower = fromUnit.toLowerCase();
    final toLower = toUnit.toLowerCase();

    // Nhóm đơn vị khối lượng
    if (['kg', 'kilogram', 'kilograms'].contains(fromLower)) {
      if (['g', 'gram', 'grams'].contains(toLower)) {
        return amount * 1000;
      }
    }
    if (['g', 'gram', 'grams'].contains(fromLower)) {
      if (['kg', 'kilogram', 'kilograms'].contains(toLower)) {
        return amount / 1000;
      }
    }

    // Nhóm đơn vị thể tích
    if (['l', 'liter', 'liters', 'litre', 'litres'].contains(fromLower)) {
      if (['ml', 'milliliter', 'milliliters', 'millilitre', 'millilitres'].contains(toLower)) {
        return amount * 1000;
      }
    }
    if (['ml', 'milliliter', 'milliliters', 'millilitre', 'millilitres'].contains(fromLower)) {
      if (['l', 'liter', 'liters', 'litre', 'litres'].contains(toLower)) {
        return amount / 1000;
      }
    }

    // Các đơn vị tương đương (cái, quả, trái, v.v.) - không cần chuyển đổi
    final equivalentUnits = [
      ['cái', 'quả', 'trái', 'củ', 'nhánh', 'lá', 'bông', 'cây'],
      ['muỗng', 'thìa', 'spoon', 'tablespoon', 'teaspoon'],
      ['chén', 'bát', 'bowl', 'cup'],
    ];

    for (var group in equivalentUnits) {
      if (group.contains(fromLower) && group.contains(toLower)) {
        return amount; // Không cần chuyển đổi
      }
    }

    // Nếu không thể chuyển đổi, trả về số lượng gốc (coi như không tương thích)
    return amount;
  }

  /// Chuẩn hóa tên nguyên liệu để so sánh (lowercase, bỏ dấu, bỏ khoảng trắng thừa)
  String _normalizeIngredientName(String name) {
    // Chuyển về lowercase
    String normalized = name.toLowerCase();
    
    // Bỏ dấu tiếng Việt (có thể mở rộng sau)
    // normalized = _removeVietnameseAccents(normalized);
    
    return normalized;
  }

}