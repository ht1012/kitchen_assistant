import 'package:flutter/material.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  // 1. Tạo controller để điều khiển PageView
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // 2. Logic đếm ngược 5 giây ngay khi màn hình được tạo
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      // Kiểm tra xem màn hình còn tồn tại không trước khi chuyển trang (tránh lỗi)
      if (mounted) {
        _pageController.animateToPage(
          1, // Chuyển sang trang Login (index 1)
          duration: const Duration(milliseconds: 800), // Thời gian hiệu ứng trượt
          curve: Curves.linearToEaseOut, // Hiệu ứng mượt mà
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Giải phóng controller khi thoát màn hình
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // (Tùy chọn) physics: NeverScrollableScrollPhysics(), // Nếu muốn CHẶN người dùng tự vuốt
        children: const [
          IntroApp(),
          Login(),
        ],
      ),
    );
  }
}


class IntroApp extends StatelessWidget {
  const IntroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFF0FDF4),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _AppIcon(),
                SizedBox(height: 16),
                _Title(text: 'Bếp Trợ Lý'),
                SizedBox(height: 8),
                _Subtitle(text: 'Quản lý tủ lạnh – Gợi ý món ăn thông minh'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C850), Color(0xFF009865)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.flash_on, color: Colors.white, size: 32),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF008235),
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final String text;

  const _Subtitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF495565),
        fontSize: 15,
        height: 1.4,
      ),
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFFF0FDF4),
        child: Center(
          child: SingleChildScrollView( // Thêm ScrollView để tránh lỗi tràn màn hình khi phím ảo hiện lên
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 8,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _AppIcon(), // Tái sử dụng Icon cho gọn
                  const SizedBox(height: 16),
                  const _Title(text: "Tham gia Hộ Gia Đình"),
                  const SizedBox(height: 8),
                  const _Subtitle(text: "Tham gia hộ gia đình hiện có hoặc tạo rmới để bắt đầu"),
                  const SizedBox(height: 32),
                  _buildJoinFamily(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildCreateFamily(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== Widgets Login logic =====
  
  Widget _buildJoinFamily() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nhập mã mời', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF354152))),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            hintText: 'VD: BEP123',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C850),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {},
            child: const Text('Tham gia', style: TextStyle(fontSize: 24, fontFamily: "Inter",)),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color(0xFFD0D5DB))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Hoặc',
            style: TextStyle(color: Color(0xFF697282)),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFD0D5DB))),
      ],
    );
  }

  Widget _buildCreateFamily() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tên hộ gia đình', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF354152))),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            hintText: 'VD: Gia đình Nguyễn',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFF00C850), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {},
            child: const Text(
              'Tạo hộ gia đình',
              style: TextStyle(color: Color(0xFF00A63D), fontSize: 24),
            ),
          ),
        ),
      ],
    );
  }
}