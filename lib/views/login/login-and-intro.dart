import 'package:flutter/material.dart';
import 'package:kitchen_assistant/services/login_service.dart';
import 'dart:math';
class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  // 1. Tạo controller để điều khiển PageView
  final PageController _pageController = PageController();
  final TextEditingController _joinCodeController = TextEditingController();
  final TextEditingController _familyNameController = TextEditingController();
  bool _isLoading = false;

  // Khởi tạo Service
  final LoginService _loginService = LoginService();
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

  
  // --- LOGIC 1: THAM GIA (Sử dụng LoginService) ---
  Future<void> _handleJoinFamily() async {
    final code = _joinCodeController.text.trim(); // Giữ nguyên case theo DB của bạn
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // 1. Gọi Service tìm nhà
      final household = await _loginService.getHouseholdByCode(code);

      if (household == null) {
        throw 'Mã mời không tồn tại!';
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC 2: TẠO MỚI (Sử dụng LoginService) ---
  Future<void> _handleCreateFamily() async {
    final String name = _familyNameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // 1. Tạo mã random
      String inviteCode = _generateRandomCode(5);

      // 2. Gọi Service tạo nhà mới
      await _loginService.createHousehold(
        name, 
        inviteCode
      );

      if (name.length < 10){
        throw 'Tên hộ gia đình phải có ít nhất 10 ký tự!';
      }
      if (name.contains(RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]'))){
        throw 'Tên hộ gia đình không được chứa ký tự đặc biệt hoặc số!';
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // (Tùy chọn) physics: NeverScrollableScrollPhysics(), // Nếu muốn CHẶN người dùng tự vuốt
        children:[
          IntroApp(),
          Login(joinCodeController: _joinCodeController, familyNameController: _familyNameController, isLoading: _isLoading, handleJoinFamily: _handleJoinFamily, handleCreateFamily: _handleCreateFamily),
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
                _AppIcon(icon: Icons.kitchen_sharp),
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
  final IconData icon;
  const _AppIcon({super.key, required this.icon});

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
      child: Icon(icon, color: Colors.white, size: 32),
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
  final TextEditingController joinCodeController;
  final TextEditingController familyNameController;
  final bool isLoading;
  final Future<void> Function() handleJoinFamily;
  final Future<void> Function() handleCreateFamily;
  const Login({super.key, required this.joinCodeController, required this.familyNameController, required this.isLoading, required this.handleJoinFamily, required this.handleCreateFamily});

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
                  const _AppIcon(icon: Icons.house_sharp), // Tái sử dụng Icon cho gọn
                  const SizedBox(height: 16),
                  const _Title(text: "Tham gia Hộ Gia Đình"),
                  const SizedBox(height: 8),
                  const _Subtitle(text: "Tham gia hộ gia đình hiện có hoặc tạo rmới để bắt đầu"),
                  const SizedBox(height: 32),
                  _buildJoinFamily(joinCodeController),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildCreateFamily(familyNameController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== Widgets Login logic =====

  Widget _buildJoinFamily(TextEditingController joinCodeController) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nhập mã mời', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF354152))),
        const SizedBox(height: 8),
        TextField(
          controller: joinCodeController,
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
            onPressed: isLoading ? null : handleJoinFamily,
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

  Widget _buildCreateFamily(TextEditingController familyNameController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tên hộ gia đình', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF354152))),
        const SizedBox(height: 8),
        TextField(
          controller: familyNameController,
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
            onPressed: isLoading ? null : handleCreateFamily,
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