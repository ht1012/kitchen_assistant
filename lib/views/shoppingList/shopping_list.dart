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
            // Header Section
            _buildHeaderSection(),
            
            // Shopping List Content
            _buildShoppingListContent(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Header với thông tin tổng quan
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF2F4F6), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          // Title Row
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
          
          // Subtitle
          const Text(
            '6 thực phẩm cần có trong kho nguyên liệu',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF495565),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Progress Bar
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.0, // 0% progress
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF155CFB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Progress Text
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 of 7 items',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF495565),
                ),
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
          
          // Statistics Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Tổng', '7', const Color(0xFFEEF5FE), const Color(0xFFBDDAFF))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Đã mua', '0', const Color(0xFFF0FDF4), const Color(0xFFB8F7CF))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Còn thiếu', '6', const Color(0xFFFFF7EC), const Color(0xFFFFD6A7))),
            ],
          ),
        ],
      ),
    );
  }

  // Card thống kê nhỏ
  Widget _buildStatCard(String title, String value, Color bgColor, Color borderColor) {
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
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF495565),
            ),
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

  // Nội dung danh sách mua sắm
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
            // Rau củ section
            _buildCategorySection('🥬', 'Rau củ', 3, [
              _buildShoppingItem('Cà chua', '4kg', 'Mì Ý sốt kem cà chua'),
              _buildShoppingItem('Tỏi', '4 tép', 'Mì Ý sốt kem cà chua'),
              _buildShoppingItem('Húng quế', '1 bó', 'Mì Ý sốt kem cà chua'),
            ]),
            
            const SizedBox(height: 32),
            
            // Thịt & Hải sản section
            _buildCategorySection('🥩', 'Thịt & Hải sản', 2, [
              _buildShoppingItem('Ức gà', '2 miếng', 'Mì Ý sốt kem cà chua'),
              _buildShoppingItem('Phi lê cá hồi', '2 miếng', 'Mì Ý sốt kem cà chua'),
            ]),
            
            const SizedBox(height: 32),
            
            // Khác section
            _buildCategorySection('🍞', 'Khác', 1, [
              _buildShoppingItem('Bánh mì', '1 cái', 'Mì Ý sốt kem cà chua', hasEdit: true),
            ]),
            
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  // Section cho từng loại thực phẩm
  Widget _buildCategorySection(String emoji, String title, int count, List<Widget> items) {
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
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF354152),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Danh sách items
        ...items,
      ],
    );
  }

  // Item trong danh sách mua sắm
  Widget _buildShoppingItem(String name, String quantity, String recipe, {bool hasEdit = false}) {
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
          // Checkbox
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD0D5DB), width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
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
                
                // Recipe tag
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
                        color: const Color(0xFFC93400),
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
          
          // Actions
          Row(
            children: [
              if (hasEdit)
                const Text('✏️', style: TextStyle(fontSize: 16)),
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

  // Floating Action Button
  Widget _buildFloatingActionButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7BF1A8), Color(0xFF7BF1A8)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.add,
        size: 28,
        color: Colors.white,
      ),
    );
  }
}
