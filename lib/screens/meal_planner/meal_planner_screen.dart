import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../providers/meal_planner_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../models/recipe.dart';
import '../../models/meal_plan.dart';
import '../../models/nutrition.dart';
import '../recipe/detail_screen.dart';

/// Meal Planner — วางแผนรายวัน/สัปดาห์/เดือน + คำนวณแคลอรี/สารอาหาร
class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<MealPlannerProvider>();
    final recipes = context.watch<RecipeProvider>().allRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('วางแผนมื้ออาหาร'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'รายวัน'),
            Tab(text: 'รายสัปดาห์'),
            Tab(text: 'รายเดือน'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMealDialog(context),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DailyView(
            date: _selectedDate,
            entries: planner.entriesForDate(_selectedDate),
            nutrition: planner.nutritionForDate(_selectedDate, recipes),
            onDateChanged: (d) => setState(() => _selectedDate = d),
            recipes: recipes,
          ),
          _WeeklyView(
            weekStart: _weekStart(_selectedDate),
            entries: planner.entriesForWeek(_weekStart(_selectedDate)),
            nutrition: planner.nutritionForWeek(_weekStart(_selectedDate), recipes),
            recipes: recipes,
          ),
          _MonthlyView(
            month: _selectedDate.month,
            year: _selectedDate.year,
            entries: planner.entriesForMonth(_selectedDate.year, _selectedDate.month),
            recipes: recipes,
          ),
        ],
      ),
    );
  }

  DateTime _weekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _showAddMealDialog(BuildContext context) {
    final recipes = context.read<RecipeProvider>().allRecipes;
    final planner = context.read<MealPlannerProvider>();
    String? selectedRecipeId = recipes.isNotEmpty ? recipes.first.id : null;
    MealType selectedMeal = MealType.lunch;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('เพิ่มมื้ออาหาร'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedRecipeId,
                decoration: const InputDecoration(labelText: 'เลือกเมนู'),
                items: recipes
                    .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
                    .toList(),
                onChanged: (v) => setState(() => selectedRecipeId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MealType>(
                value: selectedMeal,
                decoration: const InputDecoration(labelText: 'มื้อ'),
                items: MealType.values
                    .map((m) => DropdownMenuItem(value: m, child: Text('${m.emoji} ${m.label}')))
                    .toList(),
                onChanged: (v) => setState(() => selectedMeal = v ?? MealType.lunch),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
            TextButton(
              onPressed: () {
                if (selectedRecipeId != null) {
                  planner.addEntry(
                    recipeId: selectedRecipeId!,
                    date: _selectedDate,
                    mealType: selectedMeal,
                  );
                }
                Navigator.pop(ctx);
              },
              child: const Text('เพิ่ม'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyView extends StatelessWidget {
  final DateTime date;
  final List<MealPlanEntry> entries;
  final NutritionInfo nutrition;
  final ValueChanged<DateTime> onDateChanged;
  final List<Recipe> recipes;

  const _DailyView({
    required this.date,
    required this.entries,
    required this.nutrition,
    required this.onDateChanged,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    final planner = context.read<MealPlannerProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onDateChanged(date.subtract(const Duration(days: 1))),
            ),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onDateChanged(date.add(const Duration(days: 1))),
            ),
          ],
        ),
        _NutritionSummary(nutrition: nutrition, title: 'สารอาหารวันนี้'),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          const EmptyStateWidget(message: 'ยังไม่มีมื้ออาหารในวันนี้', emoji: '🍽️')
        else
          ...entries.map((e) {
            final recipe = recipes.cast<Recipe?>().firstWhere(
                  (r) => r?.id == e.recipeId,
                  orElse: () => null,
                );
            return _MealEntryTile(
              mealType: e.mealType,
              recipeName: recipe?.name ?? 'ไม่พบสูตร',
              onTap: recipe != null
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailScreen(recipe: recipe)),
                      )
                  : null,
              onDelete: () => planner.removeEntry(e.id),
            );
          }),
      ],
    );
  }
}

class _WeeklyView extends StatelessWidget {
  final DateTime weekStart;
  final List<MealPlanEntry> entries;
  final NutritionInfo nutrition;
  final List<Recipe> recipes;

  const _WeeklyView({
    required this.weekStart,
    required this.entries,
    required this.nutrition,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'สัปดาห์ ${weekStart.day}/${weekStart.month} - ${weekStart.add(const Duration(days: 6)).day}/${weekStart.add(const Duration(days: 6)).month}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _NutritionSummary(nutrition: nutrition, title: 'สารอาหารสัปดาห์นี้'),
        const SizedBox(height: 16),
        ...List.generate(7, (i) {
          final day = weekStart.add(Duration(days: i));
          final dayEntries = entries.where((e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('${day.day}/${day.month}', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${dayEntries.length} มื้อ'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        }),
      ],
    );
  }
}

class _MonthlyView extends StatelessWidget {
  final int month;
  final int year;
  final List<MealPlanEntry> entries;
  final List<Recipe> recipes;

  const _MonthlyView({
    required this.month,
    required this.year,
    required this.entries,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    final monthNames = ['', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${monthNames[month]} $year',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Text('รวม ${entries.length} มื้อในเดือนนี้'),
        const SizedBox(height: 16),
        ...entries.map((e) {
          final recipe = recipes.cast<dynamic>().firstWhere(
                (r) => r.id == e.recipeId,
                orElse: () => null,
              );
          return ListTile(
            leading: Text(e.mealType.emoji, style: const TextStyle(fontSize: 20)),
            title: Text(recipe?.name ?? 'ไม่พบสูตร'),
            subtitle: Text('${e.date.day}/${e.date.month} · ${e.mealType.label}'),
          );
        }),
      ],
    );
  }
}

class _NutritionSummary extends StatelessWidget {
  final NutritionInfo nutrition;
  final String title;

  const _NutritionSummary({required this.nutrition, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutItem('🔥', '${nutrition.calories}', 'kcal'),
              _NutItem('💪', '${nutrition.protein.toStringAsFixed(0)}g', 'โปรตีน'),
              _NutItem('🧈', '${nutrition.fat.toStringAsFixed(0)}g', 'ไขมัน'),
              _NutItem('🍞', '${nutrition.carbs.toStringAsFixed(0)}g', 'คาร์บ'),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutItem extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _NutItem(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _MealEntryTile extends StatelessWidget {
  final MealType mealType;
  final String recipeName;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _MealEntryTile({
    required this.mealType,
    required this.recipeName,
    this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(mealType.emoji, style: const TextStyle(fontSize: 24)),
        title: Text(recipeName),
        subtitle: Text(mealType.label),
        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
        onTap: onTap,
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String emoji;

  const EmptyStateWidget({super.key, required this.message, this.emoji = '🔍'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
