import 'package:flutter/material.dart';
import 'recip-card.dart';
class Recipes extends StatelessWidget {
  const Recipes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: Column(
          children: [
            //body cuộn
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    // Bộ lọc (Filter)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterSection('Thời gian nấu ăn', ['Tất cả', 'Nhanh (≤20’)', 'Trung bình', 'Dài (>35’)']),
                          const SizedBox(height: 15),
                          _buildFilterSection('Loại ẩm thực', ['Tất cả', 'Italian', 'American', 'Asian']),
                          const SizedBox(height: 15),
                          _buildFilterSection('Thời điểm', ['Tất cả', 'Sáng', 'Trưa', 'Tối']),
                          const SizedBox(height: 15),
                          _buildFilterSection('Khẩu phần ăn', ['Tất cả', '1 người', '2-4 người', '> 5 người'])
                        ],
                      ),
                    ),
                    // Thông báo tìm thấy
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Center(
                        child: Text(
                          'Đã tìm thấy 3 công thức nấu ăn',
                          style: TextStyle(
                            color: Color(0xFF495565),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Danh sách món ăn
                    const RecipeCard(
                      title: 'Cá hồi nướng với rau',
                      image: "assets/images/recipes/recipe1.png",
                      time: '30 phút',
                      steps: '7/7',
                      tags: ['American', 'Trung bình'],
                      matchPercent: 100,
                    ),
                    const SizedBox(height: 15),
                    const RecipeCard(
                      title: 'Cá hồi nướng với rau',
                      image: "assets/images/recipes/recipe1.png",
                      time: '30 phút',
                      steps: '7/7',
                      tags: ['American', 'Dễ'],
                      matchPercent: 100,
                    ),
                    const SizedBox(height: 15),
                    const RecipeCard(
                      title: 'Mỳ ống sốt cà chua',
                      image: "assets/images/recipes/recipe2.png",
                      time: '30 phút',
                      steps: '5/6',
                      tags: ['Italian', 'Dễ'],
                      matchPercent: 83,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Widget con: Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7BF1A8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.restaurant_menu, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Gợi ý món ăn',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Gợi ý cá nhân hóa dựa trên tủ đựng thức ăn của bạn',
            style: TextStyle(color: Color(0xFF495565), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Widget con: Section lọc
  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF495565), fontSize: 13)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((e) => Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // Logic đổi màu đơn giản: Cái đầu tiên (Tất cả) thì màu xanh
                color: e == options.first ? const Color(0xFF05DF72) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: e == options.first ? Colors.transparent : const Color(0xFFE5E7EB)),
              ),
              child: Text(
                e == options.first ? e+' x' : e,
                style: TextStyle(color: e == options.first ? Colors.white : Colors.black),
              ),
            )).toList(),
          ),
        )
      ],
    );
  }
}