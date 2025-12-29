import 'package:flutter/material.dart';
import 'package:kitchen_assistant/models/meal_plan_model.dart';
import 'package:kitchen_assistant/models/recipe_model.dart';
import 'package:kitchen_assistant/services/meal_plan_service.dart';
import 'package:kitchen_assistant/services/recipe_service.dart';
import 'package:kitchen_assistant/viewmodels/meal_planner_viewmodel.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late MealPlannerViewModel _viewModel;
  late DateTime _currentWeekStart;
  final String _householdId = "fcLWhhpMpZZVOMydR1mF"; // Replace with actual household ID

  @override
  void initState() {
    super.initState();
    _viewModel = MealPlannerViewModel(MealPlanService(), RecipeService());
    _currentWeekStart = _getWeekStart(DateTime.now());
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              StreamBuilder<List<MealPlan>>(
                stream: _viewModel.getWeeklyPlans(_householdId, _currentWeekStart),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final mealPlans = snapshot.data ?? [];
                  return _buildWeeklyPlan(mealPlans);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDishSelectionForm(context);
        },
        backgroundColor: const Color(0xFF7BF1A8),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showDishSelectionForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true, // Cho phép đóng bằng cách tap ra ngoài
      builder: (context) => DraggableScrollableSheet(
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
              Navigator.pop(context); // Đóng form ngay lập tức
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã chọn $recipeName. Kéo vào lịch để thêm.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onDishDropped: () {
              Navigator.pop(context); // Đóng form sau khi drop
            },
            viewModel: _viewModel,
            householdId: _householdId,
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7BF1A8), Color(0xFF7BF1A8)],
                  ),
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
          const Text(
            '0/21 bữa ăn đã lên kế hoạch cho tuần này',
            style: TextStyle(fontSize: 14, color: Color(0xFF495565)),
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
                fit: BoxFit.contain,
                color: const Color(0xFF7BF1A8),
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 8),
              Text(
                '${_currentWeekStart.day} Thg ${_currentWeekStart.month} – ${weekEnd.day} Thg ${weekEnd.month}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
    final List<Map<String, dynamic>> weekDays = List.generate(7, (index) {
      final date = _currentWeekStart.add(Duration(days: index));
      final weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
      
      return {
        'day': weekdays[index],
        'date': date.day.toString(),
        'fullDate': date,
      };
    });

    return Column(
      children: weekDays.map((dayInfo) => _buildDayCard(dayInfo, mealPlans)).toList(),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> dayInfo, List<MealPlan> mealPlans) {
    final DateTime date = dayInfo['fullDate'];
    final dayMeals = mealPlans.where((meal) => 
      meal.date.year == date.year && 
      meal.date.month == date.month && 
      meal.date.day == date.day
    ).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                      dayInfo['date'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dayInfo['day'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildMealSection('☀️', 'Sáng', date, dayMeals, 'breakfast'),
          _buildMealSection('🌤', 'Trưa', date, dayMeals, 'lunch'),
          _buildMealSection('🌙', 'Tối', date, dayMeals, 'dinner'),
        ],
      ),
    );
  }

  Widget _buildMealSection(String emoji, String mealTime, DateTime date, 
      List<MealPlan> dayMeals, String mealTimeKey) {
    final mealPlansForTime = dayMeals.where((meal) => meal.mealTime == mealTimeKey).toList();

    return DragTarget<Map<String, String>>(
      onAcceptWithDetails: (details) async {
        final data = details.data;
        try {
          await _viewModel.onDropRecipeToCalendar(
            date: date,
            mealTime: mealTimeKey,
            recipeId: data['recipeId']!,
            householdId: _householdId,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã thêm ${data['recipeName']} vào $mealTime')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Có lỗi xảy ra khi thêm món ăn')),
            );
          }
        }
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
                ...mealPlansForTime.map((meal) => 
                  _buildMealItem(meal.recipeId, meal.id)),
                _buildAddMealButton(date, mealTimeKey),
              ] else
                _buildEmptyMealSlot(date, mealTimeKey),
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
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x4CA7D4B9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Đang tải...'),
          );
        }

        final recipe = snapshot.data;
        if (recipe == null) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Không tìm thấy món ăn'),
          );
        }

        return FutureBuilder<int>(
          future: _viewModel.getMissingIngredientsCount(recipeId, _householdId),
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
                        onTap: () async {
                          await _viewModel.deleteMealPlan(mealPlanId);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã xóa món ăn khỏi kế hoạch')),
                            );
                          }
                        },
                        child: const Text(
                          '✕',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D2838),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hasWarning) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/icon_conthieu.png',
                          width: 14,
                          height: 14,
                          fit: BoxFit.contain,
                          color: const Color(0xFFFFB84D),
                          colorBlendMode: BlendMode.srcIn,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Thiếu $missingCount nguyên liệu',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFFB84D),
                          ),
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

  Widget _buildAddMealButton(DateTime date, String mealTimeKey) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D5DB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          _showDishSelectionForm(context);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: Color(0xFF99A1AE)),
            SizedBox(width: 8),
            Text(
              'Thêm món',
              style: TextStyle(color: Color(0xFF99A1AE), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMealSlot(DateTime date, String mealTimeKey) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D5DB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          _showDishSelectionForm(context);
        },
        child: const Text(
          'Chưa có món',
          style: TextStyle(color: Color(0xFF99A1AE), fontSize: 14),
        ),
      ),
    );
  }
}

