import 'dart:convert';
import 'package:http/http.dart' as http;

class BarcodeService {
  /// Tra cứu thông tin sản phẩm từ barcode
  static Future<Map<String, dynamic>?> lookupBarcode(String barcode) async {
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout: Không thể kết nối đến server');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Kiểm tra status
        final status = data['status'];
        if (status == 1 && data.containsKey('product')) {
          final product = data['product'] as Map<String, dynamic>;
          return _parseProductData(product, barcode);
        } else {
          // Status = 0 nghĩa là không tìm thấy sản phẩm trong database
          // Đây là điều bình thường, không phải lỗi
          return null;
        }
      } else {
        // Lỗi HTTP
        throw Exception('Lỗi HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi tra cứu barcode: ${e.toString()}');
    }
  }

  /// Parse dữ liệu sản phẩm từ API response
  static Map<String, dynamic> _parseProductData(Map<String, dynamic> product, String barcode) {
    // Parse tên sản phẩm - ưu tiên tiếng Việt
    String productName = '';
    if (product.containsKey('product_name_vi') && 
        product['product_name_vi'] != null && 
        product['product_name_vi'].toString().trim().isNotEmpty) {
      productName = product['product_name_vi'].toString().trim();
    } else if (product.containsKey('product_name') && 
               product['product_name'] != null &&
               product['product_name'].toString().trim().isNotEmpty) {
      productName = product['product_name'].toString().trim();
    } else if (product.containsKey('product_name_en') && 
               product['product_name_en'] != null &&
               product['product_name_en'].toString().trim().isNotEmpty) {
      productName = product['product_name_en'].toString().trim();
    } else if (product.containsKey('abbreviated_product_name') && 
               product['abbreviated_product_name'] != null) {
      productName = product['abbreviated_product_name'].toString().trim();
    }
    
    // Parse quantity
    String quantityStr = '';
    if (product.containsKey('quantity') && product['quantity'] != null) {
      quantityStr = product['quantity'].toString();
    } else if (product.containsKey('product_quantity') && product['product_quantity'] != null) {
      quantityStr = product['product_quantity'].toString();
    }
    final quantity = _parseQuantity(quantityStr);
    
    // Parse category
    String categoryName = '';
    if (product.containsKey('categories') && product['categories'] != null) {
      categoryName = product['categories'].toString();
    } else if (product.containsKey('categories_tags') && 
               product['categories_tags'] is List && 
               (product['categories_tags'] as List).isNotEmpty) {
      categoryName = (product['categories_tags'] as List).first.toString();
    }
    final categoryId = _mapCategoryFromName(categoryName);
    
    return {
      'name': productName.isNotEmpty ? productName : barcode,
      'quantity': quantity['value'],
      'unit': quantity['unit'],
      'categoryId': categoryId,
    };
  }

  /// Parse quantity từ string như "500g", "1kg", "250ml"
  static Map<String, String?> _parseQuantity(String quantityStr) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*([a-zA-Z]+)?');
    final match = regex.firstMatch(quantityStr);
    
    if (match != null) {
      final value = match.group(1);
      final unit = match.group(2)?.toLowerCase();
      
      // Map unit về chuẩn app
      String? mappedUnit;
      if (unit != null) {
        switch (unit) {
          case 'g':
          case 'gram':
          case 'grams':
            mappedUnit = 'g';
            break;
          case 'kg':
          case 'kilogram':
          case 'kilograms':
            mappedUnit = 'kg';
            break;
          case 'ml':
          case 'milliliter':
          case 'milliliters':
            mappedUnit = 'ml';
            break;
          case 'l':
          case 'liter':
          case 'liters':
          case 'litre':
          case 'litres':
            mappedUnit = 'l';
            break;
        }
      }
      
      return {'value': value, 'unit': mappedUnit};
    }
    
    return {'value': null, 'unit': null};
  }

  /// Map category name về categoryId
  static String? _mapCategoryFromName(String categoryName) {
    final lower = categoryName.toLowerCase();
    
    if (lower.contains('fruit') || lower.contains('trái cây') || 
        lower.contains('hoa quả') || lower.contains('quả')) {
      return 'fruit';
    } else if (lower.contains('vegetable') || lower.contains('rau củ') || 
               lower.contains('rau') || lower.contains('củ')) {
      return 'vegetable';
    } else if (lower.contains('meat') || lower.contains('thịt') || 
               lower.contains('cá') || lower.contains('fish')) {
      return 'meat';
    } else if (lower.contains('drink') || lower.contains('đồ uống') || 
               lower.contains('nước') || lower.contains('beverage')) {
      return 'drink';
    }
    
    return null;
  }
}

