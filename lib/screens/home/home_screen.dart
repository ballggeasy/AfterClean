import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/recipe_data.dart';
import '../../theme/app_theme.dart';
import '../../providers/recipe_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/common/filter_chip_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/search/search_bar_widget.dart';
import '../recipe/detail_screen.dart';
import '../recipe/add_recipe_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final recipes = provider.filteredRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('สูตรอาหาร'),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'เรียงลำดับ',
            onSelected: provider.updateSortOption,
            itemBuilder: (_) => AppConstants.sortOptions
                .map((o) => PopupMenuItem(value: _sortFromKey(o.$1), child: Text(o.$2)))
                .toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มสูตร', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchBarWidget(showHistory: true),
          ),
          _HomeSections(provider: provider),
          const SizedBox(height: 8),
          _DietTagsRow(provider: provider),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SourceFilterRow(provider: provider),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: RecipeData.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = RecipeData.categories[index];
                return FilterChipWidget(
                  label: category,
                  isSelected: provider.selectedCategory == category,
                  onTap: () => provider.updateSelectedCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: RecipeData.countries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final country = RecipeData.countries[index];
                return FilterChipWidget(
                  label: country == 'ทั้งหมด' ? '🌏 ทั้งหมด' : '${_countryFlag(country)} $country',
                  isSelected: provider.selectedCountry == country,
                  onTap: () => provider.updateSelectedCountry(country),
                  filled: false,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: recipes.isEmpty
                ? EmptyState(
                    message: 'ไม่พบเมนูที่ตรงกับการค้นหา',
                    actionLabel: 'ล้างตัวกรอง',
                    onAction: provider.clearFilters,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(recipe: recipe)),
                        ),
                      );
                    },
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

String _countryFlag(String country) => switch (country) {
      'ไทย' => '🇹🇭',
      'อิตาลี' => '🇮🇹',
      'ญี่ปุ่น' => '🇯🇵',
      'จีน' => '🇨🇳',
      'เกาหลี' => '🇰🇷',
      _ => '🌏',
    };

class _HomeSections extends StatelessWidget {
  final RecipeProvider provider;
  const _HomeSections({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.homeSections.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (key, label, emoji) = AppConstants.homeSections[index];
          final mode = switch (key) {
            'latest' => RecipeListMode.latest,
            'popular' => RecipeListMode.popular,
            'recommended' => RecipeListMode.recommended,
            'random' => RecipeListMode.random,
            _ => RecipeListMode.seasonal,
          };
          final isSelected = provider.listMode == mode;
          return FilterChipWidget(
            label: '$emoji $label',
            isSelected: isSelected,
            onTap: () => provider.updateListMode(
              isSelected ? RecipeListMode.all : mode,
            ),
          );
        },
      ),
    );
  }
}

class _DietTagsRow extends StatelessWidget {
  final RecipeProvider provider;
  const _DietTagsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.dietTags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = AppConstants.dietTags[index];
          final isSelected = provider.selectedDietTag == tag;
          return FilterChipWidget(
            label: tag,
            isSelected: isSelected,
            onTap: () => provider.updateListMode(
              isSelected ? RecipeListMode.all : RecipeListMode.diet,
              dietTag: isSelected ? null : tag,
            ),
            filled: false,
          );
        },
      ),
    );
  }
}

class _SourceFilterRow extends StatelessWidget {
  final RecipeProvider provider;
  const _SourceFilterRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final options = [
      (SourceFilter.all, 'ทั้งหมด', null),
      (SourceFilter.official, 'ทางการ', Icons.verified_rounded),
      (SourceFilter.user, 'ผู้ใช้', Icons.person_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: options.map((option) {
          final (value, label, icon) = option;
          final isSelected = provider.selectedSource == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.updateSelectedSource(value),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 14, color: isSelected ? Colors.white : AppTheme.textSecondary),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