class DishSelectionForm extends StatefulWidget {
  final ScrollController scrollController;
  final Function(String recipeId, String recipeName) onDishSelected;
  final VoidCallback onDishDropped;
  final MealPlannerViewModel viewModel;
  final String householdId;

  const DishSelectionForm({
    super.key,
    required this.scrollController,
    required this.onDishSelected,
    required this.onDishDropped,
    required this.viewModel,
    required this.householdId,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chọn món ăn',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101727),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
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
                            onChanged: (value) {
                              setState(() {
                                _searchText = value.toLowerCase();
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Tìm món ăn...',
                              hintStyle: TextStyle(
                                color: Color(0xFF697282),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kéo thả món ăn vào lịch hoặc nhấn để chọn',
                    style: TextStyle(
                      color: Color(0xFF697282),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<Recipe>>(
                    stream: widget.viewModel.getRecipesByHousehold(widget.householdId),
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
                              Text(
                                'Có lỗi xảy ra khi tải dữ liệu',
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Chi tiết: ${snapshot.error}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {}); // Rebuild to retry
                                },
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      }

                      final recipes = snapshot.data ?? [];
                      
                      if (recipes.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              const Icon(Icons.restaurant, color: Colors.grey, size: 64),
                              const SizedBox(height: 16),
                              const Text(
                                'Chưa có công thức nào',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF697282),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hãy thêm công thức mới để bắt đầu lập kế hoạch bữa ăn!',
                                style: TextStyle(color: Color(0xFF697282)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Navigate to add recipe screen
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Chức năng thêm công thức đang được phát triển'),
                                    ),
                                  );
                                },
                                child: const Text('Thêm công thức'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Filter recipes based on search text
                      final filteredRecipes = recipes.where((recipe) {
                        return _searchText.isEmpty ||
                               recipe.recipeName.toLowerCase().contains(_searchText);
                      }).toList();

                      if (filteredRecipes.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.search_off, color: Colors.grey, size: 48),
                                SizedBox(height: 16),
                                Text(
                                  'Không tìm thấy món ăn nào',
                                  style: TextStyle(color: Color(0xFF697282), fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Thử tìm kiếm với từ khóa khác',
                                  style: TextStyle(color: Color(0xFF697282), fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: filteredRecipes.map((recipe) => 
                          _buildDishItem(recipe)
                        ).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDishItem(Recipe recipe) {
    return FutureBuilder<bool>(
      future: widget.viewModel.checkIngredientsAvailability(recipe.id, widget.householdId),
      builder: (context, availabilitySnapshot) {
        final hasEnoughIngredients = availabilitySnapshot.data ?? false;
        
        return FutureBuilder<int>(
          future: widget.viewModel.getMissingIngredientsCount(recipe.id, widget.householdId),
          builder: (context, missingSnapshot) {
            final missingCount = missingSnapshot.data ?? 0;

            return Draggable<Map<String, String>>(
              data: {
                'recipeId': recipe.id,
                'recipeName': recipe.recipeName,
              },
              onDragEnd: (details) {
                if (details.wasAccepted) {
                  widget.onDishDropped(); // Callback để đóng form
                }
              },
              feedback: Material(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasEnoughIngredients 
                        ? const Color(0xFFF0FDF4) 
                        : const Color(0xFFFEF9C2),
                    border: Border.all(
                      color: hasEnoughIngredients 
                          ? const Color(0xFFB8F7CF) 
                          : const Color(0xFFFFDF20),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: recipe.recipeImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  recipe.recipeImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.restaurant);
                                  },
                                ),
                              )
                            : const Icon(Icons.restaurant),
                      ),
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
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: _buildDishContainer(recipe, hasEnoughIngredients, missingCount),
              ),
              child: GestureDetector(
                onTap: () => widget.onDishSelected(recipe.id, recipe.recipeName),
                child: _buildDishContainer(recipe, hasEnoughIngredients, missingCount),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDishContainer(Recipe recipe, bool hasEnoughIngredients, int missingCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasEnoughIngredients 
            ? const Color(0xFFF0FDF4) 
            : const Color(0xFFFEF9C2),
        border: Border.all(
          color: hasEnoughIngredients 
              ? const Color(0xFFB8F7CF) 
              : const Color(0xFFFFDF20),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 57,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[200],
            ),
            child: recipe.recipeImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      recipe.recipeImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.restaurant, size: 30);
                      },
                    ),
                  )
                : const Icon(Icons.restaurant, size: 30),
          ),
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
                    Image.asset(
                      hasEnoughIngredients
                          ? 'assets/images/icon_check.png'
                          : 'assets/images/icon_conthieu.png',
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasEnoughIngredients 
                          ? 'Đủ nguyên liệu'
                          : 'Thiếu $missingCount nguyên liệu',
                      style: TextStyle(
                        fontSize: 14,
                        color: hasEnoughIngredients 
                            ? const Color(0xFFA8D5BA) 
                            : const Color(0xFFA65F00),
                      ),
                    ),
                  ],
                ),
                if (recipe.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    recipe.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF697282),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}