import 'package:flutter/material.dart';
// import 'package:kitchen_assistant/views/recipes/suggested_recipes.dart';
import '../widgets/bottom_nav.dart';
import '../notification/notification.dart';
import '../shoppingList/shopping_list.dart';
import '../mealPlanner/meal_planner.dart';
import '../virtualPantry/pantry_screen.dart';
import '../login/login-and-intro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../viewmodels/virtualPantry/pantry_viewmodel.dart';
import '../../services/ai_recipe_service.dart';
import '../../models/RecipeMatch.dart';
import 'package:provider/provider.dart';
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}
  
class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children:  [
          _HomePage(),        // Trang chủ
          PantryPage(),      // Kho
          ShoppingPage(),    // Mua sắm
          PlanPage(),        // Kế hoạch
          NotificationPage() // Thông báo
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  @override
  void initState() {
    super.initState();
    // Load ingredients khi mở home page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PantryViewModel>(context, listen: false);
      viewModel.loadIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao của phần tai thỏ (top padding)
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0FDF4), Colors.white], // Màu nền đồng nhất
        ),
      ),
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 16),
          children: const [
            _Header(),
            SizedBox(height: 16),
            _IngredientStatus(),
            SizedBox(height: 24),
            _SuggestSection(),
          ],
        ),
      )
    );
  }
}

class _Header extends StatefulWidget {
  const _Header();

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  String householdName = 'Bếp Nhà Trang';
  String householdCode = '';

  @override
  void initState() {
    super.initState();
    _loadHouseholdInfo();
  }

  Future<void> _loadHouseholdInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      householdName = prefs.getString('household_name') ?? 'Bếp Nhà Trang';
      householdCode = prefs.getString('household_code') ?? '';
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const FirstScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/img_cook.png',
            width: 65,
            height: 65,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào gia đình $householdName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF075B33),
                  ),
                ),
                const SizedBox(height: 4),
                if (householdCode.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: householdCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép mã!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Mã: $householdCode',
                          style: const TextStyle(
                            color: Color(0xFF6A7282),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _logout,
            child: const Column(
              children: [
                Icon(Icons.logout, size: 20, color: Color(0xFF075B33)),
                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Color(0xFF075B33),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _IngredientStatus extends StatelessWidget {
  const _IngredientStatus();

  @override
  Widget build(BuildContext context) {
    // 1. Lấy dữ liệu từ ViewModel để đếm số lượng thực tế
    final viewModel = context.watch<PantryViewModel>();
    
    final freshCount = viewModel.ingredients.where((i) => viewModel.getStatus(i) == 'Tươi').length;
    final expiringCount = viewModel.ingredients.where((i) => viewModel.getStatus(i) == 'Sắp hết hạn').length;
    final expiredCount = viewModel.ingredients.where((i) => viewModel.getStatus(i) == 'Hết hạn').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tình trạng nguyên liệu',
          style: TextStyle(fontSize: 14, color: Color(0xFF697282)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Card Tươi
            _StatusCard(
              count: freshCount.toString(),
              label: 'Tươi',
              bgColor: Colors.white,
              textColor: const Color(0xFF00A63D),
            ),
            const SizedBox(width: 12),
            // Card Sắp hết hạn
            _StatusCard(
              count: expiringCount.toString(),
              label: 'Sắp hết hạn',
              bgColor: const Color(0xFFFDFBE8),
              textColor: const Color(0xFFD08700),
            ),
            const SizedBox(width: 12),
            // Card Hết hạn
            _StatusCard(
              count: expiredCount.toString(),
              label: 'Hết hạn',
              bgColor: const Color(0xFFFEF2F2),
              textColor: const Color(0xFFE7000A),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String count;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _StatusCard({
    required this.count,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(count, style: TextStyle(fontSize: 24, color: textColor)),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF495565)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestSection extends StatefulWidget {
  const _SuggestSection();

  @override
  State<_SuggestSection> createState() => _SuggestSectionState();
}

class _SuggestSectionState extends State<_SuggestSection> {
  final SmartRecipeProvider _recipeService = SmartRecipeProvider();
  List<RecipeMatch> _suggestedRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestedRecipes();
  }

  Future<void> _loadSuggestedRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy ingredients từ ViewModel
      final viewModel = Provider.of<PantryViewModel>(context, listen: false);
      
      // Load ingredients nếu chưa có
      if (viewModel.ingredients.isEmpty) {
        await viewModel.loadIngredients();
      }

      // Lấy món ăn gợi ý từ AI service
      final recipes = await _recipeService.getRecipesByPantry(
        viewModel.ingredients,
        minMatchPercentage: 7.0, // Hiển thị món có ít nhất 7% phù hợp
      );

      setState(() {
        _suggestedRecipes = recipes.take(3).toList(); // Chỉ lấy 3 món đầu
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Lỗi load suggested recipes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SuggestHeader(),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_suggestedRecipes.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF2F4F6)),
            ),
            child: const Column(
              children: [
                Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Chưa có món ăn gợi ý',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF697282),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hãy thêm nguyên liệu vào kho để nhận gợi ý',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF697282),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._suggestedRecipes.map((recipeMatch) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecipeCard(
                  recipeMatch: recipeMatch,
                ),
              )),
      ],
    );
  }
}

class _SuggestHeader extends StatelessWidget {
  const _SuggestHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bạn muốn nấu gì hôm nay?',
          style: TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
          ),
        ),
        
        TextButton(
          onPressed: (){
            Navigator.pushNamed(context, '/home/recipes');
          },
          child: Text(
            'Các gợi ý khác',
            style: TextStyle(
              color: Color(0xFF00C850),
              fontWeight: FontWeight.w700,
            ), 
          ),
        )
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final RecipeMatch recipeMatch;

  const _RecipeCard({
    required this.recipeMatch,
  });

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes phút';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours giờ';
      }
      return '$hours giờ $mins phút';
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = recipeMatch.recipe;
    final matchPercent = recipeMatch.matchPercentage.round();
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/home/recipes/recipe-detail',
          arguments: recipe.recipeId,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF2F4F6)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: recipe.recipeImage != null && recipe.recipeImage!.isNotEmpty
                  ? Image.network(
                      recipe.recipeImage!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 96,
                          height: 96,
                          color: const Color(0xFFF2F4F6),
                          child: const Icon(Icons.restaurant_menu, size: 32, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      width: 96,
                      height: 96,
                      color: const Color(0xFFF2F4F6),
                      child: const Icon(Icons.restaurant_menu, size: 32, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: const Color(0xFF697282),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(recipe.prepTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF697282),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: matchPercent >= 70
                              ? const Color(0xFF00C850).withOpacity(0.1)
                              : const Color(0xFFD08700).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${matchPercent}% phù hợp',
                          style: TextStyle(
                            fontSize: 10,
                            color: matchPercent >= 70
                                ? const Color(0xFF00C850)
                                : const Color(0xFFD08700),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
