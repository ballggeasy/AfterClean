/// รายการมื้ออาหารในแผน
class MealPlanEntry {
  final String id;
  final String recipeId;
  final DateTime date;
  final MealType mealType;
  final int servings;

  const MealPlanEntry({
    required this.id,
    required this.recipeId,
    required this.date,
    required this.mealType,
    this.servings = 1,
  });

  MealPlanEntry copyWith({
    String? recipeId,
    DateTime? date,
    MealType? mealType,
    int? servings,
  }) {
    return MealPlanEntry(
      id: id,
      recipeId: recipeId ?? this.recipeId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      servings: servings ?? this.servings,
    );
  }
}

enum MealType {
  breakfast('อาหารเช้า', '🌅'),
  lunch('อาหารกลางวัน', '☀️'),
  dinner('อาหารเย็น', '🌙'),
  snack('ของว่าง', '🍪');

  final String label;
  final String emoji;
  const MealType(this.label, this.emoji);
}
