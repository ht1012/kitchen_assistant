import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitchen_assistant/models/meal_plan_model.dart';

class MealPlanService {
  final _db = FirebaseFirestore.instance;

  Stream<List<MealPlan>> getMealPlansByWeek(
    String householdId,
    DateTime start,
    DateTime end,
  ) {
    // Chuẩn hóa ngày bắt đầu và kết thúc
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return _db
        .collection('meal_plans')
        .where('household_id', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) {
      final allMealPlans = snapshot.docs
          .map((d) => MealPlan.fromFirestore(d.id, d.data()))
          .toList();

      // Filter theo ngày trong code để tránh vấn đề với format date
      return allMealPlans.where((meal) {
        final mealDate = DateTime(
          meal.date.year,
          meal.date.month,
          meal.date.day,
        );
        return mealDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            mealDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    });
  }

  Future<void> addMealPlan({
    required DateTime date,
    required String mealTime,
    required String recipeId,
    required String householdId,
  }) async {
    // Chuẩn hóa ngày (chỉ lấy năm/tháng/ngày, không có giờ)
    final normalizedDate = DateTime(date.year, date.month, date.day);

    await _db.collection('meal_plans').add({
      'date': normalizedDate.toIso8601String(),
      'meal_time': mealTime,
      'recipe_id': recipeId,
      'household_id': householdId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMealPlan(String mealPlanId) async {
    await _db.collection('meal_plans').doc(mealPlanId).delete();
  }
}