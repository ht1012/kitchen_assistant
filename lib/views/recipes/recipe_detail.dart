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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildVideoHeader(),
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
}