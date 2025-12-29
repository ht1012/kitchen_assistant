import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/virtualPantry/ingredient_model.dart';

class IngredientService {
  final _collection =
      FirebaseFirestore.instance.collection('ingredient_inventory');

  Future<List<Ingredient>> getIngredients() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Ingredient.fromFirestore(doc))
        .toList();
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    await _collection.add({
      'ingredient_name': ingredient.name,
      'quantity': ingredient.quantity,
      'unit': ingredient.unit,
      'expiration_date': Timestamp.fromDate(ingredient.expirationDate),
      'ingredient_image': ingredient.imageUrl,
      'category_id': ingredient.categoryId,
      'category_name': ingredient.categoryName,
    });
  }

  Future<void> updateIngredient(String id, Ingredient ingredient) async {
    await _collection.doc(id).update({
      'ingredient_name': ingredient.name,
      'quantity': ingredient.quantity,
      'unit': ingredient.unit,
      'expiration_date': Timestamp.fromDate(ingredient.expirationDate),
      'ingredient_image': ingredient.imageUrl,
      'category_id': ingredient.categoryId,
      'category_name': ingredient.categoryName,
    });
  }

  Future<void> deleteIngredient(String id) async {
    await _collection.doc(id).delete();
  }
}
