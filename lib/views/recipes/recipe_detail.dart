import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Cần thêm package này vào pubspec.yaml

class RecipeDetail extends StatefulWidget {
  const RecipeDetail({super.key});

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  int _selectedTab = 0;
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = true;
  bool _isCooking = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo video (Thay URL bằng link video thực tế của bạn)
    _videoController = VideoPlayerController.asset('assets/videos/pasta.mp4',
    )..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildVideoHeader(),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  _buildDescribe(),
                  // Các phần khác như nguyên liệu, hướng dẫn, v.v.
                  _buildTimeInfoRow(),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen[50]
                    ),
                    
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTabButtons(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            spacing: 10,
                            children: [
                              _selectedTab == 0 
                                ? _buildIngredientsList() 
                                : _buildInstructionsList(),
                              if (_selectedTab == 0) _buildTipBox(), // Chỉ hiện Tip ở tab nguyên liệu
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),// Hiển thị nội dung dựa trên Tab đang chọn
                ],
              ),
            ),
          ]
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // --- 1. PHẦN VIDEO PLAYER ---
  Widget _buildVideoHeader() {
    
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 320,
          width: double.infinity,
          child: _isVideoInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : Container(
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator()),
                ),
        ),
        // Nút Play/Pause ở giữa
        if (_isVideoInitialized)
          IconButton(
            iconSize: 50,
            icon: Icon(
              _videoController.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.white.withOpacity(0.8),
            ),
            onPressed: () {
              setState(() {
                _videoController.value.isPlaying
                    ? _videoController.pause()
                    : _videoController.play();
              });
            },
          ),
        // Nút Back
        Positioned(
          left: 16, top: 40,
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        // Title đè lên video
        Positioned(
          left: 24, bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Italian', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Dễ', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              const Text('Mỳ Pasta sốt cà chua', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(children: [
                    const Icon(Icons.schedule, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    const Text('40 phút', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      const Text('2 phần', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: const [
                      Icon(Icons.fire_extinguisher, color: Colors.yellow, size: 16),
                      SizedBox(width: 4),
                      Text('4.8', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
  // --- CÁC WIDGET CŨ GIỮ NGUYÊN ---
  Widget _buildDescribe() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
        ),
        const Expanded(
          child: Text(
            'Một món mì ống béo ngậy và thơm ngon với cà chua tươi và '
             + 'các loại thảo mộc. Món ăn này rất dễ làm và chắc chắn sẽ làm hài lòng cả gia đình bạn.',
            style: TextStyle(color: Color(0xFF354152), height: 1.5),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfoRow() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: 
        BoxDecoration(
          color: Colors.lightGreen[50],
        ),
      child: Row(
        children: [
        Expanded(child: _buildInfoCard('Thời gian chuẩn bị', '15 phút')),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoCard('Thời gian nấu', '25 phút')),
      ],
      ),
      
    );
  }

  Widget _buildInfoCard(String title, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB8F7CF)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF495565), fontSize: 12)),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(color: Color(0xFF101727), fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- 2. PHẦN TAB BUTTONS (Đã hiệu chỉnh theo style BackgroundHorizontalborder) ---
Widget _buildTabButtons() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.only(top: 15), // Padding top theo mẫu
    decoration: const BoxDecoration(
      color: Colors.white, // Nền trắng
      border: Border(
        top: BorderSide(
          width: 1,
          color: Color(0xFFF2F4F6), // Viền xám nhạt phía trên
        ),
        bottom: BorderSide(
          width: 1,
          color: Color(0xFFF2F4F6), // Viền xám nhạt phía dưới
        ),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab 0: Nguyên liệu
        Expanded(
          child: _buildSingleTabBtn(
            text: "Nguyên liệu",
            index: 0,
            iconEmoji: null, // Tab này trong mẫu dùng Stack placeholder
          ),
        ),
        
        // Tab 1: Hướng dẫn
        Expanded(
          child: _buildSingleTabBtn(
            text: "Hướng dẫn",
            index: 1,
            iconEmoji: "📝", // Icon theo mẫu
          ),
        ),
      ],
    ),
  );
}

Widget _buildSingleTabBtn({
  required String text, 
  required int index, 
  String? iconEmoji
}) {
  bool isActive = _selectedTab == index;

  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedTab = index;
      });
    },
    // Sử dụng behavior này để bấm được vào cả vùng trống xung quanh text
    behavior: HitTestBehavior.opaque, 
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Phần nội dung (Icon + Text)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconEmoji != null) ...[
              Text(
                iconEmoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                // Logic màu sắc: Active -> Xanh lá đậm, Inactive -> Xám
                color: isActive 
                    ? const Color(0xFF00A63D) 
                    : const Color(0xFF6A7282),
                fontSize: 15, // Làm tròn từ 14.90/14.60
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12), // Khoảng cách giữa text và gạch chân (runSpacing)

        // Thanh gạch chân (Chỉ hiện khi Active)
        isActive
            ? Container(
                height: 2,
                width: double.infinity, // Full width của tab
                margin: const EdgeInsets.symmetric(horizontal: 10), // Thụt vào một chút cho đẹp (tuỳ chọn)
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, 0.50),
                    end: Alignment(1.00, 0.50),
                    colors: [
                      Color(0xFF05DF72), 
                      Color(0xFF00C850)
                    ],
                  ),
                ),
              )
            : const SizedBox(height: 2), // Giữ chiều cao để không bị giật layout
      ],
    ),
  );
}

  Widget _buildIngredientsList() {
    return Column(
      spacing: 10,
      children: [
        _buildIngredientItem('Mỳ Pasta', '500g', true),
        _buildIngredientItem('Cà chua', '1 quả', true),
        _buildIngredientItem('Tỏi', '1 củ', true),
      ],
    );
  }

  Widget _buildIngredientItem(String name, String amount, bool isChecked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
        border: Border.all(color: isChecked ? const Color(0xFFB8F7CF) : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(isChecked ? Icons.check_circle : Icons.cancel, color: isChecked ? const Color(0xFF00C850) : Colors.grey),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(amount, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTipBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EC),
        border: Border.all(color: const Color(0xFFFFD6A7)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Text('💡 ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text('Thiếu 1 nguyên liệu - Thêm vào giỏ hàng?', style: TextStyle(color: Color(0xFF9F2D00), fontSize: 13))),
        ],
      ),
    );
  }
  Widget _buildInstructionsList() {
    // Đây là nội dung giả lập cho trang "Hướng dẫn"
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepItem(1, "Luộc mỳ trong nước sôi khoảng 10 phút đến khi chín tới.", note: "Mẹo: Thêm một chút muối vào nước luộc để mỳ thêm đậm đà."),
        _buildStepItem(2, "Thái nhỏ cà chua và tỏi. Phi thơm tỏi với dầu ô liu."),
        _buildStepItem(3, "Cho cà chua vào xào chín mềm, nêm gia vị vừa ăn."),
        _buildStepItem(4, "Trộn mỳ với sốt, thêm húng quế và thưởng thức."),
      ],
    );
  }

  Widget _buildStepItem(int step, String content, {String? note}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    // Thêm margin bottom để các bước cách nhau ra (tuỳ chọn)
    margin: const EdgeInsets.only(bottom: 16), 
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 1,
          color: Color(0xFFE5E7EB), // color-grey-91
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      // Sử dụng spacing giống mẫu của bạn (Flutter version mới)
      spacing: 16, 
      children: [
        // --- 1. Phần số thứ tự (Hình tròn xám) ---
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: const Color(0xFFF2F4F6), // color-grey-96
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100), // Bo tròn hoàn toàn
            ),
          ),
          child: Text(
            '$step',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF495565), // color-azure-34
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ),

        // --- 2. Phần nội dung chính ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7.4, // Khoảng cách giữa tiêu đề và nội dung
            children: [
              // Label "Bước X"
              Text(
                'Bước $step',
                style: const TextStyle(
                  color: Color(0xFF697282), // color-azure-46
                  fontSize: 13.30,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              
              // Nội dung hướng dẫn
              Text(
                content,
                style: const TextStyle(
                  color: Color(0xFF101727), // color-azure-11
                  fontSize: 15.10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.72,
                ),
              ),

              // --- 3. Phần Note/Mẹo (Hộp màu vàng) ---
              // Chỉ hiển thị nếu có truyền vào biến 'note'
              if (note != null && note.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 10), // Cách phần text trên một chút
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFDFBE8), // color-grey-95 (Yellow tint)
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFFEEF85), // color-yellow-76
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    note,
                    style: const TextStyle(
                      color: Color(0xFF101727), // color-azure-11
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.54,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}


// ...

Widget _buildBottomBar() {
  // Sử dụng SafeArea để tránh bị tràn xuống thanh Home ảo của iPhone/Android
  return SafeArea(
    // top: false, // Không cần safe area ở trên
    child: Container(
      height: 70,
      // width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10), // Giảm padding bottom vì SafeArea đã lo rồi
      decoration: ShapeDecoration(
        color: Colors.white,
        // Chỉ giữ viền trên, bỏ các viền khác nếu không cần thiết
        shape: const Border(
          top: BorderSide(width: 1, color: Color(0xFFF2F4F6)),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0D000000), // Giảm opacity bóng đổ cho nhẹ nhàng hơn
            blurRadius: 10,
            offset: Offset(0, -5), // Bóng đổ hắt lên trên
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Quan trọng: Chỉ chiếm chiều cao vừa đủ
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- BUTTON 1: Bắt đầu nấu / Đang nấu ---
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isCooking = !_isCooking;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 20), // Hiệu ứng chuyển màu mượt mà
                padding: const EdgeInsets.symmetric(vertical: 12), // Giảm padding dọc một chút để đỡ bị cao quá
                decoration: ShapeDecoration(
                  color: _isCooking ? const Color(0xFFEF5350) : null,
                  gradient: _isCooking
                      ? null
                      : const LinearGradient(
                          begin: Alignment(0.00, 0.50),
                          end: Alignment(1.00, 0.50),
                          colors: [Color(0xFF05DF72), Color(0xFF00C850)],
                        ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: -4,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    _isCooking ? 'Đang nấu' : 'Bắt đầu nấu',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.20,
                      fontWeight: FontWeight.w600, // Tăng độ đậm một chút cho dễ đọc
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16), // Khoảng cách giữa 2 nút

          // --- BUTTON 2: Tạo kế hoạch ---
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Xử lý sự kiện
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFF05DF72)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: -4,
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Tạo kế hoạch',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF05DF72),
                      fontSize: 13.20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}