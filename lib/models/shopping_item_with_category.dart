import 'shopping_list_model.dart';

/// Model mở rộng để chứa thêm thông tin category cho ShoppingItem
class ShoppingItemWithCategory {
  final ShoppingItem item;
  final String ingredientName;
  final String categoryId;
  final String categoryName;

  ShoppingItemWithCategory({
    required this.item,
    required this.ingredientName,
    required this.categoryId,
    required this.categoryName,
  });
}