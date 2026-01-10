import 'package:flutter/material.dart';
import '../models/shopping_list_model.dart';
import '../models/shopping_item_with_category.dart';
import '../models/Recipe.dart';
import '../models/virtualPantry/ingredient_model.dart';
import '../models/virtualPantry/category_model.dart';
import '../services/shopping_list_service.dart';
import '../services/virtualPantry/ingredient_service.dart';
import '../services/meal_plan_service.dart';
import '../services/ai_recipe_service.dart';
import '../utils/category_emoji_helper.dart';
import 'meal_planner_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final ShoppingListService _shoppingService = ShoppingListService();
  final IngredientService _ingredientService = IngredientService();
  final _db = FirebaseFirestore.instance;

  List<ShoppingItem> _shoppingItems = [];
  List<Category> _categories = [];
  Map<String, ShoppingItemWithCategory> _itemsWithCategory = {};
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  String? _errorMessage;

  List<ShoppingItem> get shoppingItems => _shoppingItems;
  List<Category> get categories => _categories;
  Map<String, ShoppingItemWithCategory> get itemsWithCategory => _itemsWithCategory;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
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

  /// Load categories từ Firebase
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _ingredientService.getCategories();
      _isLoadingCategories = false;
      notifyListeners();
    } catch (e) {
      print('Lỗi load categories: $e');
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Lấy emoji cho category - sử dụng CategoryEmojiHelper
  String getCategoryEmoji(String categoryName) {
    // Tìm category trong danh sách đã load
    final category = _categories.firstWhere(
      (cat) => cat.categoryName.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => Category(
        id: '',
        categoryId: '',
        categoryName: categoryName,
      ),
    );

    // Sử dụng helper để lấy emoji
    return CategoryEmojiHelper.getEmoji(
      categoryId: category.categoryId,
      categoryName: category.categoryName,
    );
  }

  /// Lấy category name từ categoryId
  String getCategoryNameById(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.categoryId.toLowerCase() == categoryId.toLowerCase(),
      orElse: () => Category(
        id: '',
        categoryId: categoryId,
        categoryName: 'Khác',
      ),
    );
    return category.categoryName;
  }

  /// Lấy thông tin đầy đủ của shopping item (bao gồm category)
  Future<ShoppingItemWithCategory> getItemWithCategory(ShoppingItem item) async {
    // Kiểm tra cache
    if (_itemsWithCategory.containsKey(item.id)) {
      return _itemsWithCategory[item.id]!;
    }

    final info = await _getIngredientInfo(item.ingredientId);
    final itemWithCategory = ShoppingItemWithCategory(
      item: item,
      ingredientName: info['name'] ?? item.ingredientId,
      categoryId: info['categoryId'] ?? '',
      categoryName: info['categoryName'] ?? 'Khác',
    );

    // Cache lại
    _itemsWithCategory[item.id] = itemWithCategory;
    return itemWithCategory;
  }

  /// Lấy danh sách items đã được nhóm theo category
  Future<Map<String, List<ShoppingItemWithCategory>>> getItemsGroupedByCategory(
    List<ShoppingItem> items,
  ) async {
    final Map<String, List<ShoppingItemWithCategory>> grouped = {};

    for (var item in items) {
      final itemWithCategory = await getItemWithCategory(item);
      final categoryName = itemWithCategory.categoryName;

      if (!grouped.containsKey(categoryName)) {
        grouped[categoryName] = [];
      }
      grouped[categoryName]!.add(itemWithCategory);
    }

    // Sắp xếp theo thứ tự ưu tiên
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final order = [
          'Rau củ',
          'Thịt & Hải sản',
          'Trái cây',
          'Sữa',
          'Bánh',
          'Đồ uống',
          'Gia vị',
          'Đông lạnh',
          'Khác',
        ];
        final indexA = order.indexOf(a);
        final indexB = order.indexOf(b);
        if (indexA == -1 && indexB == -1) return a.compareTo(b);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

    final sortedGrouped = <String, List<ShoppingItemWithCategory>>{};
    for (var key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
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
      
      // Clear cache
      _itemsWithCategory.clear();
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
      
      // Clear cache
      _itemsWithCategory.remove(id);
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

      // Clear cache
      _itemsWithCategory.clear();

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
      // 1. Tìm trong ingredient_inventory trước (theo tên/slug)
      final inventorySnapshot = await _db
          .collection('ingredient_inventory')
          .where('ingredient_slug', isEqualTo: ingredientId.toLowerCase())
          .limit(1)
          .get();

      if (inventorySnapshot.docs.isNotEmpty) {
        final data = inventorySnapshot.docs.first.data();
        return {
          'name': data['ingredient_name'] ?? ingredientId,
          'categoryId': data['category_id'] ?? '',
          'categoryName': data['category_name'] ?? 'Khác',
        };
      }

      // 2. Tìm theo document id
      final docSnapshot = await _db
          .collection('ingredient_inventory')
          .doc(ingredientId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        return {
          'name': data['ingredient_name'] ?? ingredientId,
          'categoryId': data['category_id'] ?? '',
          'categoryName': data['category_name'] ?? 'Khác',
        };
      }

      // 3. Tìm trong recipes
      final recipesSnapshot = await _db.collection('recipes').get();
      for (var doc in recipesSnapshot.docs) {
        final recipe = Recipe.fromFirestore(doc);
        final ingredient = recipe.ingredientsRequirements.firstWhere(
          (ing) =>
              ing.id.toLowerCase() == ingredientId.toLowerCase() ||
              ing.name.toLowerCase() == ingredientId.toLowerCase(),
          orElse: () => IngredientRequirement(
            id: '',
            name: '',
            amount: 0,
            unit: '',
          ),
        );

        if (ingredient.id.isNotEmpty || ingredient.name.isNotEmpty) {
          // Lấy category từ tên ingredient
          final categoryName = _getCategoryFromIngredientName(
            ingredient.name.isNotEmpty ? ingredient.name : ingredientId,
          );
          return {
            'name': ingredient.name.isNotEmpty ? ingredient.name : ingredientId,
            'categoryId': '',
            'categoryName': categoryName,
          };
        }
      }

      // 4. Nếu không tìm thấy, dùng heuristic để đoán category
      final categoryName = _getCategoryFromIngredientName(ingredientId);
      return {
        'name': ingredientId,
        'categoryId': '',
        'categoryName': categoryName,
      };
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
        name.contains('húng') ||
        name.contains('xà lách') ||
        name.contains('bí') ||
        name.contains('dưa')) {
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
        name.contains('lợn') ||
        name.contains('vịt') ||
        name.contains('trứng')) {
      return 'Thịt & Hải sản';
    }

    if (name.contains('bánh') ||
        name.contains('mì') ||
        name.contains('noodle') ||
        name.contains('bún') ||
        name.contains('phở')) {
      return 'Bánh';
    }

    if (name.contains('sữa') ||
        name.contains('milk') ||
        name.contains('cream') ||
        name.contains('phô mai') ||
        name.contains('cheese') ||
        name.contains('bơ')) {
      return 'Sữa';
    }

    if (name.contains('đông') ||
        name.contains('lạnh') ||
        name.contains('frozen')) {
      return 'Đông lạnh';
    }

    if (name.contains('táo') ||
        name.contains('cam') ||
        name.contains('chuối') ||
        name.contains('nho') ||
        name.contains('dâu') ||
        name.contains('xoài') ||
        name.contains('ổi') ||
        name.contains('quả')) {
      return 'Trái cây';
    }

    if (name.contains('nước') ||
        name.contains('trà') ||
        name.contains('cà phê') ||
        name.contains('bia') ||
        name.contains('rượu')) {
      return 'Đồ uống';
    }

    if (name.contains('muối') ||
        name.contains('tiêu') ||
        name.contains('đường') ||
        name.contains('nước mắm') ||
        name.contains('xì dầu') ||
        name.contains('dầu') ||
        name.contains('giấm') ||
        name.contains('tương')) {
      return 'Gia vị';
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
      
      // Clear cache sau khi sync
      _itemsWithCategory.clear();
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

  @override
  void dispose() {
    super.dispose();
  }
}