import 'package:flutter/material.dart';
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


// --- WIDGET TÁI SỬ DỤNG: CARD MÓN ĂN ---
class RecipeCard extends StatelessWidget {
  final String title;
  final String image;
  final String time;
  final String steps;
  final List<String> tags;
  final int matchPercent;

  const RecipeCard({
    super.key,
    required this.title,
    required this.image,
    required this.time,
    required this.steps,
    required this.tags,
    required this.matchPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Ảnh & Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(image, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Text(time, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
          // Nội dung
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: tags.map((t) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(8)),
                    child: Text(t, style: const TextStyle(fontSize: 11)),
                  )).toList(),
                ),
                const SizedBox(height: 10),
                // Thanh tiến trình
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Độ phù hợp', style: TextStyle(color: Colors.grey)),
                    Text('$matchPercent%', style: TextStyle(color: matchPercent == 100 ? Colors.green : Colors.orange)),
                  ],
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: matchPercent / 100,
                  backgroundColor: const Color(0xFFF2F4F6),
                  color: matchPercent == 100 ? const Color(0xFF00C850) : Colors.orange,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 15),
                // Nút bấm
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {}, // <--- Thêm logic chuyển trang ở đây nếu muốn
                        style: ElevatedButton.styleFrom(
                          backgroundColor: matchPercent == 100 ? const Color(0xFF00C850) : Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Xem công thức'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00C850),
                          side: const BorderSide(color: Color(0xFF00C850)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Tạo kế hoạch'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}


