import 'package:flutter/material.dart';
import 'package:kitchen_assistant/views/recipes/recipe_detail.dart';

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
  Color _getTagColor(String tag) {
    // Hàm lấy màu sắc dựa trên thẻ
    // Ví dụ đơn giản, bạn có thể mở rộng theo nhu cầu
    if (tag == 'Dễ') {
      return Colors.green[100]!;
    } else if (tag == 'Trung bình') {
      return Colors.orange[100]!;
    } else if (tag == 'Cao') {
      return Colors.red[100]!;
    } else {
      return Colors.grey[200]!;
    }
  }

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
                    decoration: BoxDecoration(
                      color: _getTagColor(t),
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetail()
                            ),
                            );
                        }, // <--- Thêm logic chuyển trang ở đây nếu muốn
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