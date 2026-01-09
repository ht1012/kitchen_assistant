import 'package:flutter/material.dart';
import 'package:kitchen_assistant/models/meal_plan_model.dart';
import 'package:kitchen_assistant/models/Recipe.dart';
import 'package:kitchen_assistant/models/RecipeMatch.dart';
import 'package:kitchen_assistant/models/virtualPantry/ingredient_model.dart';
import 'package:kitchen_assistant/models/shopping_list_model.dart';
import 'package:kitchen_assistant/services/meal_plan_service.dart';
import 'package:kitchen_assistant/services/ai_recipe_service.dart';
import 'package:kitchen_assistant/services/shopping_list_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealPlannerViewModel extends ChangeNotifier {
  final MealPlanService _mealPlanService;
  final SmartRecipeProvider _recipeProvider;
  final ShoppingListService _shoppingListService = ShoppingListService();
  final _db = FirebaseFirestore.instance;

  MealPlannerViewModel(this._mealPlanService, this._recipeProvider);

  // Lấy meal plans theo tuần
  Stream<List<MealPlan>> getWeeklyPlans(
    String householdId,
    DateTime weekStart,
  ) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return _mealPlanService.getMealPlansByWeek(householdId, weekStart, weekEnd);
  }

  // Lấy tất cả recipes của household
  Stream<List<Recipe>> getRecipesByHousehold(String householdId) {
    return _db
        .collection('recipes')
        .where('household_id', isEqualTo: householdId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList(),
        );
  }

  // Lấy tất cả recipes (không phân biệt household)
  Stream<List<Recipe>> getAllRecipes() {
    return _db
        .collection('recipes')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList(),
        );
  }

  // Lấy recipe theo ID
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      // Thử tìm theo document ID trước
      final doc = await _db.collection('recipes').doc(recipeId).get();
      if (doc.exists) {
        return Recipe.fromFirestore(doc);
      }

      // Nếu không tìm thấy, thử tìm theo field recipe_id
      final querySnapshot = await _db
          .collection('recipes')
          .where('recipe_id', isEqualTo: recipeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Recipe.fromFirestore(querySnapshot.docs.first);
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
          slug: data['ingredient_slug'] ?? '', // Thêm slug
        );
      }).toList();
    } catch (e) {
      print('Lỗi lấy pantry: $e');
      return [];
    }
  }

  // So sánh nguyên liệu và tính số nguyên liệu thiếu
  Future<int> getMissingIngredientsCount(
    String recipeId,
    String householdId,
  ) async {
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
            slug: existing.slug,
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
        Ingredient? pantryIngredient =
            pantryMap[normalizedId] ?? pantryMap[normalizedName];

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
  Future<bool> checkIngredientsAvailability(
    String recipeId,
    String householdId,
  ) async {
    final missingCount = await getMissingIngredientsCount(
      recipeId,
      householdId,
    );
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

    // Tự động thêm nguyên liệu thiếu vào shopping list
    await _addMissingIngredientsToShoppingList(recipeId, householdId);
  }

  // Tự động thêm nguyên liệu thiếu vào shopping list
  Future<void> _addMissingIngredientsToShoppingList(
    String recipeId,
    String householdId,
  ) async {
    try {
      // Sau khi thêm meal plan, sync lại toàn bộ shopping list
      await syncShoppingListWithMealPlans(householdId);
    } catch (e) {
      print('Lỗi thêm nguyên liệu vào shopping list: $e');
      // Không throw để không ảnh hưởng đến việc thêm meal plan
    }
  }

  // Sync shopping list với tất cả meal plans
  Future<void> syncShoppingListWithMealPlans(String householdId) async {
    try {
      // Lấy tất cả meal plans
      final weekStart = DateTime.now().subtract(
        Duration(days: DateTime.now().weekday - 1),
      );
      final weekEnd = weekStart.add(const Duration(days: 13)); // 2 tuần

      final mealPlansSnapshot = await _db
          .collection('meal_plans')
          .where('household_id', isEqualTo: householdId)
          .get();

      final mealPlans = mealPlansSnapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc.id, doc.data()))
          .where((meal) {
            final mealDate = DateTime(
              meal.date.year,
              meal.date.month,
              meal.date.day,
            );
            return mealDate.isAfter(
                  weekStart.subtract(const Duration(days: 1)),
                ) &&
                mealDate.isBefore(weekEnd.add(const Duration(days: 1)));
          })
          .toList();

      // Lấy pantry ingredients
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
            slug: existing.slug,
          );
        } else {
          pantryMap[normalizedName] = ingredient;
        }
      }

      // Tính tổng nguyên liệu thiếu từ tất cả recipes
      final Map<String, Map<String, dynamic>> missingIngredientsMap = {};
      final Map<String, Set<String>> recipeMap =
          {}; // ingredient_id -> set of recipe_ids

      for (var mealPlan in mealPlans) {
        final recipe = await getRecipeById(mealPlan.recipeId);
        if (recipe == null) continue;

        for (var required in recipe.ingredientsRequirements) {
          final normalizedId = required.id.toLowerCase().trim();
          final normalizedName = required.name.toLowerCase().trim();

          // Tìm theo ID hoặc tên
          Ingredient? pantryIngredient =
              pantryMap[normalizedId] ?? pantryMap[normalizedName];

          double missingQuantity = 0;
          bool isMissing = false;

          if (pantryIngredient == null) {
            missingQuantity = required.amount;
            isMissing = true;
          } else {
            final convertedAmount = _convertUnit(
              pantryIngredient.quantity,
              pantryIngredient.unit,
              required.unit,
            );
            if (convertedAmount < required.amount) {
              missingQuantity = required.amount - convertedAmount;
              isMissing = true;
            }
          }

          if (isMissing && missingQuantity > 0) {
            final key = required.id;

            if (!missingIngredientsMap.containsKey(key)) {
              // Lấy category từ ingredient_inventory hoặc pantry
              String categoryId = '';
              String categoryName = 'Khác';

              if (pantryIngredient != null) {
                categoryId = pantryIngredient.categoryId;
                categoryName = pantryIngredient.categoryName.isNotEmpty
                    ? pantryIngredient.categoryName
                    : 'Khác';
              } else {
                // Tìm trong ingredient_inventory
                final categoryInfo = await _getCategoryFromIngredientInventory(
                  required.id,
                  required.name,
                );
                categoryId = categoryInfo['categoryId'] ?? '';
                categoryName = categoryInfo['categoryName'] ?? 'Khác';
              }

              missingIngredientsMap[key] = {
                'ingredientId': required.id,
                'requiredQuantity': missingQuantity,
                'unit': required.unit,
                'categoryId': categoryId,
                'categoryName': categoryName,
              };
              recipeMap[key] = {mealPlan.recipeId};
            } else {
              // Cộng dồn số lượng và merge recipes
              missingIngredientsMap[key]!['requiredQuantity'] +=
                  missingQuantity;
              recipeMap[key]!.add(mealPlan.recipeId);
            }
          }
        }
      }

      // Xóa tất cả shopping items pending của household
      // (Vì model đơn giản không có is_manually_added, ta sẽ xóa tất cả pending items)
      final existingItemsSnapshot = await _db
          .collection('shopping_list')
          .where('household_id', isEqualTo: householdId)
          .where('status', isEqualTo: 'pending')
          .get();

      final batch = _db.batch();
      for (var doc in existingItemsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Thêm lại các items mới
      for (var entry in missingIngredientsMap.entries) {
        final data = entry.value;
        final ingredientKey = entry.key;
        final relatedRecipeIds = recipeMap[ingredientKey]?.toList() ?? [];

        final shoppingItem = ShoppingItem(
          id: '',
          householdId: householdId,
          ingredientId: data['ingredientId'],
          requiredQuantity: data['requiredQuantity'],
          status: 'pending',
          unit: data['unit'],
          recipeIds: relatedRecipeIds,
        );

        await _shoppingListService.addShoppingItem(shoppingItem);
      }
    } catch (e) {
      print('Lỗi sync shopping list: $e');
      rethrow;
    }
  }

  // Lấy category từ ingredient_inventory
  Future<Map<String, String>> _getCategoryFromIngredientInventory(
    String ingredientId,
    String ingredientName,
  ) async {
    try {
      // Lấy household_code từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final householdCode = prefs.getString('household_code');
      if (householdCode == null) {
        return {
          'categoryId': '',
          'categoryName': _getCategoryFromIngredientName(ingredientName),
        };
      }

      // Tìm trong ingredient_inventory theo tên và household_code
      final snapshot = await _db
          .collection('ingredient_inventory')
          .where('household_id', isEqualTo: householdCode)
          .where('ingredient_name', isEqualTo: ingredientName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return {
          'categoryId': data['category_id'] ?? '',
          'categoryName': data['category_name'] ?? 'Khác',
        };
      }

      // Nếu không tìm thấy, dùng heuristic
      return {
        'categoryId': '',
        'categoryName': _getCategoryFromIngredientName(ingredientName),
      };
    } catch (e) {
      print('Lỗi lấy category: $e');
      return {'categoryId': '', 'categoryName': 'Khác'};
    }
  }

  // Helper: Lấy category từ tên nguyên liệu (heuristic)
  String _getCategoryFromIngredientName(String ingredientName) {
    final name = ingredientName.toLowerCase();

    // Rau củ
    if (name.contains('rau') ||
        name.contains('cà') ||
        name.contains('cải') ||
        name.contains('bắp') ||
        name.contains('cà rốt') ||
        name.contains('khoai') ||
        name.contains('hành') ||
        name.contains('tỏi') ||
        name.contains('ớt') ||
        name.contains('gừng') ||
        name.contains('sả') ||
        name.contains('húng')) {
      return 'Rau củ';
    }

    // Thịt & Hải sản
    if (name.contains('thịt') ||
        name.contains('gà') ||
        name.contains('heo') ||
        name.contains('bò') ||
        name.contains('cá') ||
        name.contains('tôm') ||
        name.contains('cua') ||
        name.contains('mực') ||
        name.contains('lợn')) {
      return 'Thịt & Hải sản';
    }

    // Bánh
    if (name.contains('bánh') ||
        name.contains('mì') ||
        name.contains('noodle')) {
      return 'Bánh';
    }

    // Sữa
    if (name.contains('sữa') ||
        name.contains('milk') ||
        name.contains('cream')) {
      return 'Sữa';
    }

    // Đông lạnh
    if (name.contains('đông') ||
        name.contains('lạnh') ||
        name.contains('frozen')) {
      return 'Đông lạnh';
    }

    return 'Khác';
  }

  // Xóa meal plan
  Future<void> deleteMealPlan(String mealPlanId) async {
    // Lấy household_id từ meal plan trước khi xóa
    final mealPlanDoc = await _db
        .collection('meal_plans')
        .doc(mealPlanId)
        .get();
    if (mealPlanDoc.exists) {
      final data = mealPlanDoc.data()!;
      final householdId = data['household_id'] as String;

      await _mealPlanService.deleteMealPlan(mealPlanId);

      // Sync lại shopping list sau khi xóa
      await syncShoppingListWithMealPlans(householdId);
    } else {
      await _mealPlanService.deleteMealPlan(mealPlanId);
    }
  }

  // Chuyển đổi đơn vị
  double _convertUnit(double amount, String fromUnit, String toUnit) {
    if (fromUnit.toLowerCase() == toUnit.toLowerCase()) {
      return amount;
    }

    final fromLower = fromUnit.toLowerCase();
    final toLower = toUnit.toLowerCase();

    // Khối lượng
    if (['kg', 'kilogram'].contains(fromLower) &&
        ['g', 'gram'].contains(toLower)) {
      return amount * 1000;
    }
    if (['g', 'gram'].contains(fromLower) &&
        ['kg', 'kilogram'].contains(toLower)) {
      return amount / 1000;
    }

    // Thể tích
    if (['l', 'liter'].contains(fromLower) &&
        ['ml', 'milliliter'].contains(toLower)) {
      return amount * 1000;
    }
    if (['ml', 'milliliter'].contains(fromLower) &&
        ['l', 'liter'].contains(toLower)) {
      return amount / 1000;
    }

    return amount;
  }
}
