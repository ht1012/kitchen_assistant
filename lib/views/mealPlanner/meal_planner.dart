import 'package:flutter/material.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white],
            ),
          ),
          child: Column(
            children: [
              
              _buildHeader(),

              
              _buildWeeklyPlan(),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
        },
        backgroundColor: const Color(0xFF7BF1A8),
        shape: const CircleBorder(), 
        child: const Icon(
          Icons.add,
          color: Colors.white, 
          size: 28,
        ),
      ),
    );
  }

  
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7BF1A8), Color(0xFF7BF1A8)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/icon_mealPlane.png',
                  color: Colors.white,
                  fit: BoxFit.contain,
                ),
              ),
            ),
              const SizedBox(width: 12),
              const Text(
                'Lập kế hoạch bữa ăn',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101727),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '0/21 bữa ăn đã lên kế hoạch cho tuần này',
            style: TextStyle(fontSize: 14, color: Color(0xFF495565)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios),
              ),

              Image.asset(
                'assets/images/icon_mealPlane.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                color: const Color(0xFF7BF1A8),
                colorBlendMode: BlendMode.srcIn,
              ),

              const SizedBox(width: 8),

              const Text(
                '12 Thg 8 – 18 Thg 8',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),

        ],
      ),
    );
  }

  
  Widget _buildWeeklyPlan() {
    final List<Map<String, dynamic>> weekDays = [
      {'day': 'Thứ 2', 'date': '12'},
      {'day': 'Thứ 3', 'date': '13'},
      {'day': 'Thứ 4', 'date': '14'},
      {'day': 'Thứ 5', 'date': '15'},
      {'day': 'Thứ 6', 'date': '16'},
      {'day': 'Thứ 7', 'date': '17'},
      {'day': 'Chủ nhật', 'date': '18'},
    ];

    return Column(
      children: weekDays.map((dayInfo) => _buildDayCard(dayInfo)).toList(),
    );
  }

  
  Widget _buildDayCard(Map<String, dynamic> dayInfo) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Center(
                    child: Text(
                      dayInfo['date'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dayInfo['day'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          
          _buildMealSection(
            '☀️',
            'Sáng',
            dayInfo['day'] == 'Thứ 2' ? 'Phở bò' : null,
          ),
          _buildMealSection(
            '🌤',
            'Trưa',
            dayInfo['day'] == 'Thứ 2' ? ['Cơm gà xối mỡ', 'Rau xào'] : null,
          ),
          _buildMealSection(
            '🌙',
            'Tối',
            dayInfo['day'] == 'Thứ 4' ? 'Phở bò' : null,
          ),
        ],
      ),
    );
  }

  
  Widget _buildMealSection(String emoji, String mealTime, dynamic meals) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                mealTime,
                style: const TextStyle(fontSize: 14, color: Color(0xFF495565)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (meals != null) ...[
            if (meals is String)
              _buildMealItem(meals, false)
            else if (meals is List)
              ...meals
                  .map((meal) => _buildMealItem(meal, meal == 'Cơm gà xối mỡ'))
                  .toList(),
            _buildAddMealButton(),
          ] else
            _buildEmptyMealSlot(),
        ],
      ),
    );
  }

  
  Widget _buildMealItem(String mealName, bool hasWarning) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasWarning ? Colors.white : const Color(0x4CA7D4B9),
        borderRadius: BorderRadius.circular(10),
        border: hasWarning ? Border.all(color: const Color(0xFFE5E7EB)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mealName,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1D2838)),
            ),
            GestureDetector(
              onTap: () {
                
              },
              child: const Text(
                'X',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D2838),
                ),
              ),
            ),
          ],
        ),
          if (hasWarning) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Image.asset(
                  'assets/images/icon_conthieu.png',
                  width: 14,
                  height: 14,
                  fit: BoxFit.contain,
                  color: const Color(0xFFFFB84D), 
                  colorBlendMode: BlendMode.srcIn,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Thiếu 2 nguyên liệu',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFFB84D),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  
  Widget _buildAddMealButton() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D5DB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: Color(0xFF99A1AE)),
            SizedBox(width: 8),
            Text(
              'Thêm món',
              style: TextStyle(color: Color(0xFF99A1AE), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildEmptyMealSlot() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D5DB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          
        },
        child: const Text(
          'Chưa có món',
          style: TextStyle(color: Color(0xFF99A1AE), fontSize: 14),
        ),
      ),
    );
  }
}