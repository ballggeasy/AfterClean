import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/recipe_data.dart';
import '../theme/app_theme.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'favorites_screen.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';

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
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'รายการที่ชอบ',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'โปรไฟล์',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: _SearchBar(provider: provider),
          ),
          // แถวที่ 1: filter แหล่งที่มา (ทั้งหมด / ทางการ / ผู้ใช้)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SourceFilterRow(provider: provider),
          ),
          const SizedBox(height: 10),
          // แถวที่ 2: filter หมวดหมู่อาหาร
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: RecipeData.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = RecipeData.categories[index];
                final isSelected = provider.selectedCategory == category;
                return _FilterChip(
                  label: category,
                  isSelected: isSelected,
                  onTap: () => provider.updateSelectedCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // แถวที่ 3: filter ประเทศ
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: RecipeData.countries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final country = RecipeData.countries[index];
                final isSelected = provider.selectedCountry == country;
                return _FilterChip(
                  label: country == 'ทั้งหมด' ? '🌏 ทั้งหมด' : '${_countryFlag(country)} $country',
                  isSelected: isSelected,
                  onTap: () => provider.updateSelectedCountry(country),
                  filled: false,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: recipes.isEmpty
                ? const _EmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(recipe: recipe),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// ใช้แสดงธงประเทศแบบ emoji คู่กับชื่อประเทศใน filter chip
String _countryFlag(String country) {
  switch (country) {
    case 'ไทย':
      return '🇹🇭';
    case 'อิตาลี':
      return '🇮🇹';
    case 'ญี่ปุ่น':
      return '🇯🇵';
    case 'จีน':
      return '🇨🇳';
    case 'เกาหลี':
      return '🇰🇷';
    default:
      return '🌏';
  }
}

class _SearchBar extends StatelessWidget {
  final RecipeProvider provider;
  const _SearchBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: TextField(
        onChanged: provider.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'ค้นหาเมนูหรือวัตถุดิบ เช่น "กุ้ง"',
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          suffixIcon: provider.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: provider.clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// แถบ segmented control สำหรับกรองแหล่งที่มา: ทั้งหมด / ทางการ / ผู้ใช้
class _SourceFilterRow extends StatelessWidget {
  final RecipeProvider provider;
  const _SourceFilterRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final List<(SourceFilter, String, IconData?)> options = [
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
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                      ),
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

/// chip ทรงกลมใช้ร่วมกันสำหรับ filter หมวดหมู่และประเทศ
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool filled;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBg = filled ? AppTheme.primary : AppTheme.primaryLight;
    final selectedFg = filled ? Colors.white : AppTheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedBg : AppTheme.divider,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isSelected ? selectedFg : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            'ไม่พบเมนูที่ตรงกับการค้นหา',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}