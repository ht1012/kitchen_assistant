import 'package:flutter/material.dart';
import 'package:kitchen_assistant/models/meal_plan_model.dart';
import 'package:kitchen_assistant/models/recipe_model.dart';
import 'package:kitchen_assistant/services/meal_plan_service.dart';
import 'package:kitchen_assistant/services/recipe_service.dart';

class MealPlannerViewModel extends ChangeNotifier {
  final MealPlanService _mealPlanService;
  final RecipeService _recipeService;

  MealPlannerViewModel(this._mealPlanService, this._recipeService);

  Stream<List<MealPlan>> getWeeklyPlans(
    String householdId,
    DateTime weekStart,
  ) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return _mealPlanService.getMealPlansByWeek(householdId, weekStart, weekEnd);
  }

  Stream<List<Recipe>> getRecipesByHousehold(String householdId) {
    return _recipeService.getRecipesByHousehold(householdId);
  }

  Future<Recipe?> getRecipeById(String recipeId) {
    return _recipeService.getRecipeById(recipeId);
  }

  Future<bool> checkIngredientsAvailability(String recipeId, String householdId) {
    return _recipeService.checkIngredientsAvailability(recipeId, householdId);
  }

  Future<int> getMissingIngredientsCount(String recipeId, String householdId) {
    return _recipeService.getMissingIngredientsCount(recipeId, householdId);
  }

  Future<void> onDropRecipeToCalendar({
    required DateTime date,
    required String mealTime,
    required String recipeId,
    required String householdId,
  }) async {
    await _mealPlanService.addMealPlan(
      date: date,
      mealTime: mealTime,
      recipeId: recipeId,
      householdId: householdId,
    );
  }

  Future<void> deleteMealPlan(String mealPlanId) async {
    await _mealPlanService.deleteMealPlan(mealPlanId);
  }
}