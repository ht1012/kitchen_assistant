import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitchen_assistant/models/meal_plan_model.dart';

class MealPlanService {
  final _db = FirebaseFirestore.instance;

  Stream<List<MealPlan>> getMealPlansByWeek(
    String householdId,
    DateTime start,
    DateTime end,
  ) {
    return _db
        .collection('meal_plans')
        .where('household_id', isEqualTo: householdId)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => MealPlan.fromFirestore(d.id, d.data()))
            .toList());
  }

  Future<void> addMealPlan({
    required DateTime date,
    required String mealTime,
    required String recipeId,
    required String householdId,
  }) async {
    await _db.collection('meal_plans').add({
      'date': date.toIso8601String(),
      'meal_time': mealTime,
      'recipe_id': recipeId,
      'household_id': householdId,
    });
  }

  Future<void> deleteMealPlan(String mealPlanId) async {
    await _db.collection('meal_plans').doc(mealPlanId).delete();
  }
}