import 'package:flutter/material.dart';
import 'package:kitchen_assistant/models/Recipe.dart'; // Import Model
import 'package:kitchen_assistant/models/RecipeMatch.dart'; // Import RecipeMatch
import 'package:kitchen_assistant/services/ai_recipe_service.dart'; // Import Service
import 'package:kitchen_assistant/services/virtualPantry/ingredient_service.dart'; // Import IngredientService
import 'recipe-card.dart'; // Widget Card cũ của bạn

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<Recipes> {
  // --- 1. KHAI BÁO BIẾN DỮ LIỆU ---
  final SmartRecipeProvider _provider = SmartRecipeProvider();
  final IngredientService _ingredientService = IngredientService();
  List<RecipeMatch> _recipeMatches = [];
  bool _isLoading = true;

  // Giữ nguyên biến filter của bạn
  Map<String, List<String>> selectedFilters = {
    'Thời gian nấu ăn': [],
    'Loại ẩm thực': [],
    'Thời điểm': [],
    'Khẩu phần ăn': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchRecipes(); // Gọi dữ liệu ngay khi vào màn hình
  }

  // --- 2. LOGIC LẤY DỮ LIỆU DỰA TRÊN KHO ---
  Future<void> _fetchRecipes() async {
    setState(() => _isLoading = true);

    try {
      // 1. Lấy nguyên liệu từ kho
      final pantryIngredients = await _ingredientService.getIngredients();

      // 2. Map từ UI Filter sang Database Query Param
      Map<String, dynamic> queryParams = {};

      // Logic: Lấy phần tử đầu tiên trong list filter làm điều kiện lọc
      // Bỏ qua nếu là "Tất cả" hoặc rỗng
      if (selectedFilters['Loại ẩm thực']!.isNotEmpty && 
          selectedFilters['Loại ẩm thực']![0] != '') {
        queryParams['cuisine'] = _mapUiToDb(selectedFilters['Loại ẩm thực']![0]);
      }
      if (selectedFilters['Thời điểm']!.isNotEmpty && 
          selectedFilters['Thời điểm']![0] != '') {
        queryParams['meal_time'] = _mapUiToDb(selectedFilters['Thời điểm']![0]);
      }
      if (selectedFilters['Thời gian nấu ăn']!.isNotEmpty && 
          selectedFilters['Thời gian nấu ăn']![0] != '') {
        queryParams['cook_time'] = _mapUiToDb(selectedFilters['Thời gian nấu ăn']![0]);
      }
      if (selectedFilters['Khẩu phần ăn']!.isNotEmpty && 
          selectedFilters['Khẩu phần ăn']![0] != '') {
        queryParams['servings'] = _mapUiToDb(selectedFilters['Khẩu phần ăn']![0]);
      }

      // 3. Gọi Service để so sánh với kho (minMatchPercentage = 50%)
      final results = await _provider.getRecipesByPantry(
        pantryIngredients,
        filters: queryParams.isNotEmpty ? queryParams : null,
        minMatchPercentage: 80.0,
      );

      if (mounted) {
        setState(() {
          _recipeMatches = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi khi lấy công thức: $e");
      if (mounted) {
        setState(() {
          _recipeMatches = [];
          _isLoading = false;
        });
      }
    }
  }

  // Hàm phụ trợ: Chuyển tiếng Việt/Anh sang ID database
  String _mapUiToDb(String uiText) {
    if (uiText.contains('Nhanh (< 20p)')) return 'nhohon_20';
    if (uiText.contains('Trung bình')) return '20den35';
    if (uiText.contains('Dài (> 35p)')) return 'lonhon_35';
    
    if (uiText == 'Sáng') return 'sáng';
    if (uiText == 'Trưa') return 'trưa';
    if (uiText == 'Tối') return 'tối';

    if (uiText == '1 người') return '1 người';
    if (uiText == '2-4 người') return '2-4 người';
    if (uiText == '> 5 người') return '> 5 người';

    // Tên nước về lowercase (Vietnamese -> vietnamese, Vietnamese -> vietnam)
    return uiText; 
  }

  // --- 3. UI GIỮ NGUYÊN LAYOUT CŨ ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView( // Giữ nguyên scroll view bao trùm
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    
                    // --- PHẦN BỘ LỌC ---
                    const SizedBox(
                      height: 5,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 240, 253, 244),
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterSection('Thời gian nấu ăn', [ 'Nhanh (< 20p)', 'Trung bình', 'Dài (> 35p)']),
                          const SizedBox(height: 15),
                          _buildFilterSection('Loại ẩm thực', [ 'Italian', 'American', 'Asian', 'Mexican', 'Việt Nam']),
                          const SizedBox(height: 15),
                          _buildFilterSection('Thời điểm', [ 'Sáng', 'Trưa', 'Tối']),
                          const SizedBox(height: 15),
                          _buildFilterSection('Khẩu phần ăn', ['1 người', '2-4 người', '> 5 người'])
                        ],
                      ),
                    ),

                    const SizedBox(height: 1, child: Divider(color: Color(0xFFF2F4F6), thickness: 1)),
                    
                    // --- HIỂN THỊ SỐ LƯỢNG KẾT QUẢ ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Center(
                        child: Text(
                          _isLoading 
                              ? 'Đang tìm kiếm...' 
                              : 'Đã tìm thấy ${_recipeMatches.length} công thức phù hợp với kho của bạn',
                          style: const TextStyle(
                            color: Color(0xFF495565),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // --- DANH SÁCH MÓN ĂN (DYNAMIC) ---
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_recipeMatches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(child: Text("Không tìm thấy món nào phù hợp với kho của bạn!")),
                      )
                    else
                      ListView.separated(
                        // QUAN TRỌNG: 2 dòng này giúp List nằm gọn trong SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _recipeMatches.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final match = _recipeMatches[index];
                          final recipe = match.recipe;
                          return RecipeCard(
                            title: recipe.recipeName,
                            // Xử lý ảnh (nếu null thì dùng ảnh mặc định)
                            image: (recipe.recipeImage == null || recipe.recipeImage!.isEmpty)
                                ? "assets/images/recipes/default.png" 
                                : recipe.recipeImage!,
                            time: '${recipe.prepTime} phút',
                            steps: '${recipe.steps.length} bước', // Đếm số bước
                            // Hiển thị Tags lấy từ DB
                            tags: [
                              recipe.categories.cuisine,
                              recipe.difficulty == Difficulty.easy ? "Dễ" : "Khó"
                            ],
                            matchPercent: match.matchPercentage.round(), // Hiển thị phần trăm match thực tế
                            sumIngredient: recipe.ingredientsRequirements.length,
                            fillIngredient: match.sufficientIngredients.length,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. LOGIC XỬ LÝ FILTER ---
  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF495565), fontSize: 13)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((e) {
              // 1. Lấy danh sách đang chọn của mục hiện tại (dựa vào title)
              // Nếu chưa có thì mặc định là rỗng
              List<String> currentSelections = selectedFilters[title] ?? [];

              // 2. Kiểm tra
              bool isSelected = currentSelections.contains(e);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Logic xử lý "Tất cả"
                     if(isSelected){
                      selectedFilters.remove(e);
                      selectedFilters[title] = [''];
                    }else{
                      selectedFilters[title] = [e];
                    }
                  });
                  // QUAN TRỌNG: Gọi lại dữ liệu ngay sau khi chọn
                  _fetchRecipes();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF05DF72) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    isSelected ? '$e x' : e, // Chỉ hiện 'x' nếu không phải là nút 'Tất cả'
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
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
        spacing: 10,
        children: [
          Row(
            spacing: 40,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7BF1A8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.restaurant_menu, size: 24, color: Colors.white),
                      ),
                      const Text(
                        'Gợi ý món ăn',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                      ),
                    ],
                  )
                ],
              ),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ 
              const SizedBox(height: 10),
              const Text(
                'Gợi ý cá nhân hóa dựa trên tủ đựng thức ăn của bạn',
                style: TextStyle(color: Color(0xFF495565), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}