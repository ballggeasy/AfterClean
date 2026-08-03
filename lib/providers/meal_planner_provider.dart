import 'package:flutter/foundation.dart';

import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../models/nutrition.dart';

/// วางแผนมื้ออาหาร รายวัน/สัปดาห์/เดือน + คำนวณแคลอรี/สารอาหาร
class MealPlannerProvider extends ChangeNotifier {
  final List<MealPlanEntry> _entries = [
    MealPlanEntry(
      id: 'mp1',
      recipeId: '1',
      date: DateTime.now(),
      mealType: MealType.lunch,
    ),
    MealPlanEntry(
      id: 'mp2',
      recipeId: '2',
      date: DateTime.now(),
      mealType: MealType.dinner,
    ),
    MealPlanEntry(
      id: 'mp3',
      recipeId: '4',
      date: DateTime.now().add(const Duration(days: 1)),
      mealType: MealType.lunch,
    ),
  ];

  List<MealPlanEntry> get entries => List.unmodifiable(_entries);

  List<MealPlanEntry> entriesForDate(DateTime date) {
    return _entries.where((e) =>
        e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day).toList();
  }

  List<MealPlanEntry> entriesForWeek(DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 7));
    return _entries.where((e) =>
        e.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        e.date.isBefore(end)).toList();
  }

  List<MealPlanEntry> entriesForMonth(int year, int month) {
    return _entries.where((e) =>
        e.date.year == year && e.date.month == month).toList();
  }

  void addEntry({
    required String recipeId,
    required DateTime date,
    required MealType mealType,
    int servings = 1,
  }) {
    _entries.add(MealPlanEntry(
      id: 'mp${_entries.length + 1}',
      recipeId: recipeId,
      date: date,
      mealType: mealType,
      servings: servings,
    ));
    notifyListeners();
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// คำนวณแคลอรีรวมของวัน
  int totalCaloriesForDate(DateTime date, List<Recipe> recipes) {
    return _calcNutritionForDate(date, recipes).calories;
  }

  /// คำนวณสารอาหารรวมของวัน
  NutritionInfo nutritionForDate(DateTime date, List<Recipe> recipes) {
    return _calcNutritionForDate(date, recipes);
  }

  NutritionInfo _calcNutritionForDate(DateTime date, List<Recipe> recipes) {
    final dayEntries = entriesForDate(date);
    var total = const NutritionInfo();
    for (final entry in dayEntries) {
      final recipe = recipes.cast<Recipe?>().firstWhere(
            (r) => r?.id == entry.recipeId,
            orElse: () => null,
          );
      if (recipe?.nutrition != null) {
        final n = recipe!.nutrition!.forServings(entry.servings);
        total = NutritionInfo(
          calories: total.calories + n.calories,
          protein: total.protein + n.protein,
          fat: total.fat + n.fat,
          carbs: total.carbs + n.carbs,
          sugar: total.sugar + n.sugar,
          sodium: total.sodium + n.sodium,
        );
      }
    }
    return total;
  }

  NutritionInfo nutritionForWeek(DateTime weekStart, List<Recipe> recipes) {
    final weekEntries = entriesForWeek(weekStart);
    var total = const NutritionInfo();
    for (final entry in weekEntries) {
      final recipe = recipes.cast<Recipe?>().firstWhere(
            (r) => r?.id == entry.recipeId,
            orElse: () => null,
          );
      if (recipe?.nutrition != null) {
        final n = recipe!.nutrition!.forServings(entry.servings);
        total = NutritionInfo(
          calories: total.calories + n.calories,
          protein: total.protein + n.protein,
          fat: total.fat + n.fat,
          carbs: total.carbs + n.carbs,
          sugar: total.sugar + n.sugar,
          sodium: total.sodium + n.sodium,
        );
      }
    }
    return total;
  }
}
