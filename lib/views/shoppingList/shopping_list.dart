import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/shopping_list_viewmodel.dart';
import '../../viewmodels/virtualPantry/pantry_viewmodel.dart';
import '../../models/shopping_list_model.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late ShoppingListViewModel _viewModel;
  final Set<String> _checkedItems = {}; // Track checked items

  @override
  void initState() {
    super.initState();
    _viewModel = ShoppingListViewModel();
    _viewModel.loadShoppingItems();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<List<ShoppingItem>>(
          stream: _viewModel.getShoppingItemsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            final items = snapshot.data ?? [];
            final groupedItems = _groupItemsByCategory(items);
            final stats = _calculateStats(items);

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Truyền allItems vào header
                  _buildHeaderSection(stats, items.length, items),
                  _buildShoppingListContent(groupedItems),
                ],
              ),
            );
          },
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  Map<String, List<ShoppingItem>> _groupItemsByCategory(
    List<ShoppingItem> items,
  ) {
    final Map<String, List<ShoppingItem>> grouped = {};

    for (var item in items) {
      // Lấy category từ ingredientId (sẽ được resolve sau)
      const categoryName = 'Khác'; // Mặc định

      if (!grouped.containsKey(categoryName)) {
        grouped[categoryName] = [];
      }
      grouped[categoryName]!.add(item);
    }

    return grouped;
  }

  Map<String, dynamic> _calculateStats(List<ShoppingItem> items) {
    final total = items.length;
    final checked = _checkedItems.length;
    final pending = total - checked;
    final percentage = total > 0 ? (checked / total * 100).round() : 0;

    return {
      'total': total,
      'purchased': checked,
      'pending': pending,
      'percentage': percentage,
    };
  }

  String _getCategoryEmoji(String categoryName) {
    switch (categoryName) {
      case 'Rau củ':
        return '🥬';
      case 'Thịt & Hải sản':
        return '🥩';
      case 'Bánh':
        return '🍞';
      case 'Sữa':
        return '🥛';
      case 'Đông lạnh':
        return '❄️';
      default:
        return '📦';
    }
  }

  Widget _buildHeaderSection(
    Map<String, dynamic> stats,
    int totalItems,
    List<ShoppingItem> allItems,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7BF1A8), Color(0xFF7BF1A8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Danh sách mua sắm',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101727),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$totalItems thực phẩm cần có trong kho nguyên liệu',
            style: const TextStyle(fontSize: 15, color: Color(0xFF495565)),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: stats['total'] > 0
                  ? (_checkedItems.length / stats['total']).clamp(0.0, 1.0)
                  : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF155CFB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_checkedItems.length} of ${stats['total']} items',
                style: const TextStyle(fontSize: 13, color: Color(0xFF495565)),
              ),
              Text(
                '${stats['total'] > 0 ? (_checkedItems.length / stats['total'] * 100).round() : 0}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF155CFB),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng',
                  stats['total'].toString(),
                  const Color(0xFFEEF5FE),
                  const Color(0xFFBDDAFF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Đã chọn',
                  _checkedItems.length.toString(),
                  const Color(0xFFF0FDF4),
                  const Color(0xFFB8F7CF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Còn lại',
                  (stats['total'] - _checkedItems.length).toString(),
                  const Color(0xFFFFF7EC),
                  const Color(0xFFFFD6A7),
                ),
              ),
            ],
          ),
          // Button thêm vào kho
          if (_checkedItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _addCheckedItemsToPantry(allItems),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7BF1A8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Thêm vào kho',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Xử lý thêm items đã check vào kho
  Future<void> _addCheckedItemsToPantry(List<ShoppingItem> allItems) async {
    if (_checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một item'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Lọc ra các items đã được check từ danh sách stream
      final checkedItemsList = allItems
          .where((item) => _checkedItems.contains(item.id))
          .toList();

      if (checkedItemsList.isEmpty) {
        throw Exception('Không tìm thấy items đã chọn');
      }

      // Gọi ViewModel với danh sách items thực tế
      await _viewModel.addCheckedItemsToPantry(checkedItemsList);

      // Refresh pantry nếu có
      try {
        final pantryViewModel = Provider.of<PantryViewModel>(
          context,
          listen: false,
        );
        await pantryViewModel.loadIngredients();
      } catch (e) {
        print('Lỗi refresh pantry: $e');
      }

      // Clear checked items
      setState(() {
        _checkedItems.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm vào kho nguyên liệu!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color bgColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Color(0xFF495565)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101727),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListContent(
    Map<String, List<ShoppingItem>> groupedItems,
  ) {
    if (groupedItems.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        child: const Column(
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Danh sách mua sắm trống',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0FDF4), Colors.white],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ...groupedItems.entries.map((entry) {
              return Column(
                children: [
                  _buildCategorySection(
                    _getCategoryEmoji(entry.key),
                    entry.key,
                    entry.value.length,
                    entry.value,
                  ),
                  if (entry != groupedItems.entries.last)
                    const SizedBox(height: 32),
                ],
              );
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    String emoji,
    String title,
    int count,
    List<ShoppingItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF101727),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(fontSize: 12, color: Color(0xFF354152)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _buildShoppingItem(item)),
      ],
    );
  }

  Widget _buildShoppingItem(ShoppingItem item) {
    final isChecked = _checkedItems.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isChecked ? const Color(0xFF7BF1A8) : const Color(0xFFE5E7EB),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Checkbox - CHỈ CẬP NHẬT LOCAL STATE
          GestureDetector(
            onTap: () {
              setState(() {
                if (isChecked) {
                  _checkedItems.remove(item.id);
                } else {
                  _checkedItems.add(item.id);
                }
              });
              // KHÔNG gọi database ở đây
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF7BF1A8) : Colors.transparent,
                border: Border.all(
                  color: isChecked
                      ? const Color(0xFF7BF1A8)
                      : const Color(0xFFD0D5DB),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIngredientName(item),
                const SizedBox(height: 4),
                Text(
                  '${item.requiredQuantity} ${item.unit}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF495565),
                  ),
                ),
                // Hiển thị tên công thức nấu ăn
                if (item.recipeIds.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildRecipeNames(item.recipeIds),
                ],
              ],
            ),
          ),
          // Delete button
          GestureDetector(
            onTap: () => _showDeleteDialog(item),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFF99A1AF),
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/images/icon_trash.png',
                width: 16,
                height: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientName(ShoppingItem item) {
    return FutureBuilder<String>(
      future: _viewModel.getIngredientName(item.ingredientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Đang tải...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF101727),
            ),
          );
        }

        final name = snapshot.data ?? item.ingredientId;
        return Text(
          name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101727),
          ),
        );
      },
    );
  }

