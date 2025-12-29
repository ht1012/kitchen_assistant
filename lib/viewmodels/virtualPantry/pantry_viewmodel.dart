import 'package:flutter/material.dart';
import '../../models/virtualPantry/ingredient_model.dart';
import '../../services/virtualPantry/ingredient_service.dart';

class PantryViewModel extends ChangeNotifier {
  final IngredientService _service = IngredientService();

  List<Ingredient> ingredients = [];
  bool isLoading = false;

  Future<void> loadIngredients() async {
    isLoading = true;
    notifyListeners();

    ingredients = await _service.getIngredients();

    isLoading = false;
    notifyListeners();
  }

  // tính trạng thái
  String getStatus(Ingredient i) {
    final days = i.expirationDate.difference(DateTime.now()).inDays;
    if (days < 0) return 'Hết hạn';
    if (days <= 3) return 'Sắp hết hạn';
    return 'Tươi';
  }
}
