import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/virtualPantry/ingredient_model.dart';
import '../../models/virtualPantry/category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IngredientService {
  final _collection =
      FirebaseFirestore.instance.collection('ingredient_inventory');
  final _categoryCollection =
      FirebaseFirestore.instance.collection('ingredient_categories');

  // Tạo "slug" thân thiện từ tên nguyên liệu (không dấu, snake_case)
  String _slugify(String text) {
    const replacements = {
      'á': 'a', 'à': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
      'ă': 'a', 'ắ': 'a', 'ằ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
      'â': 'a', 'ấ': 'a', 'ầ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a',
      'đ': 'd',
      'é': 'e', 'è': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
      'ê': 'e', 'ế': 'e', 'ề': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
      'í': 'i', 'ì': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
      'ó': 'o', 'ò': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
      'ô': 'o', 'ố': 'o', 'ồ': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
      'ơ': 'o', 'ớ': 'o', 'ờ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
      'ú': 'u', 'ù': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
      'ư': 'u', 'ứ': 'u', 'ừ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
      'ý': 'y', 'ỳ': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
      'Á': 'A', 'À': 'A', 'Ả': 'A', 'Ã': 'A', 'Ạ': 'A',
      'Ă': 'A', 'Ắ': 'A', 'Ằ': 'A', 'Ẳ': 'A', 'Ẵ': 'A', 'Ặ': 'A',
      'Â': 'A', 'Ấ': 'A', 'Ầ': 'A', 'Ẩ': 'A', 'Ẫ': 'A', 'Ậ': 'A',
      'Đ': 'D',
      'É': 'E', 'È': 'E', 'Ẻ': 'E', 'Ẽ': 'E', 'Ẹ': 'E',
      'Ê': 'E', 'Ế': 'E', 'Ề': 'E', 'Ể': 'E', 'Ễ': 'E', 'Ệ': 'E',
      'Í': 'I', 'Ì': 'I', 'Ỉ': 'I', 'Ĩ': 'I', 'Ị': 'I',
      'Ó': 'O', 'Ò': 'O', 'Ỏ': 'O', 'Õ': 'O', 'Ọ': 'O',
      'Ô': 'O', 'Ố': 'O', 'Ồ': 'O', 'Ổ': 'O', 'Ỗ': 'O', 'Ộ': 'O',
      'Ơ': 'O', 'Ớ': 'O', 'Ờ': 'O', 'Ở': 'O', 'Ỡ': 'O', 'Ợ': 'O',
      'Ú': 'U', 'Ù': 'U', 'Ủ': 'U', 'Ũ': 'U', 'Ụ': 'U',
      'Ư': 'U', 'Ứ': 'U', 'Ừ': 'U', 'Ử': 'U', 'Ữ': 'U', 'Ự': 'U',
      'Ý': 'Y', 'Ỳ': 'Y', 'Ỷ': 'Y', 'Ỹ': 'Y', 'Ỵ': 'Y',
    };

    String normalized = text.trim();
    replacements.forEach((k, v) {
      normalized = normalized.replaceAll(k, v);
    });
    normalized = normalized.toLowerCase();
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    normalized = normalized.replaceAll(RegExp(r'_+'), '_');
    normalized = normalized.replaceAll(RegExp(r'^_+|_+$'), '');
    return normalized;
  }

  // Lấy household_id từ SharedPreferences
  Future<String?> _getHouseholdId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('household_code');
  }

  // Lấy danh sách categories từ Firebase
  Future<List<Category>> getCategories() async {
    // Lấy tất cả categories (dùng chung, không phụ thuộc household)
    final snapshot = await _categoryCollection.get();
    
    return snapshot.docs
        .map((doc) => Category.fromFirestore(doc))
        .toList();
  }

  Future<List<Ingredient>> getIngredients() async {
    final householdId = await _getHouseholdId();
    if (householdId == null || householdId.isEmpty) {
      return []; // Nếu chưa có household_id, trả về danh sách rỗng
    }

    // Lọc nguyên liệu theo household_id
    final snapshot = await _collection
        .where('household_id', isEqualTo: householdId)
        .get();
    return snapshot.docs
        .map((doc) => Ingredient.fromFirestore(doc))
        .toList();
  }
  
  Future<void> addIngredient(Ingredient ingredient) async {
    try {
      final householdId = await _getHouseholdId();
      if (householdId == null || householdId.isEmpty) {
        throw Exception('Chưa có mã gia đình. Vui lòng đăng nhập lại.');
      }

      // Tạo trước docId để lưu kèm trong dữ liệu (dễ tham chiếu ở tính năng khác)
      final docRef = _collection.doc();
      final ingredientSlug = _slugify(ingredient.name);

      await docRef.set({
        'ingredient_id': docRef.id,
        'ingredient_slug': ingredientSlug, // id thân thiện, dễ dùng cho AI
        'ingredient_name': ingredient.name,
        'quantity': ingredient.quantity,
        'unit': ingredient.unit,
        'expiration_date': Timestamp.fromDate(ingredient.expirationDate),
        'ingredient_image': ingredient.imageUrl,
        'category_id': ingredient.categoryId,
        'category_name': ingredient.categoryName,
        'household_id': householdId, // Lưu household_id
      });
    } catch (e) {
      throw Exception('Không thể thêm nguyên liệu: ${e.toString()}');
    }
  }

  Future<void> updateIngredient(String id, Ingredient ingredient) async {
    try {
      final householdId = await _getHouseholdId();
      if (householdId == null || householdId.isEmpty) {
        throw Exception('Chưa có mã gia đình. Vui lòng đăng nhập lại.');
      }

      // Kiểm tra xem nguyên liệu có thuộc về household này không
      final doc = await _collection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Nguyên liệu không tồn tại');
      }
      final docHouseholdId = doc.data()?['household_id'];
      if (docHouseholdId != householdId) {
        throw Exception('Không có quyền cập nhật nguyên liệu này');
      }

      await _collection.doc(id).update({
        'ingredient_name': ingredient.name,
        'ingredient_slug': _slugify(ingredient.name),
        'quantity': ingredient.quantity,
        'unit': ingredient.unit,
        'expiration_date': Timestamp.fromDate(ingredient.expirationDate),
        'ingredient_image': ingredient.imageUrl,
        'category_id': ingredient.categoryId,
        'category_name': ingredient.categoryName,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật nguyên liệu: ${e.toString()}');
    }
  }

  Future<void> useIngredient(String id, double amount) async {
    try {
      final householdId = await _getHouseholdId();
      if (householdId == null || householdId.isEmpty) {
        throw Exception('Chưa có mã gia đình. Vui lòng đăng nhập lại.');
      }

      final doc = await _collection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Nguyên liệu không tồn tại');
      }

      // Kiểm tra xem nguyên liệu có thuộc về household này không
      final docHouseholdId = doc.data()?['household_id'];
      if (docHouseholdId != householdId) {
        throw Exception('Không có quyền sử dụng nguyên liệu này');
      }

      final currentQuantity = (doc.data()!['quantity'] as num).toDouble();
      final newQuantity = currentQuantity - amount;

      if (newQuantity <= 0) {
        // Nếu số lượng <= 0, xóa nguyên liệu
        await _collection.doc(id).delete();
      } else {
        // Cập nhật số lượng mới
        await _collection.doc(id).update({
          'quantity': newQuantity,
        });
      }
    } catch (e) {
      throw Exception('Không thể sử dụng nguyên liệu: ${e.toString()}');
    }
  }

  // Trừ nhiều nguyên liệu cùng lúc (dùng khi nấu món ăn)
  // recipeIngredients: Danh sách nguyên liệu cần trừ từ recipe
  Future<Map<String, dynamic>> useIngredientsForRecipe(
    List<Ingredient> pantryIngredients,
    List<dynamic> recipeIngredients,
  ) async {
    final results = {
      'success': <String>[],
      'failed': <String>[],
      'notFound': <String>[],
    };

    try {
      final householdId = await _getHouseholdId();
      if (householdId == null || householdId.isEmpty) {
        throw Exception('Chưa có mã gia đình. Vui lòng đăng nhập lại.');
      }

      // Tạo map để tìm nguyên liệu trong kho nhanh hơn
      final Map<String, Ingredient> pantryMap = {};
      for (var ingredient in pantryIngredients) {
        // Map theo slug (id thân thiện)
        final normalizedSlug = _slugify(ingredient.name).toLowerCase();
        pantryMap[normalizedSlug] = ingredient;
        
        // Map theo id nếu có
        if (ingredient.id.isNotEmpty) {
          pantryMap[ingredient.id] = ingredient;
        }
      }

      // Xử lý từng nguyên liệu trong recipe
      for (var requiredIngredient in recipeIngredients) {
        try {
          // Parse dữ liệu từ recipe ingredient
          final requiredId = (requiredIngredient['id'] ?? '').toString().toLowerCase();
          final requiredName = (requiredIngredient['name'] ?? '').toString();
          final requiredAmount = (requiredIngredient['amount'] as num?)?.toDouble() ?? 0.0;
          final requiredUnit = (requiredIngredient['unit'] ?? '').toString().toLowerCase();

          if (requiredAmount <= 0) continue;

          // Tìm nguyên liệu trong kho
          Ingredient? pantryIngredient;
          
          // Ưu tiên tìm theo id (slug) từ recipe
          if (requiredId.isNotEmpty && pantryMap.containsKey(requiredId)) {
            pantryIngredient = pantryMap[requiredId];
          } else {
            // Tìm theo tên (normalized slug)
            final normalizedRequiredId = _slugify(requiredName).toLowerCase();
            pantryIngredient = pantryMap[normalizedRequiredId];
            
            // Nếu vẫn không tìm thấy, tìm theo tên tương tự
            if (pantryIngredient == null) {
              try {
                pantryIngredient = pantryMap.values.firstWhere(
                  (ing) {
                    final ingSlug = _slugify(ing.name).toLowerCase();
                    return ingSlug == normalizedRequiredId || 
                           ingSlug.contains(normalizedRequiredId) ||
                           normalizedRequiredId.contains(ingSlug);
                  },
                );
              } catch (e) {
                // Không tìm thấy
                pantryIngredient = null;
              }
            }
          }

          if (pantryIngredient == null) {
            results['notFound']!.add(requiredName);
            continue;
          }

          // Chuyển đổi đơn vị và tính số lượng cần trừ
          final convertedAmount = _convertUnitForRecipe(
            requiredAmount,
            requiredUnit,
            pantryIngredient.unit.toLowerCase(),
          );

          // Kiểm tra số lượng có đủ không
          if (pantryIngredient.quantity < convertedAmount) {
            results['failed']!.add('$requiredName (thiếu ${convertedAmount - pantryIngredient.quantity} ${pantryIngredient.unit})');
            continue;
          }

          // Trừ nguyên liệu
          await useIngredient(pantryIngredient.id, convertedAmount);
          results['success']!.add(requiredName);
        } catch (e) {
          final ingredientName = (requiredIngredient['name'] ?? 'Nguyên liệu').toString();
          results['failed']!.add('$ingredientName: ${e.toString()}');
        }
      }

      return results;
    } catch (e) {
      throw Exception('Không thể sử dụng nguyên liệu: ${e.toString()}');
    }
  }

  // Chuyển đổi đơn vị cho recipe (đơn giản hóa)
  double _convertUnitForRecipe(double amount, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return amount;

    // Chuyển về gram hoặc ml làm đơn vị chuẩn
    double amountInBase = amount;
    
    // Chuyển từUnit về base
    if (['kg', 'kilogram'].contains(fromUnit)) {
      amountInBase = amount * 1000; // kg -> g
    } else if (['l', 'liter', 'litre'].contains(fromUnit)) {
      amountInBase = amount * 1000; // l -> ml
    }

    // Chuyển từ base về toUnit
    if (['kg', 'kilogram'].contains(toUnit)) {
      return amountInBase / 1000; // g -> kg
    } else if (['l', 'liter', 'litre'].contains(toUnit)) {
      return amountInBase / 1000; // ml -> l
    }

    // Nếu cùng nhóm đơn vị (g, ml, piece, item, etc.) thì không cần chuyển
    return amount;
  }
}
