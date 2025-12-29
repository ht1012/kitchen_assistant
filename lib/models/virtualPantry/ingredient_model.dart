import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime expirationDate;
  final String imageUrl;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expirationDate,
    required this.imageUrl,
  });

  factory Ingredient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Ingredient(
      id: doc.id,
      name: data['ingredient_name'],
      quantity: (data['quantity'] as num).toDouble(),
      unit: data['unit'],
      expirationDate:
          (data['expiration_date'] as Timestamp).toDate(),
      imageUrl: data['ingredient_image'] ?? '',
    );
  }
}
