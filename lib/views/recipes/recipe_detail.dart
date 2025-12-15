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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDescribe(),
                  const SizedBox(height: 24),
                  // Các phần khác như nguyên liệu, hướng dẫn, v.v.
                  _buildTimeInfoRow(),
                ],
              ),
            ),
          ]
        ),
      ),
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
        const SizedBox(width: 10),
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
          border: Border.all(color: const Color(0xFFB8F7CF)),        ),
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

  

}