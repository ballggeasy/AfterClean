import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../data/recipe_data.dart';

/// ตัวเลือกกรองตามแหล่งที่มาของสูตร
enum SourceFilter { all, official, user }

/// จัดการ state ของแอป: รายการสูตรอาหาร, favorites, การค้นหา, หมวดหมู่,
/// ประเทศ และแหล่งที่มา (ทางการ/ผู้ใช้)
class RecipeProvider extends ChangeNotifier {
  final List<Recipe> _allRecipes = RecipeData.recipes;
  final Set<String> _favoriteIds = {};

  String _searchQuery = '';
  String _selectedCategory = 'ทั้งหมด';
  String _selectedCountry = 'ทั้งหมด';
  SourceFilter _selectedSource = SourceFilter.all;

  List<Recipe> get allRecipes => _allRecipes;

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedCountry => _selectedCountry;
  SourceFilter get selectedSource => _selectedSource;

  /// รายการสูตรอาหารที่ผ่านการกรองด้วยคำค้นหา หมวดหมู่ ประเทศ และแหล่งที่มา
  List<Recipe> get filteredRecipes {
    return _allRecipes.where((recipe) {
      final matchesCategory =
          _selectedCategory == 'ทั้งหมด' || recipe.category == _selectedCategory;
      final matchesCountry =
          _selectedCountry == 'ทั้งหมด' || recipe.country == _selectedCountry;
      final matchesSource = switch (_selectedSource) {
        SourceFilter.all => true,
        SourceFilter.official => recipe.isOfficial,
        SourceFilter.user => !recipe.isOfficial,
      };
      final matchesSearch = recipe.matchesQuery(_searchQuery);
      return matchesCategory && matchesCountry && matchesSource && matchesSearch;
    }).toList();
  }

  /// รายการสูตรอาหารที่ถูก favorite ไว้
  List<Recipe> get favoriteRecipes {
    return _allRecipes.where((r) => _favoriteIds.contains(r.id)).toList();
  }

  bool isFavorite(String recipeId) => _favoriteIds.contains(recipeId);

  void toggleFavorite(String recipeId) {
    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
    }
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateSelectedCountry(String country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void updateSelectedSource(SourceFilter source) {
    _selectedSource = source;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
