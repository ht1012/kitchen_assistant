import 'package:flutter/material.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header section
          _buildHeader(),
          // Main content
          Expanded(
            child: _buildMealPlanGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF2F4F6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon app
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7BF1A8), Color(0xFF7BF1A8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/icon_mealPlane.png',
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                    color: Colors.white, // bỏ nếu không cần đổi màu
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title
              const Text(
                'Lập kế hoạch bữa ăn',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101727),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            '0/21 bữa ăn đã lên kế hoạch',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF495565),
            ),
          ),
        ],
      ),
    );
  }

  // Lưới kế hoạch bữa ăn
  Widget _buildMealPlanGrid() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0FDF4), Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header các loại bữa ăn
            _buildMealTypeHeaders(),
            const SizedBox(height: 24),
            // Lưới 7 ngày
            ..._buildWeekDays(),
          ],
        ),
      ),
    );
  }

  // Header loại bữa ăn
  Widget _buildMealTypeHeaders() {
    return Row(
      children: [
        const SizedBox(width: 55), // Khoảng trống cho cột ngày
        Expanded(
          child: _buildMealTypeHeader('🌅 BREAKFAST'),
        ),
        Expanded(
          child: _buildMealTypeHeader('☀️ LUNCH'),
        ),
        Expanded(
          child: _buildMealTypeHeader('🌙 DINNER'),
        ),
      ],
    );
  }

  Widget _buildMealTypeHeader(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF697282),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
    );
  }

  // Xây dựng 7 ngày trong tuần
  List<Widget> _buildWeekDays() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
    
    return List.generate(7, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildDayRow(days[index], dayNames[index], index == 1), // Thứ 3 có món ăn
      );
    });
  }

  // Hàng của mỗi ngày
  Widget _buildDayRow(String dayCode, String dayName, bool hasFood) {
    return Row(
      children: [
        // Nhãn ngày
        _buildDayLabel(dayCode),
        const SizedBox(width: 16),
        // 3 bữa ăn
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildMealCard(hasFood && dayCode == 'Tue' ? 'Cá hồi nướng' : null)),
              const SizedBox(width: 8),
              Expanded(child: _buildMealCard(null)),
              const SizedBox(width: 8),
              Expanded(child: _buildMealCard(null)),
            ],
          ),
        ),
      ],
    );
  }

  // Nhãn ngày trong tuần
  Widget _buildDayLabel(String day) {
    return Container(
      width: 39,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF05DF72), Color(0xFF00C850)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), // Fixed deprecated withOpacity
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          day,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // Card bữa ăn
  Widget _buildMealCard(String? mealName) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        border: Border.all(
          color: const Color(0xFFD0D5DB),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: mealName != null
          ? _buildMealContent(mealName)
          : _buildAddMealContent(),
    );
  }

  // Nội dung khi có món ăn
  Widget _buildMealContent(String mealName) {
    return Stack(
      children: [
        Center(
          child: Text(
            mealName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF697282),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 8,
          child: GestureDetector(
            onTap: () {
              // Xóa món ăn
            },
            child: const Text(
              'X',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF354152),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Nội dung thêm món ăn
  Widget _buildAddMealContent() {
    return Builder(
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showRecipesModal(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add meal',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF697282),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipesModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.8), // Fixed deprecated withOpacity
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: const Recipes(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }
}

class Recipes extends StatelessWidget {
  const Recipes({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 705,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header với nút đóng
          _buildHeader(context),
          
          // Danh sách công thức
          Expanded(
            child: _buildRecipeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Công thức nấu ăn',
            style: TextStyle(
              color: Color(0xFF101727),
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 67,
              height: 47,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Text(
                  'X',
                  style: TextStyle(
                    color: Color(0xFF354152),
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildRecipeCard(),
          const SizedBox(height: 16),
          _buildRecipeCard(),
          const SizedBox(height: 16),
          _buildRecipeCard(),
          const SizedBox(height: 16),
          _buildRecipeCard(),
        ],
      ),
    );
  }

  Widget _buildRecipeCard() {
    return Container(
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 2,
          color: const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // Hình ảnh món ăn
            Container(
              width: 83,
              height: 79,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/img_healthy_buddha_bowl.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Thông tin món ăn
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cá hồi nướng với rau',
                    style: TextStyle(
                      color: Color(0xFF101727),
                      fontSize: 15.40,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  // Tag loại món
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'American',
                      style: TextStyle(
                        color: Color(0xFF354152),
                        fontSize: 11.40,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Thời gian nấu
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECD4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/icon_time_cook.png',
                          width: 12,
                          height: 12,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '25 phút',
                          style: TextStyle(
                            color: Color(0xFFC93400),
                            fontSize: 10.90,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
