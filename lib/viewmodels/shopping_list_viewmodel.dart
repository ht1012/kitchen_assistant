import 'package:flutter/material.dart';
import '../models/shopping_list_model.dart';
import '../models/Recipe.dart';
import '../models/virtualPantry/ingredient_model.dart';
import '../services/shopping_list_service.dart';
import '../services/virtualPantry/ingredient_service.dart';
import '../services/meal_plan_service.dart';
import '../services/ai_recipe_service.dart';
import 'meal_planner_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final ShoppingListService _shoppingService = ShoppingListService();
  final IngredientService _ingredientService = IngredientService();
  final _db = FirebaseFirestore.instance;

  List<ShoppingItem> _shoppingItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ShoppingItem> get shoppingItems => _shoppingItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stream shopping items
  Stream<List<ShoppingItem>> getShoppingItemsStream() {
    return _shoppingService.getShoppingItems();
  }

  // Load shopping items
  Future<void> loadShoppingItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final stream = _shoppingService.getShoppingItems();
      await for (final items in stream) {
        _shoppingItems = items;
        _isLoading = false;
        notifyListeners();
        break;
      }
    } catch (e) {
      _errorMessage = 'Lỗi tải danh sách: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm shopping item thủ công
  Future<void> addManualShoppingItem({
    required String ingredientId,
    required String ingredientName,
    required double quantity,
    required String unit,
  }) async {
    try {
      final householdId = await _getHouseholdId();
      if (householdId == null) {
        throw Exception('Chưa có thông tin hộ gia đình');
      }

      final item = ShoppingItem(
        id: '',
        householdId: householdId,
        ingredientId: ingredientId,
        requiredQuantity: quantity,
        status: 'pending',
        unit: unit,
      );

      await _shoppingService.addShoppingItem(item);
    } catch (e) {
      _errorMessage = 'Lỗi thêm item: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Xóa shopping item
  Future<void> deleteShoppingItem(String id) async {
    try {
      await _shoppingService.deleteShoppingItem(id);
    } catch (e) {
      _errorMessage = 'Lỗi xóa item: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Thêm các items đã check vào kho - NHẬN TRỰC TIẾP DANH SÁCH ITEMS
  Future<void> addCheckedItemsToPantry(List<ShoppingItem> checkedItems) async {
    if (checkedItems.isEmpty) {
      throw Exception('Không có item nào được chọn');
    }

    try {
      final householdId = await _getHouseholdId();
      if (householdId == null) {
        throw Exception('Chưa có thông tin hộ gia đình');
      }

      for (var item in checkedItems) {
        // 1. Lấy thông tin ingredient từ ingredient_inventory hoặc recipes
        final ingredientInfo = await _getIngredientInfo(item.ingredientId);
        final ingredientName = ingredientInfo['name'] ?? item.ingredientId;
        final categoryId = ingredientInfo['categoryId'] ?? '';
        final categoryName = ingredientInfo['categoryName'] ?? 'Khác';

        // 2. Kiểm tra ingredient đã tồn tại trong kho chưa
        final existingIngredients = await _ingredientService.getIngredients();
        final existingIngredient = existingIngredients.firstWhere(
          (ing) =>
              ing.name.toLowerCase().trim() ==
              ingredientName.toLowerCase().trim(),
          orElse: () => Ingredient(
            id: '',
            name: '',
            quantity: 0,
            unit: '',
            expirationDate: DateTime.now(),
            imageUrl: '',
            categoryId: '',
            categoryName: '',
            householdId: '',
            slug: '',
          ),
        );

        if (existingIngredient.id.isNotEmpty) {
          // Cộng dồn số lượng
          final updatedIngredient = Ingredient(
            id: existingIngredient.id,
            name: existingIngredient.name,
            quantity: existingIngredient.quantity + item.requiredQuantity,
            unit: existingIngredient.unit,
            expirationDate: existingIngredient.expirationDate,
            imageUrl: existingIngredient.imageUrl,
            categoryId: existingIngredient.categoryId,
            categoryName: existingIngredient.categoryName,
            householdId: existingIngredient.householdId,
            slug: existingIngredient.slug,
          );
          await _ingredientService.updateIngredient(
            existingIngredient.id,
            updatedIngredient,
          );
        } else {
          // Tạo mới ingredient
          final newIngredient = Ingredient(
            id: '',
            name: ingredientName,
            quantity: item.requiredQuantity,
            unit: item.unit,
            expirationDate: DateTime.now().add(const Duration(days: 7)),
            imageUrl: '',
            categoryId: categoryId,
            categoryName: categoryName,
            householdId: householdId,
            slug: '',
          );
          await _ingredientService.addIngredient(newIngredient);
        }

        // 3. Xóa item khỏi shopping list
        await _shoppingService.deleteShoppingItem(item.id);
      }

      // 4. Sync lại shopping list với meal plans
      await _syncShoppingListWithMealPlans(householdId);
    } catch (e) {
      _errorMessage = 'Lỗi thêm vào kho: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Lấy thông tin ingredient (name, category) từ ingredientId
  Future<Map<String, String>> _getIngredientInfo(String ingredientId) async {
    try {
      // 1. Tìm trong ingredient_inventory trước
      final inventorySnapshot = await _db
          .collection('ingredient_inventory')
          .doc(ingredientId)
          .get();

      if (inventorySnapshot.exists) {
        final data = inventorySnapshot.data()!;
        return {
          'name': data['ingredient_name'] ?? ingredientId,
          'categoryId': data['category_id'] ?? '',
          'categoryName': data['category_name'] ?? 'Khác',
        };
      }

      // 2. Tìm trong recipes
      final recipesSnapshot = await _db.collection('recipes').get();
      for (var doc in recipesSnapshot.docs) {
        final recipe = Recipe.fromFirestore(doc);
        final ingredient = recipe.ingredientsRequirements.firstWhere(
          (ing) => ing.id == ingredientId,
          orElse: () =>
              IngredientRequirement(id: '', name: '', amount: 0, unit: ''),
        );

        if (ingredient.id == ingredientId && ingredient.name.isNotEmpty) {
          // Lấy category từ tên ingredient
          final categoryName = _getCategoryFromIngredientName(ingredient.name);
          return {
            'name': ingredient.name,
            'categoryId': '',
            'categoryName': categoryName,
          };
        }
      }

      // 3. Nếu không tìm thấy, trả về ingredientId làm tên
      return {'name': ingredientId, 'categoryId': '', 'categoryName': 'Khác'};
    } catch (e) {
      print('Lỗi lấy ingredient info: $e');
      return {'name': ingredientId, 'categoryId': '', 'categoryName': 'Khác'};
    }
  }

  /// Helper: Lấy category từ tên nguyên liệu (heuristic)
  String _getCategoryFromIngredientName(String ingredientName) {
    final name = ingredientName.toLowerCase();

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

    if (name.contains('bánh') ||
        name.contains('mì') ||
        name.contains('noodle')) {
      return 'Bánh';
    }

    if (name.contains('sữa') ||
        name.contains('milk') ||
        name.contains('cream')) {
      return 'Sữa';
    }

    if (name.contains('đông') ||
        name.contains('lạnh') ||
        name.contains('frozen')) {
      return 'Đông lạnh';
    }

    return 'Khác';
  }

  // Sync shopping list với meal plans
  Future<void> _syncShoppingListWithMealPlans(String householdId) async {
    try {
      final mealPlannerViewModel = MealPlannerViewModel(
        MealPlanService(),
        SmartRecipeProvider(),
      );
      await mealPlannerViewModel.syncShoppingListWithMealPlans(householdId);
    } catch (e) {
      print('Lỗi sync shopping list: $e');
    }
  }

  // Helper: Lấy household_id
  Future<String?> _getHouseholdId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final householdCode = prefs.getString('household_code');

      if (householdCode == null) return null;

      final snapshot = await _db
          .collection('households')
          .where('household_code', isEqualTo: householdCode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Lỗi lấy household_id: $e');
      return null;
    }
  }

  // Lấy tên ingredient từ ingredient_id (public method)
  Future<String> getIngredientName(String ingredientId) async {
    final info = await _getIngredientInfo(ingredientId);
    return info['name'] ?? ingredientId;
  }

  // Lấy tên các recipes từ danh sách recipe IDs
  Future<List<String>> getRecipeNames(List<String> recipeIds) async {
    if (recipeIds.isEmpty) return [];

    try {
      final List<String> names = [];
      for (var recipeId in recipeIds) {
        final doc = await _db.collection('recipes').doc(recipeId).get();
        if (doc.exists) {
          final data = doc.data();
          names.add(data?['recipe_name'] ?? recipeId);
        }
      }
      return names;
    } catch (e) {
      print('Lỗi lấy recipe names: $e');
      return [];
    }
  }
}
