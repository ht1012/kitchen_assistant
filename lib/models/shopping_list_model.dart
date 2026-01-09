import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final String id;
  final String householdId;
  final String ingredientId;
  final double requiredQuantity;
  final String status; // "pending", "purchased"
  final String unit;
  final List<String> recipeIds; // Danh sách recipe IDs liên quan

  ShoppingItem({
    required this.id,
    required this.householdId,
    required this.ingredientId,
    required this.requiredQuantity,
    required this.status,
    required this.unit,
    this.recipeIds = const [],
  });

  // Factory từ Firestore DocumentSnapshot
  factory ShoppingItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItem(
      id: doc.id,
      householdId: data['household_id'] ?? '',
      ingredientId: data['ingredient_id'] ?? '',
      requiredQuantity: (data['required_quantity'] as num?)?.toDouble() ?? 0,
      status: data['status'] ?? 'pending',
      unit: data['unit'] ?? '',
      recipeIds: (data['recipe_ids'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'household_id': householdId,
      'ingredient_id': ingredientId,
      'required_quantity': requiredQuantity,
      'status': status,
      'unit': unit,
      'recipe_ids': recipeIds,
    };
  }

  ShoppingItem copyWith({
    String? id,
    String? householdId,
    String? ingredientId,
    double? requiredQuantity,
    String? status,
    String? unit,
    List<String>? recipeIds,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      ingredientId: ingredientId ?? this.ingredientId,
      requiredQuantity: requiredQuantity ?? this.requiredQuantity,
      status: status ?? this.status,
      unit: unit ?? this.unit,
      recipeIds: recipeIds ?? this.recipeIds,
    );
  }
}
