import 'package:flutter/material.dart';
import 'package:kitchen_assistant/models/meal_plan_model.dart';
import 'package:kitchen_assistant/models/Recipe.dart';
import 'package:kitchen_assistant/services/meal_plan_service.dart';
import 'package:kitchen_assistant/services/ai_recipe_service.dart';
import 'package:kitchen_assistant/viewmodels/meal_planner_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late MealPlannerViewModel _viewModel;
  late DateTime _currentWeekStart;
  String? _householdId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _viewModel = MealPlannerViewModel(MealPlanService(), SmartRecipeProvider());
    _currentWeekStart = _getWeekStart(DateTime.now());
    _loadHouseholdId();
  }

  // Lấy householdId từ SharedPreferences
  Future<void> _loadHouseholdId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final householdCode = prefs.getString('household_code');
      
      if (householdCode != null) {
        // Tìm household document theo code
        final snapshot = await FirebaseFirestore.instance
            .collection('households')
            .where('household_code', isEqualTo: householdCode)
            .limit(1)
            .get();
        
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _householdId = snapshot.docs.first.id;
            _isLoading = false;
          });
        } else {
          _showSnackBar('Không tìm thấy hộ gia đình!', Colors.red);
          setState(() => _isLoading = false);
        }
      } else {
        _showSnackBar('Chưa đăng nhập hộ gia đình!', Colors.orange);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Lỗi load householdId: $e');
      _showSnackBar('Lỗi tải thông tin hộ gia đình!', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  DateTime _getWeekStart(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  Future<void> _addMealToFirestore({
    required DateTime date,
    required String mealTime,
    required String recipeId,
    required String recipeName,
    required List<MealPlan> existingMealPlans,
  }) async {
    if (_householdId == null) {
      _showSnackBar('Chưa có thông tin hộ gia đình!', Colors.red);
      return;
    }

    final existingInFirestore = existingMealPlans.any(
      (meal) =>
          meal.date.year == date.year &&
          meal.date.month == date.month &&
          meal.date.day == date.day &&
          meal.mealTime == mealTime &&
          meal.recipeId == recipeId,
    );

    if (existingInFirestore) {
      _showSnackBar('Món "$recipeName" đã có trong bữa này!', Colors.orange);
      return;
    }

    try {
      await _viewModel.onDropRecipeToCalendar(
        date: date,
        mealTime: mealTime,
        recipeId: recipeId,
        householdId: _householdId!,
      );
      _showSnackBar('Đã thêm "$recipeName" thành công!', const Color(0xFF7BF1A8));
    } catch (e) {
      _showSnackBar('Có lỗi khi lưu món ăn!', Colors.red);
    }
  }

  Future<void> _deleteMealFromFirestore(String mealPlanId) async {
    try {
      await _viewModel.deleteMealPlan(mealPlanId);
      _showSnackBar('Đã xóa món ăn!', Colors.grey);
    } catch (e) {
      _showSnackBar('Có lỗi khi xóa món ăn!', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_householdId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Chưa có thông tin hộ gia đình',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            StreamBuilder<List<MealPlan>>(
              stream: _viewModel.getWeeklyPlans(_householdId!, _currentWeekStart),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Lỗi: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                return _buildWeeklyPlan(snapshot.data ?? []);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<List<MealPlan>>(
        stream: _viewModel.getWeeklyPlans(_householdId!, _currentWeekStart),
        builder: (context, snapshot) {
          return FloatingActionButton(
            onPressed: () => _showDishSelectionForm(
              context,
              existingMealPlans: snapshot.data ?? [],
            ),
            backgroundColor: const Color(0xFF7BF1A8),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          );
        },
      ),
    );
  }

  void _showDishSelectionForm(
    BuildContext context, {
    DateTime? targetDate,
    String? targetMealTime,
    required List<MealPlan> existingMealPlans,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DishSelectionForm(
            scrollController: scrollController,
            onDishSelected: (recipeId, recipeName) {
              Navigator.pop(bottomSheetContext);
              if (targetDate != null && targetMealTime != null) {
                _addMealToFirestore(
                  date: targetDate,
                  mealTime: targetMealTime,
                  recipeId: recipeId,
                  recipeName: recipeName,
                  existingMealPlans: existingMealPlans,
                );
              }
            },
            onDragStarted: () => Navigator.pop(bottomSheetContext),
            viewModel: _viewModel,
            householdId: _householdId!,
            existingMealPlans: existingMealPlans,
            targetDate: targetDate,
            targetMealTime: targetMealTime,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 16),
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
                  color: const Color(0xFF7BF1A8),
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
          StreamBuilder<List<MealPlan>>(
            stream: _viewModel.getWeeklyPlans(_householdId!, _currentWeekStart),
            builder: (context, snapshot) {
              final mealPlans = snapshot.data ?? [];
              final uniqueMeals = <String>{};
              for (final meal in mealPlans) {
                final key = '${meal.date.year}-${meal.date.month}-${meal.date.day}-${meal.mealTime}';
                uniqueMeals.add(key);
              }
              final mealCount = uniqueMeals.length;
              return Text(
                '$mealCount/21 bữa ăn đã lên kế hoạch cho tuần này',
                style: const TextStyle(fontSize: 14, color: Color(0xFF495565)),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _previousWeek,
                icon: const Icon(Icons.arrow_back_ios),
              ),
              Image.asset(
                'assets/images/icon_mealPlane.png',
                width: 20,
                height: 20,
                color: const Color(0xFF7BF1A8),
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 8),
              Text(
                '${_currentWeekStart.day} Thg ${_currentWeekStart.month} – ${weekEnd.day} Thg ${weekEnd.month}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: _nextWeek,
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlan(List<MealPlan> mealPlans) {
    const weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];

    return Column(
      children: List.generate(7, (index) {
        final date = _currentWeekStart.add(Duration(days: index));
        return _buildDayCard(weekdays[index], date, mealPlans);
      }),
    );
  }

  Widget _buildDayCard(String dayName, DateTime date, List<MealPlan> mealPlans) {
    final dayMeals = mealPlans
        .where((meal) =>
            meal.date.year == date.year &&
            meal.date.month == date.month &&
            meal.date.day == date.day)
        .toList();

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
                      '${date.day}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dayName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          _buildMealSection('☀️', 'Sáng', date, dayMeals, 'breakfast', mealPlans),
          _buildMealSection('🌤', 'Trưa', date, dayMeals, 'lunch', mealPlans),
          _buildMealSection('🌙', 'Tối', date, dayMeals, 'dinner', mealPlans),
        ],
      ),
    );
  }

  Widget _buildMealSection(
    String emoji,
    String mealTime,
    DateTime date,
    List<MealPlan> dayMeals,
    String mealTimeKey,
    List<MealPlan> allMealPlans,
  ) {
    final mealPlansForTime = dayMeals
        .where((meal) => meal.mealTime == mealTimeKey)
        .toList();

    return DragTarget<Map<String, String>>(
      onWillAcceptWithDetails: (details) {
        return !mealPlansForTime.any(
          (meal) => meal.recipeId == details.data['recipeId'],
        );
      },
      onAcceptWithDetails: (details) {
        _addMealToFirestore(
          date: date,
          mealTime: mealTimeKey,
          recipeId: details.data['recipeId']!,
          recipeName: details.data['recipeName']!,
          existingMealPlans: allMealPlans,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: candidateData.isNotEmpty
              ? BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  border: Border.all(color: const Color(0xFF7BF1A8), width: 2),
                )
              : rejectedData.isNotEmpty
                  ? BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red, width: 2),
                    )
                  : null,
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
              if (mealPlansForTime.isNotEmpty) ...[
                ...mealPlansForTime.map((meal) => _buildMealItem(meal.recipeId, meal.id)),
                _buildMealButton(date, mealTimeKey, allMealPlans, 'Thêm món'),
              ] else
                _buildMealButton(date, mealTimeKey, allMealPlans, 'Chưa có món'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealItem(String recipeId, String mealPlanId) {
    return FutureBuilder<Recipe?>(
      future: _viewModel.getRecipeById(recipeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingMealItem();
        }

        final recipe = snapshot.data;
        if (recipe == null) {
          return _buildErrorMealItem(mealPlanId);
        }

        return FutureBuilder<int>(
          future: _viewModel.getMissingIngredientsCount(recipeId, _householdId!),
          builder: (context, missingSnapshot) {
            final missingCount = missingSnapshot.data ?? 0;
            final hasWarning = missingCount > 0;

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
                      Expanded(
                        child: Text(
                          recipe.recipeName,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF1D2838)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _deleteMealFromFirestore(mealPlanId),
                        child: const Icon(Icons.close, size: 18, color: Color(0xFF1D2838)),
                      ),
                    ],
                  ),
                  if (hasWarning) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFFFB84D)),
                        const SizedBox(width: 4),
                        Text(
                          'Thiếu $missingCount nguyên liệu',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFFFB84D)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingMealItem() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x4CA7D4B9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8),
          Text('Đang tải...'),
        ],
      ),
    );
  }

  Widget _buildErrorMealItem(String mealPlanId) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Không tìm thấy món ăn'),
          GestureDetector(
            onTap: () => _deleteMealFromFirestore(mealPlanId),
            child: const Icon(Icons.close, size: 18, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildMealButton(DateTime date, String mealTimeKey, List<MealPlan> allMealPlans, String text) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D5DB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () => _showDishSelectionForm(
          context,
          targetDate: date,
          targetMealTime: mealTimeKey,
          existingMealPlans: allMealPlans,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (text == 'Thêm món') ...[
              const Icon(Icons.add, size: 16, color: Color(0xFF99A1AE)),
              const SizedBox(width: 8),
            ],
            Text(text, style: const TextStyle(color: Color(0xFF99A1AE), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ============ DISH SELECTION FORM ============

class DishSelectionForm extends StatefulWidget {
  final ScrollController scrollController;
  final Function(String recipeId, String recipeName) onDishSelected;
  final VoidCallback onDragStarted;
  final MealPlannerViewModel viewModel;
  final String householdId;
  final List<MealPlan> existingMealPlans;
  final DateTime? targetDate;
  final String? targetMealTime;

  const DishSelectionForm({
    super.key,
    required this.scrollController,
    required this.onDishSelected,
    required this.onDragStarted,
    required this.viewModel,
    required this.householdId,
    required this.existingMealPlans,
    this.targetDate,
    this.targetMealTime,
  });

  @override
  State<DishSelectionForm> createState() => _DishSelectionFormState();
}

class _DishSelectionFormState extends State<DishSelectionForm> {
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isRecipeAlreadyAdded(String recipeId) {
    if (widget.targetDate == null || widget.targetMealTime == null) return false;

    return widget.existingMealPlans.any(
      (meal) =>
          meal.date.year == widget.targetDate!.year &&
          meal.date.month == widget.targetDate!.month &&
          meal.date.day == widget.targetDate!.day &&
          meal.mealTime == widget.targetMealTime &&
          meal.recipeId == recipeId,
    );
  }

  String _getMealTimeText(String? mealTime) {
    switch (mealTime) {
      case 'breakfast':
        return 'Sáng';
      case 'lunch':
        return 'Trưa';
      case 'dinner':
        return 'Tối';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader(),
                const SizedBox(height: 16),
                _buildSearchField(),
                const SizedBox(height: 8),
                Text(
                  widget.targetDate != null
                      ? 'Nhấn vào món ăn để thêm ngay'
                      : 'Kéo thả món ăn vào lịch',
                  style: const TextStyle(color: Color(0xFF697282), fontSize: 15),
                ),
                const SizedBox(height: 16),
                _buildRecipeList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn món ăn',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101727),
              ),
            ),
            if (widget.targetDate != null && widget.targetMealTime != null)
              Text(
                '${_getMealTimeText(widget.targetMealTime)} - ${widget.targetDate!.day}/${widget.targetDate!.month}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF697282)),
              ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 24),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF697282), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Tìm món ăn...',
                hintStyle: TextStyle(color: Color(0xFF697282), fontSize: 15),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    return StreamBuilder<List<Recipe>>(
      stream: widget.viewModel.getAllRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              ],
            ),
          );
        }

        final recipes = snapshot.data ?? [];
        if (recipes.isEmpty) {
          return const Center(
            child: Column(
              children: [
                Icon(Icons.restaurant, color: Colors.grey, size: 64),
                SizedBox(height: 16),
                Text(
                  'Chưa có công thức nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF697282),
                  ),
                ),
              ],
            ),
          );
        }

        final filteredRecipes = recipes
            .where((recipe) =>
                _searchText.isEmpty ||
                recipe.recipeName.toLowerCase().contains(_searchText))
            .toList();

        // if (filteredRecipes.isEmpty) {
        //   return const Center(
        //     child: Padding(
        //       padding: EdgeInsets.all(32.0),
        //       child: Column(
        //         children: [
        //           Icon(Icons.search_off, color: Colors.grey, size: 48),
        //           SizedBox(height: 16),
        //           Text(
        //             'Không tìm thấy món ăn',
        //             style: TextStyle(color: Color(0xFF697282), fontSize: 16),
        //           ),
        //         ],
        //       ),
        //     ),
        //   );
        // }

        return Column(
          children: filteredRecipes.map((recipe) => _buildDishItem(recipe)).toList(),
        );
      },
    );
  }

  Widget _buildDishItem(Recipe recipe) {
    final isAlreadyAdded = _isRecipeAlreadyAdded(recipe.recipeId);

    return FutureBuilder<int>(
      future: widget.viewModel.getMissingIngredientsCount(recipe.recipeId, widget.householdId),
      builder: (context, missingSnapshot) {
        final missingCount = missingSnapshot.data ?? 0;
        final hasEnoughIngredients = missingCount == 0;

        if (isAlreadyAdded) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: Opacity(
              opacity: 0.6,
              child: Stack(
                children: [
                  _buildDishContainer(recipe, hasEnoughIngredients, missingCount),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 22),
                            SizedBox(width: 6),
                            Text(
                              'Đã thêm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Draggable<Map<String, String>>(
          data: {'recipeId': recipe.recipeId, 'recipeName': recipe.recipeName},
          onDragStarted: widget.onDragStarted,
          feedback: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(14),
            child: _buildDragFeedback(recipe, hasEnoughIngredients),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildDishContainer(recipe, hasEnoughIngredients, missingCount),
          ),
          child: GestureDetector(
            onTap: () => widget.onDishSelected(recipe.recipeId, recipe.recipeName),
            child: _buildDishContainer(recipe, hasEnoughIngredients, missingCount),
          ),
        );
      },
    );
  }

  Widget _buildDragFeedback(Recipe recipe, bool hasEnoughIngredients) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasEnoughIngredients ? const Color(0xFFF0FDF4) : const Color(0xFFFEF9C2),
        border: Border.all(
          color: hasEnoughIngredients ? const Color(0xFFB8F7CF) : const Color(0xFFFFDF20),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRecipeImage(recipe, 40),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              recipe.recipeName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF101727),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishContainer(Recipe recipe, bool hasEnoughIngredients, int missingCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasEnoughIngredients ? const Color(0xFFF0FDF4) : const Color(0xFFFEF9C2),
        border: Border.all(
          color: hasEnoughIngredients ? const Color(0xFFB8F7CF) : const Color(0xFFFFDF20),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildRecipeImage(recipe, 60),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.recipeName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF101727),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      hasEnoughIngredients ? Icons.check_circle : Icons.warning_amber_rounded,
                      size: 16,
                      color: hasEnoughIngredients ? const Color(0xFFA8D5BA) : const Color(0xFFA65F00),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasEnoughIngredients ? 'Đủ nguyên liệu' : 'Thiếu $missingCount nguyên liệu',
                      style: TextStyle(
                        fontSize: 14,
                        color: hasEnoughIngredients ? const Color(0xFFA8D5BA) : const Color(0xFFA65F00),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Text("⋮⋮⋮"),
        ],
      ),
    );
  }

  Widget _buildRecipeImage(Recipe recipe, double size) {
    return Container(
      width: size,
      height: size - 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size == 40 ? 8 : 16),
        color: Colors.grey[200],
      ),
      child: recipe.recipeImage != null && recipe.recipeImage!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(size == 40 ? 8 : 16),
              child: Image.network(
                recipe.recipeImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.restaurant, size: size == 40 ? 20 : 30),
              ),
            )
          : Icon(Icons.restaurant, size: size == 40 ? 20 : 30),
    );
  }
}