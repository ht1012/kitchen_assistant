class MealPlan {
  final String id;
  final DateTime date;
  final String householdId;
  final String mealTime;
  final String recipeId;

  MealPlan({
    required this.id,
    required this.date,
    required this.householdId,
    required this.mealTime,
    required this.recipeId,
  });

  factory MealPlan.fromFirestore(String id, Map<String, dynamic> data) {
    return MealPlan(
      id: id,
      date: DateTime.parse(data['date']),
      householdId: data['household_id'],
      mealTime: data['meal_time'],
      recipeId: data['recipe_id'],
    );
  }
}
