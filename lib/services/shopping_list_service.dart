import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListService {
  final _db = FirebaseFirestore.instance;

  Future<String?> _getHouseholdId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final householdCode = prefs.getString('household_code');

      if (householdCode == null) return null;

      final snapshot = await _db
          .collection('households')
          .where('household_code', isEqualTo: householdCode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Lỗi lấy household_id: $e');
      return null;
    }
  }

  // Lấy tất cả shopping items của household (chỉ pending)
  Stream<List<ShoppingItem>> getShoppingItems() {
    return _db
        .collection('shopping_list')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
          final householdId = await _getHouseholdId();
          if (householdId == null) return <ShoppingItem>[];

          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                return data['household_id'] == householdId;
              })
              .map((doc) => ShoppingItem.fromFirestore(doc))
              .toList();
        });
  }

  // Thêm shopping item
  Future<void> addShoppingItem(ShoppingItem item) async {
    final householdId = await _getHouseholdId();
    if (householdId == null) {
      throw Exception('Chưa có thông tin hộ gia đình');
    }

    // Kiểm tra xem đã có item này chưa
    final existingSnapshot = await _db
        .collection('shopping_list')
        .where('household_id', isEqualTo: householdId)
        .where('ingredient_id', isEqualTo: item.ingredientId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existingSnapshot.docs.isNotEmpty) {
      // Cộng dồn số lượng và merge recipe_ids
      final existingDoc = existingSnapshot.docs.first;
      final existingItem = ShoppingItem.fromFirestore(existingDoc);

      // Merge recipe_ids (loại bỏ trùng lặp)
      final mergedRecipeIds = <String>{
        ...existingItem.recipeIds,
        ...item.recipeIds,
      }.toList();

      await existingDoc.reference.update({
        'required_quantity':
            existingItem.requiredQuantity + item.requiredQuantity,
        'recipe_ids': mergedRecipeIds,
      });
    } else {
      // Thêm mới
      await _db.collection('shopping_list').add(item.toFirestore());
    }
  }

  // Xóa shopping item
  Future<void> deleteShoppingItem(String id) async {
    final householdId = await _getHouseholdId();
    if (householdId == null) {
      throw Exception('Chưa có thông tin hộ gia đình');
    }

    final doc = await _db.collection('shopping_list').doc(id).get();
    if (!doc.exists) {
      throw Exception('Shopping item không tồn tại');
    }

    final docData = doc.data();
    if (docData?['household_id'] != householdId) {
      throw Exception('Không có quyền xóa item này');
    }

    await _db.collection('shopping_list').doc(id).delete();
  }
}