Widget _buildRecipeNames(List<String> recipeIds) {
  return FutureBuilder<List<String>>(
    future: _viewModel.getRecipeNames(recipeIds),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox.shrink();
      }

      final recipeNames = snapshot.data ?? [];
      if (recipeNames.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECD4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/icon_viewRecipe.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFC93400),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${recipeNames.length} công thức',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC93400),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Món ăn: ${recipeNames.join(', ')}',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF697282),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    },
  );
}

  void _showEditDialog(ShoppingItem item) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chỉnh sửa đang được phát triển')),
    );
  }

  void _showDeleteDialog(ShoppingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục'),
        content: const Text('Bạn có chắc chắn muốn xóa mục này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _viewModel.deleteShoppingItem(item.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showCreateShoppingDialog(context);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7BF1A8), Color(0xFF7BF1A8)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  void _showCreateShoppingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CreateShopping(viewModel: _viewModel),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CreateShopping extends StatefulWidget {
  final ShoppingListViewModel viewModel;

  const CreateShopping({super.key, required this.viewModel});

  @override
  State<CreateShopping> createState() => _CreateShoppingState();
}

class _CreateShoppingState extends State<CreateShopping> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  String selectedCategory = '';

  final List<Map<String, String>> categories = [
    {'emoji': '🥬', 'name': 'Rau củ'},
    {'emoji': '🥩', 'name': 'Thịt & Hải sản'},
    {'emoji': '🍞', 'name': 'Bánh'},
    {'emoji': '🥛', 'name': 'Sữa'},
    {'emoji': '❄️', 'name': 'Đông lạnh'},
    {'emoji': '📦', 'name': 'Khác'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildNameField(),
            const SizedBox(height: 24),
            _buildQuantityField(),
            const SizedBox(height: 24),
            _buildUnitField(),
            const SizedBox(height: 24),
            _buildCategorySection(),
            const SizedBox(height: 32),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Thêm thực phẩm',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF101727),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.close, color: Color(0xFF354152), size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tên thực phẩm',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101727),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'e.g. Táo',
            hintStyle: const TextStyle(color: Color(0xFF697282), fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF00C850), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số lượng',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101727),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g. 2',
            hintStyle: const TextStyle(color: Color(0xFF697282), fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF00C850), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đơn vị',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101727),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: unitController,
          decoration: InputDecoration(
            hintText: 'e.g. kg, quả, miếng',
            hintStyle: const TextStyle(color: Color(0xFF697282), fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF00C850), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101727),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const columns = 2;
            const spacing = 12.0;
            final itemWidth = (constraints.maxWidth - spacing) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: categories.map((category) {
                final isSelected = selectedCategory == category['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category['name']!;
                    });
                  },
                  child: SizedBox(
                    width: itemWidth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00C850)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00C850)
                              : const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${category['emoji']} ${category['name']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          if (nameController.text.isNotEmpty &&
              quantityController.text.isNotEmpty &&
              unitController.text.isNotEmpty &&
              selectedCategory.isNotEmpty) {
            try {
              final quantity = double.tryParse(quantityController.text);
              if (quantity == null || quantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Số lượng không hợp lệ'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Tạo ingredient_id từ tên (có thể cải thiện sau)
              final ingredientId = nameController.text.toLowerCase().replaceAll(
                ' ',
                '_',
              );

              await widget.viewModel.addManualShoppingItem(
                ingredientId: ingredientId,
                ingredientName: nameController.text,
                quantity: quantity,
                unit: unitController.text,
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã thêm vào danh sách mua sắm'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng điền đầy đủ thông tin'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C850),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Thêm vào danh sách',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    super.dispose();
  }
}
