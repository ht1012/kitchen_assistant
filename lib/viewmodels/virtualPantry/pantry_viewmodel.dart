import 'package:flutter/material.dart';
import '../../models/virtualPantry/ingredient_model.dart';
import '../../models/virtualPantry/category_model.dart';
import '../../services/virtualPantry/ingredient_service.dart';

class PantryViewModel extends ChangeNotifier {
  final IngredientService _service = IngredientService();

  List<Ingredient> ingredients = [];
  List<Category> categories = [];
  bool isLoading = false;
  bool isLoadingCategories = false;

  Future<void> loadIngredients() async {
    isLoading = true;
    notifyListeners();

    ingredients = await _service.getIngredients();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    await _service.addIngredient(ingredient);
    await loadIngredients();
  }

  Future<void> updateIngredient(String id, Ingredient ingredient) async {
    await _service.updateIngredient(id, ingredient);
    await loadIngredients();
  }

  Future<void> useIngredient(String id, double amount) async {
    await _service.useIngredient(id, amount);
    await loadIngredients();
  }

  // Trừ nhiều nguyên liệu cùng lúc khi nấu món ăn
  Future<Map<String, dynamic>> useIngredientsForRecipe(List<dynamic> recipeIngredients) async {
    final results = await _service.useIngredientsForRecipe(ingredients, recipeIngredients);
    await loadIngredients(); // Reload để cập nhật UI
    return results;
  }

  Future<void> loadCategories() async {
    isLoadingCategories = true;
    notifyListeners();

    categories = await _service.getCategories();

    isLoadingCategories = false;
    notifyListeners();
  }

  String getStatus(Ingredient i) {
    final days = i.expirationDate.difference(DateTime.now()).inDays;
    if (days < 0) return 'Hết hạn';
    if (days <= 3) return 'Sắp hết hạn';
    return 'Tươi';
  }
}
