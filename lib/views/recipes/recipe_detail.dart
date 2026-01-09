import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Cần thêm package này vào pubspec.yaml
import 'package:kitchen_assistant/models/Recipe.dart';
// import 'package:kitchen_assistant/services/ai_recipe_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/virtualPantry/pantry_viewmodel.dart';

class RecipeDetail extends StatefulWidget {
  final String recipeId; // Nhận recipeId
  
  const RecipeDetail({super.key, required this.recipeId});

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  int _selectedTab = 0;
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _isCooking = false;
  Recipe? _recipe;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    try {
      final db = FirebaseFirestore.instance;
      // Tìm recipe theo recipe_id
      final snapshot = await db.collection('recipes')
          .where('recipe_id', isEqualTo: widget.recipeId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _recipe = Recipe.fromFirestore(snapshot.docs.first);
          _isLoading = false;
        });
        
        // Khởi tạo video nếu có
        if (_recipe?.videoUrl != null && _recipe!.videoUrl!.isNotEmpty) {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(_recipe!.videoUrl!))
            ..initialize().then((_) {
              if (mounted) {
                setState(() {
                  _isVideoInitialized = true;
                });
              }
            });
        } else {
          // Fallback về asset video nếu không có video URL
          _videoController = VideoPlayerController.asset('assets/videos/video1.mp4')
            ..initialize().then((_) {
              if (mounted) {
                setState(() {
                  _isVideoInitialized = true;
                });
              }
            });
        }
      } else {
        // Nếu không tìm thấy theo recipe_id, thử tìm theo document ID
        final doc = await db.collection('recipes').doc(widget.recipeId).get();
        if (doc.exists) {
          setState(() {
            _recipe = Recipe.fromFirestore(doc);
            _isLoading = false;
          });
          
          if (_recipe?.videoUrl != null && _recipe!.videoUrl!.isNotEmpty) {
            _videoController = VideoPlayerController.networkUrl(Uri.parse(_recipe!.videoUrl!))
              ..initialize().then((_) {
                if (mounted) {
                  setState(() {
                    _isVideoInitialized = true;
                  });
                }
              });
          } else {
            _videoController = VideoPlayerController.asset('assets/videos/video1.mp4')
              ..initialize().then((_) {
                if (mounted) {
                  setState(() {
                    _isVideoInitialized = true;
                  });
                }
              });
          }
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Lỗi khi load recipe: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleStartCooking() async {
    if (_recipe == null || _recipe!.ingredientsRequirements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Công thức không có nguyên liệu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final viewModel = Provider.of<PantryViewModel>(context, listen: false);
      
      // Đảm bảo ingredients đã được load
      if (viewModel.ingredients.isEmpty) {
        await viewModel.loadIngredients();
      }

      // Chuyển đổi ingredients requirements sang format cần thiết
      final recipeIngredients = _recipe!.ingredientsRequirements.map((ing) => {
        'id': ing.id,
        'name': ing.name,
        'amount': ing.amount,
        'unit': ing.unit,
      }).toList();

      // Trừ nguyên liệu
      final results = await viewModel.useIngredientsForRecipe(recipeIngredients);

      if (mounted) {
        Navigator.pop(context); // Đóng loading

        // Hiển thị kết quả
        final successCount = results['success']?.length ?? 0;
        final failedCount = results['failed']?.length ?? 0;
        final notFoundCount = results['notFound']?.length ?? 0;

        String message = '';
        Color backgroundColor = Colors.green;

        if (successCount > 0 && failedCount == 0 && notFoundCount == 0) {
          message = 'Đã trừ $successCount nguyên liệu. Bắt đầu nấu!';
          backgroundColor = Colors.green;
          setState(() {
            _isCooking = true;
          });
        } else if (successCount > 0) {
          message = 'Đã trừ $successCount nguyên liệu';
          if (failedCount > 0) message += '. $failedCount nguyên liệu không đủ';
          if (notFoundCount > 0) message += '. $notFoundCount nguyên liệu không tìm thấy';
          backgroundColor = Colors.orange;
          setState(() {
            _isCooking = true;
          });
        } else {
          message = 'Không thể trừ nguyên liệu. Vui lòng kiểm tra lại kho.';
          if (notFoundCount > 0) message += ' ($notFoundCount nguyên liệu không tìm thấy)';
          backgroundColor = Colors.red;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Đóng loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_recipe == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Không tìm thấy công thức')),
        body: const Center(child: Text('Công thức không tồn tại')),
      );
    }
    
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
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
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
                    child: Text(
                      _recipe?.categories.cuisine ?? 'N/A',
                      style: const TextStyle(color: Colors.white, fontSize: 12)
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      _recipe?.difficulty == Difficulty.easy ? 'Dễ' : 
                      _recipe?.difficulty == Difficulty.medium ? 'Trung bình' : 'Khó',
                      style: const TextStyle(color: Colors.white, fontSize: 12)
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              Text(
                _recipe?.recipeName ?? 'Chưa có tên',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(children: [
                    const Icon(Icons.schedule, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_recipe?.prepTime ?? 0} phút',
                      style: const TextStyle(color: Colors.white70, fontSize: 14)
                    ),
                  ],),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_recipe?.categories.servings ?? 0} người',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.fire_extinguisher, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_recipe?.calories ?? 0} calo',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)
                      ),
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
          padding: const EdgeInsets.all(25),
        ),
        Expanded(
          child: Text(
            _recipe?.description ?? 'Một món ăn ngon và bổ dưỡng.',
            style: const TextStyle(color: Color(0xFF354152)),
            // overflow: TextOverflow.ellipsis,
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
        Expanded(child: _buildInfoCard('Thời gian chuẩn bị', '${_recipe?.prepTime ?? 0} phút')),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoCard('Thời gian nấu', '${_recipe?.prepTime ?? 0} phút')),
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
    if (_recipe == null || _recipe!.ingredientsRequirements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Chưa có thông tin nguyên liệu'),
      );
    }
    
    return Column(
      spacing: 10,
      children: _recipe!.ingredientsRequirements.map((ingredient) {
        return _buildIngredientItem(
          ingredient.name,
          '${ingredient.amount} ${ingredient.unit}',
          true, // Có thể thêm logic kiểm tra trong kho sau
        );
      }).toList(),
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
    if (_recipe == null || _recipe!.steps.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Chưa có hướng dẫn nấu ăn'),
      );
    }
    
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _recipe!.steps.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final step = entry.value;
        return _buildStepItem(index, step);
      }).toList(),
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
              onTap: _isCooking ? () {
                // Nếu đang nấu, chỉ toggle state
                setState(() {
                  _isCooking = false;
                });
              } : _handleStartCooking,
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