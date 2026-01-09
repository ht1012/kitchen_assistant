import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime expirationDate;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final String householdId;
  final String slug; // id thân thiện, dễ dùng cho AI

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expirationDate,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.householdId,
    required this.slug,
  });

  factory Ingredient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Ingredient(
      id: doc.id,
      name: data['ingredient_name'] ?? '',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] ?? '',
      expirationDate: (data['expiration_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['ingredient_image'] ?? '',
      categoryId: data['category_id'] ?? '',
      categoryName: data['category_name'] ?? '',
      householdId: data['household_id'] ?? '',
      slug: data['ingredient_slug'] ?? '',
    );
  }
}
