import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitchen_assistant/models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Recipe>> getRecipesByHousehold(String householdId) {
    return _db
        .collection('recipes')
        .where('household_id', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final doc = await _db.collection('recipes').doc(recipeId).get();
      if (doc.exists) {
        return Recipe.fromFirestore(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkIngredientsAvailability(
      String recipeId, String householdId) async {
    try {
      // Get required ingredients for recipe
      final recipeIngredients = await _db
          .collection('recipe_ingredients')
          .where('recipe_id', isEqualTo: recipeId)
          .where('household_id', isEqualTo: householdId)
          .get();

      // Get available ingredients in inventory
      final inventory = await _db
          .collection('ingredient_inventory')
          .where('household_id', isEqualTo: householdId)
          .get();

      // Create map of available ingredients with quantities
      Map<String, double> availableIngredients = {};
      for (var doc in inventory.docs) {
        final data = doc.data();
        availableIngredients[data['ingredient_id']] = data['quantity'] ?? 0.0;
      }

      // Check if all required ingredients are available
      for (var doc in recipeIngredients.docs) {
        final data = doc.data();
        final ingredientId = data['ingredient_id'];
        final requiredQuantity = data['required_quantity'] ?? 0.0;
        final availableQuantity = availableIngredients[ingredientId] ?? 0.0;

        if (availableQuantity < requiredQuantity) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getMissingIngredientsCount(
      String recipeId, String householdId) async {
    try {
      // Get required ingredients for recipe
      final recipeIngredients = await _db
          .collection('recipe_ingredients')
          .where('recipe_id', isEqualTo: recipeId)
          .where('household_id', isEqualTo: householdId)
          .get();

      // Get available ingredients in inventory
      final inventory = await _db
          .collection('ingredient_inventory')
          .where('household_id', isEqualTo: householdId)
          .get();

      // Create map of available ingredients with quantities
      Map<String, double> availableIngredients = {};
      for (var doc in inventory.docs) {
        final data = doc.data();
        availableIngredients[data['ingredient_id']] = data['quantity'] ?? 0.0;
      }

      int missingCount = 0;
      // Check missing ingredients
      for (var doc in recipeIngredients.docs) {
        final data = doc.data();
        final ingredientId = data['ingredient_id'];
        final requiredQuantity = data['required_quantity'] ?? 0.0;
        final availableQuantity = availableIngredients[ingredientId] ?? 0.0;

        if (availableQuantity < requiredQuantity) {
          missingCount++;
        }
      }

      return missingCount;
    } catch (e) {
      return 0;
    }
  }
}