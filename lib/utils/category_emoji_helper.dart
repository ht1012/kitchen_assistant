class CategoryEmojiHelper {
  // Map emoji theo categoryId
  static const Map<String, String> _emojiByIdMap = {
    'vegetable': '🥬',
    'rau_cu': '🥬',
    'meat': '🥩',
    'meat_seafood': '🥩',
    'thit_hai_san': '🥩',
    'bakery': '🍞',
    'banh': '🍞',
    'dairy': '🥛',
    'sua': '🥛',
    'frozen': '❄️',
    'dong_lanh': '❄️',
    'fruit': '🍎',
    'trai_cay': '🍎',
    'drink': '🥤',
    'do_uong': '🥤',
    'spice': '🧂',
    'gia_vi': '🧂',
  };

  // Map emoji theo categoryName (tiếng Việt)
  static const Map<String, String> _emojiByNameMap = {
    'Rau củ': '🥬',
    'Thịt & Hải sản': '🥩',
    'Thịt': '🥩',
    'Hải sản': '🦐',
    'Bánh': '🍞',
    'Sữa': '🥛',
    'Đông lạnh': '❄️',
    'Trái cây': '🍎',
    'Đồ uống': '🥤',
    'Gia vị': '🧂',
    'Khác': '📦',
  };

  /// Lấy emoji từ categoryId
  static String getEmojiById(String categoryId) {
    return _emojiByIdMap[categoryId.toLowerCase()] ?? '📦';
  }

  /// Lấy emoji từ categoryName
  static String getEmojiByName(String categoryName) {
    return _emojiByNameMap[categoryName] ?? '📦';
  }

  /// Lấy emoji - ưu tiên theo categoryId, fallback sang categoryName
  static String getEmoji({String? categoryId, String? categoryName}) {
    if (categoryId != null && categoryId.isNotEmpty) {
      final emoji = _emojiByIdMap[categoryId.toLowerCase()];
      if (emoji != null) return emoji;
    }

    if (categoryName != null && categoryName.isNotEmpty) {
      final emoji = _emojiByNameMap[categoryName];
      if (emoji != null) return emoji;
    }

    return '📦'; // Default emoji
  }
}