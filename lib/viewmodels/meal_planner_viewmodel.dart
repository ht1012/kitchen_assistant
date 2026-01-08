import 'package:flutter/material.dart';
import 'package:kitchen_assistant/models/meal_plan_model.dart';
import 'package:kitchen_assistant/models/Recipe.dart';
import 'package:kitchen_assistant/models/RecipeMatch.dart';
import 'package:kitchen_assistant/models/virtualPantry/ingredient_model.dart';
import 'package:kitchen_assistant/services/meal_plan_service.dart';
import 'package:kitchen_assistant/services/ai_recipe_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlannerViewModel extends ChangeNotifier {
  final MealPlanService _mealPlanService;
  final SmartRecipeProvider _recipeProvider;
  final _db = FirebaseFirestore.instance;

  MealPlannerViewModel(this._mealPlanService, this._recipeProvider);

  // Lấy meal plans theo tuần
  Stream<List<MealPlan>> getWeeklyPlans(String householdId, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return _mealPlanService.getMealPlansByWeek(householdId, weekStart, weekEnd);
  }

  // Lấy tất cả recipes của household
  Stream<List<Recipe>> getRecipesByHousehold(String householdId) {
    return _db
        .collection('recipes')
        .where('household_id', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList());
  }

  // Lấy tất cả recipes (không phân biệt household)
  Stream<List<Recipe>> getAllRecipes() {
    return _db
        .collection('recipes')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList());
  }

  // Lấy recipe theo ID
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final doc = await _db.collection('recipes').doc(recipeId).get();
      if (doc.exists) {
        return Recipe.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Lỗi lấy recipe: $e');
      return null;
    }
  }

  // Lấy nguyên liệu trong kho của household
  Future<List<Ingredient>> getPantryIngredients(String householdId) async {
    try {
      final snapshot = await _db
          .collection('households')
          .doc(householdId)
          .collection('ingredients')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Ingredient(
          id: doc.id,
          name: data['name'] ?? '',
          quantity: (data['quantity'] as num?)?.toDouble() ?? 0,
          unit: data['unit'] ?? '',
          expirationDate: data['expiration_date'] != null 
              ? (data['expiration_date'] as Timestamp).toDate() 
              : DateTime.now(),
          imageUrl: data['image_url'] ?? '',
          categoryId: data['category_id'] ?? '',
          categoryName: data['category_name'] ?? '',
          householdId: householdId,
        );
      }).toList();
    } catch (e) {
      print('Lỗi lấy pantry: $e');
      return [];
    }
  }

  // So sánh nguyên liệu và tính số nguyên liệu thiếu
  Future<int> getMissingIngredientsCount(String recipeId, String householdId) async {
    try {
      final recipe = await getRecipeById(recipeId);
      if (recipe == null) return 0;

      final pantryIngredients = await getPantryIngredients(householdId);
      
      // Tạo map pantry theo tên (normalized)
      final Map<String, Ingredient> pantryMap = {};
      for (var ingredient in pantryIngredients) {
        final normalizedName = ingredient.name.toLowerCase().trim();
        if (pantryMap.containsKey(normalizedName)) {
          final existing = pantryMap[normalizedName]!;
          pantryMap[normalizedName] = Ingredient(
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
          pantryMap[normalizedName] = ingredient;
        }
      }

      int missingCount = 0;
      for (var required in recipe.ingredientsRequirements) {
        final normalizedId = required.id.toLowerCase().trim();
        final normalizedName = required.name.toLowerCase().trim();
        
        // Tìm theo ID hoặc tên
        Ingredient? pantryIngredient = pantryMap[normalizedId] ?? pantryMap[normalizedName];
        
        if (pantryIngredient == null) {
          missingCount++;
        } else {
          // So sánh số lượng
          final convertedAmount = _convertUnit(
            pantryIngredient.quantity,
            pantryIngredient.unit,
            required.unit,
          );
          if (convertedAmount < required.amount) {
            missingCount++;
          }
        }
      }
      
      return missingCount;
    } catch (e) {
      print('Lỗi tính nguyên liệu thiếu: $e');
      return 0;
    }
  }

  // Kiểm tra đủ nguyên liệu không
  Future<bool> checkIngredientsAvailability(String recipeId, String householdId) async {
    final missingCount = await getMissingIngredientsCount(recipeId, householdId);
    return missingCount == 0;
  }

  // Lấy danh sách RecipeMatch với độ phù hợp nguyên liệu
  Future<List<RecipeMatch>> getRecipesWithMatch(String householdId) async {
    try {
      final pantryIngredients = await getPantryIngredients(householdId);
      return await _recipeProvider.getRecipesByPantry(
        pantryIngredients,
        minMatchPercentage: 0, // Lấy tất cả để hiển thị
      );
    } catch (e) {
      print('Lỗi lấy recipes với match: $e');
      return [];
    }
  }

  // Thêm meal plan
  Future<void> onDropRecipeToCalendar({
    required DateTime date,
    required String mealTime,
    required String recipeId,
    required String householdId,
  }) async {
    await _mealPlanService.addMealPlan(
      date: date,
      mealTime: mealTime,
      recipeId: recipeId,
      householdId: householdId,
    );
  }

  // Xóa meal plan
  Future<void> deleteMealPlan(String mealPlanId) async {
    await _mealPlanService.deleteMealPlan(mealPlanId);
  }

  // Chuyển đổi đơn vị
  double _convertUnit(double amount, String fromUnit, String toUnit) {
    if (fromUnit.toLowerCase() == toUnit.toLowerCase()) {
      return amount;
    }

    final fromLower = fromUnit.toLowerCase();
    final toLower = toUnit.toLowerCase();

    // Khối lượng
    if (['kg', 'kilogram'].contains(fromLower) && ['g', 'gram'].contains(toLower)) {
      return amount * 1000;
    }
    if (['g', 'gram'].contains(fromLower) && ['kg', 'kilogram'].contains(toLower)) {
      return amount / 1000;
    }

    // Thể tích
    if (['l', 'liter'].contains(fromLower) && ['ml', 'milliliter'].contains(toLower)) {
      return amount * 1000;
    }
    if (['ml', 'milliliter'].contains(fromLower) && ['l', 'liter'].contains(toLower)) {
      return amount / 1000;
    }

    return amount;
  }
}