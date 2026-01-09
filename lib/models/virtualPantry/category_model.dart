import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id; // Document ID từ Firestore
  final String categoryId; // category_id field
  final String categoryName; // category_name field

  Category({
    required this.id,
    required this.categoryId,
    required this.categoryName,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Category(
      id: doc.id,
      categoryId: data['category_id'] ?? '',
      categoryName: data['category_name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
    };
  }
}
