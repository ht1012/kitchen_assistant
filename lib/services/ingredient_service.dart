import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/virtualPantry/ingredient_model.dart';

class IngredientService {
  final _collection =
      FirebaseFirestore.instance.collection('ingredient_inventory');

  Future<List<Ingredient>> getIngredients() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Ingredient.fromFirestore(doc))
        .toList();
  }
}
