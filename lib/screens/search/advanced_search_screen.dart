import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/recipe_data.dart';
import '../../theme/app_theme.dart';
import '../../providers/recipe_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/search/search_bar_widget.dart';
import '../../widgets/common/filter_chip_widget.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/common/empty_state.dart';
import '../recipe/detail_screen.dart';

/// ค้นหาขั้นสูง — Filter, Sort, ค้นหาตามชื่อ/วัตถุดิบ/ประเภท/ประเทศ/เวลา/ความยาก
class AdvancedSearchScreen extends StatelessWidget {
  const AdvancedSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final recipes = provider.filteredRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาขั้นสูง'),
        actions: [
          TextButton(
            onPressed: provider.clearFilters,
            child: const Text('ล้างทั้งหมด'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SearchBarWidget(showHistory: true),
          const SizedBox(height: 20),
          const Text('ประเภทอาหาร', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RecipeData.categories.map((cat) {
              return FilterChipWidget(
                label: cat,
                isSelected: provider.selectedCategory == cat,
                onTap: () => provider.updateSelectedCategory(cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('ประเทศ', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RecipeData.countries.map((c) {
              return FilterChipWidget(
                label: c,
                isSelected: provider.selectedCountry == c,
                onTap: () => provider.updateSelectedCountry(c),
                filled: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('ระดับความยาก', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChipWidget(
                label: 'ทั้งหมด',
                isSelected: provider.selectedDifficulty == null,
                onTap: () => provider.updateSelectedDifficulty(null),
              ),
              ...AppConstants.difficulties.map(
                (d) => FilterChipWidget(
                  label: d,
                  isSelected: provider.selectedDifficulty == d,
                  onTap: () => provider.updateSelectedDifficulty(d),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('เวลาในการทำ (สูงสุด)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [null, 15, 30, 45, 60].map((mins) {
              final label = mins == null ? 'ไม่จำกัด' : '$mins นาที';
              return FilterChipWidget(
                label: label,
                isSelected: provider.maxCookTime == mins,
                onTap: () => provider.updateMaxCookTime(mins),
                filled: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('เรียงตาม', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.sortOptions.map((o) {
              final opt = _sortFromKey(o.$1);
              return FilterChipWidget(
                label: o.$2,
                isSelected: provider.sortOption == opt,
                onTap: () => provider.updateSortOption(opt),
                filled: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'ผลลัพธ์ (${recipes.length} เมนู)',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (recipes.isEmpty)
            const EmptyState(message: 'ไม่พบเมนูที่ตรงเงื่อนไข')
          else
            ...recipes.map(
              (recipe) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 200,
                  child: RecipeCard(
                    recipe: recipe,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailScreen(recipe: recipe)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  SortOption _sortFromKey(String key) => switch (key) {
        'name_asc' => SortOption.nameAsc,
        'name_desc' => SortOption.nameDesc,
        'rating_desc' => SortOption.ratingDesc,
        'time_asc' => SortOption.timeAsc,
        'time_desc' => SortOption.timeDesc,
        'newest' => SortOption.newest,
        _ => SortOption.popular,
      };
}
