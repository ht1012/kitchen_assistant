import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            _buildShoppingListContent(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildHeaderSection() {
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
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101727),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            '6 thực phẩm cần có trong kho nguyên liệu',
            style: TextStyle(fontSize: 15, color: Color(0xFF495565)),
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
              widthFactor: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF155CFB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 of 7 items',
                style: TextStyle(fontSize: 13, color: Color(0xFF495565)),
              ),
              Text(
                '0%',
                style: TextStyle(
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
                  '7',
                  const Color(0xFFEEF5FE),
                  const Color(0xFFBDDAFF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Đã mua',
                  '0',
                  const Color(0xFFF0FDF4),
                  const Color(0xFFB8F7CF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Còn thiếu',
                  '6',
                  const Color(0xFFFFF7EC),
                  const Color(0xFFFFD6A7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildShoppingListContent() {
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
            _buildCategorySection('🥬', 'Rau củ', 3, [
              _buildShoppingItem('Cà chua', '4kg', 'Mì Ý sốt kem cà chua'),
              _buildShoppingItem('Tỏi', '4 tép', 'Mì Ý sốt kem cà chua'),
              _buildShoppingItem('Húng quế', '1 bó', 'Mì Ý sốt kem cà chua'),
            ]),

            const SizedBox(height: 32),

            _buildCategorySection('🥩', 'Thịt & Hải sản', 2, [
              _buildShoppingItem('Ức gà', '2 miếng', 'Mì Ý sốt kem cà chua'),
              _buildShoppingItem(
                'Phi lê cá hồi',
                '2 miếng',
                'Mì Ý sốt kem cà chua',
              ),
            ]),

            const SizedBox(height: 32),

            _buildCategorySection('🍞', 'Khác', 1, [
              _buildShoppingItem(
                'Bánh mì',
                '1 cái',
                'Mì Ý sốt kem cà chua',
                hasEdit: true,
              ),
            ]),

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
    List<Widget> items,
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

      
        ...items,
      ],
    );
  }


  Widget _buildShoppingItem(
    String name,
    String quantity,
    String recipe, {
    bool hasEdit = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
        
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD0D5DB), width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          const SizedBox(width: 12),

        
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF101727),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  quantity,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF495565),
                  ),
                ),

                const SizedBox(height: 12),

              
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
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
                      const Text(
                        '1 công thức',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFC93400),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Món ăn: $recipe',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF697282),
                  ),
                ),
              ],
            ),
          ),

        
          Row(
            children: [
              if (hasEdit) const Text('✏️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              ColorFiltered(
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
            ],
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
                child: const CreateShopping(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CreateShopping extends StatefulWidget {
  const CreateShopping({super.key});

  @override
  State<CreateShopping> createState() => _CreateShoppingState();
}

class _CreateShoppingState extends State<CreateShopping> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
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
          decoration: InputDecoration(
            hintText: 'e.g. 2 quả',
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
            final itemWidth =
                (constraints.maxWidth - spacing) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: categories.map((category) {
                final isSelected =
                    selectedCategory == category['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category['name']!;
                    });
                  },
                  child: SizedBox(
                    width: itemWidth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
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
                          color: isSelected
                              ? Colors.white
                              : Colors.black,
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
        onPressed: () {
        
          if (nameController.text.isNotEmpty &&
              quantityController.text.isNotEmpty &&
              selectedCategory.isNotEmpty) {
          
            Navigator.pop(context);
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
    super.dispose();
  }
}
