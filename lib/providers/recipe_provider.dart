import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/nutrition.dart';
import '../data/recipe_data.dart';
import '../utils/constants.dart';

/// จัดการ state หลัก: CRUD สูตร, ค้นหา, กรอง, เรียง, favorites
class RecipeProvider extends ChangeNotifier {
  static const _favoritesKeyPrefix = 'favorites_';
  static const _searchHistoryKey = 'search_history';

  List<Recipe> _allRecipes = RecipeData.recipes.map((r) => r).toList();
  Set<String> _favoriteIds = {};
  String _currentUserKey = 'guest';

  String _searchQuery = '';
  String _selectedCategory = 'ทั้งหมด';
  String _selectedCountry = 'ทั้งหมด';
  SourceFilter _selectedSource = SourceFilter.all;
  SortOption _sortOption = SortOption.ratingDesc;
  RecipeListMode _listMode = RecipeListMode.all;
  String? _selectedDietTag;
  int? _maxCookTime;
  String? _selectedDifficulty;
  List<String> _searchHistory = [];

  List<Recipe> get allRecipes => _allRecipes;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedCountry => _selectedCountry;
  SourceFilter get selectedSource => _selectedSource;
  SortOption get sortOption => _sortOption;
  RecipeListMode get listMode => _listMode;
  String? get selectedDietTag => _selectedDietTag;
  int? get maxCookTime => _maxCookTime;
  String? get selectedDifficulty => _selectedDifficulty;
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  Recipe? getById(String id) {
    try {
      return _allRecipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Recipe> get filteredRecipes {
    var list = _allRecipes.where((recipe) {
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
      final matchesDiet =
          _selectedDietTag == null || recipe.matchesDietTag(_selectedDietTag!);
      final matchesTime =
          _maxCookTime == null || recipe.totalTimeMinutes <= _maxCookTime!;
      final matchesDiff = _selectedDifficulty == null ||
          recipe.difficulty == _selectedDifficulty;
      return matchesCategory &&
          matchesCountry &&
          matchesSource &&
          matchesSearch &&
          matchesDiet &&
          matchesTime &&
          matchesDiff;
    }).toList();

    list = _applyListMode(list);
    return _sort(list);
  }

  List<Recipe> _applyListMode(List<Recipe> list) {
    switch (_listMode) {
      case RecipeListMode.all:
        return list;
      case RecipeListMode.latest:
        final sorted = [...list]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return sorted.take(10).toList();
      case RecipeListMode.popular:
        final sorted = [...list]..sort((a, b) => b.viewCount.compareTo(a.viewCount));
        return sorted.take(10).toList();
      case RecipeListMode.recommended:
        return list.where((r) => r.isRecommended).toList();
      case RecipeListMode.random:
        final shuffled = [...list]..shuffle(Random());
        return shuffled.take(6).toList();
      case RecipeListMode.seasonal:
        return list.where((r) => r.season != 'ตลอดปี').toList();
      case RecipeListMode.diet:
        return _selectedDietTag != null
            ? list.where((r) => r.matchesDietTag(_selectedDietTag!)).toList()
            : list;
    }
  }

  List<Recipe> _sort(List<Recipe> list) {
    final sorted = [...list];
    switch (_sortOption) {
      case SortOption.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case SortOption.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
      case SortOption.ratingDesc:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.timeAsc:
        sorted.sort((a, b) => a.totalTimeMinutes.compareTo(b.totalTimeMinutes));
      case SortOption.timeDesc:
        sorted.sort((a, b) => b.totalTimeMinutes.compareTo(a.totalTimeMinutes));
      case SortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOption.popular:
        sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    }
    return sorted;
  }

  List<Recipe> get favoriteRecipes =>
      _allRecipes.where((r) => _favoriteIds.contains(r.id)).toList();

  bool isFavorite(String recipeId) => _favoriteIds.contains(recipeId);

  /// Auto-complete suggestions จากชื่อเมนูและวัตถุดิบ
  List<String> getAutocompleteSuggestions(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    final names = _allRecipes
        .where((r) => r.name.toLowerCase().contains(q))
        .map((r) => r.name);
    final ingredients = _allRecipes
        .expand((r) => r.ingredients)
        .where((i) => i.toLowerCase().contains(q))
        .map((i) => i.split(' ').skip(1).join(' ').isEmpty
            ? i
            : i.split(' ').skip(1).join(' '));
    return {...names, ...ingredients}.take(8).toList();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList(_searchHistoryKey) ?? [];
    notifyListeners();
  }

  Future<void> loadFavoritesForUser(String? userKey) async {
    _currentUserKey = userKey ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    final stored =
        prefs.getStringList('$_favoritesKeyPrefix$_currentUserKey') ?? [];
    _favoriteIds = stored.toSet();
    notifyListeners();
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      '$_favoritesKeyPrefix$_currentUserKey',
      _favoriteIds.toList(),
    );
  }

  Future<void> _persistSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchHistoryKey, _searchHistory);
  }

  void toggleFavorite(String recipeId) {
    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
    }
    notifyListeners();
    _persistFavorites();
  }

  void addToSearchHistory(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _searchHistory.remove(trimmed);
    _searchHistory.insert(0, trimmed);
    if (_searchHistory.length > AppConstants.maxSearchHistory) {
      _searchHistory = _searchHistory.take(AppConstants.maxSearchHistory).toList();
    }
    notifyListeners();
    _persistSearchHistory();
  }

  void clearSearchHistory() {
    _searchHistory = [];
    notifyListeners();
    _persistSearchHistory();
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

  void updateSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void updateListMode(RecipeListMode mode, {String? dietTag}) {
    _listMode = mode;
    _selectedDietTag = dietTag;
    notifyListeners();
  }

  void updateMaxCookTime(int? minutes) {
    _maxCookTime = minutes;
    notifyListeners();
  }

  void updateSelectedDifficulty(String? difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'ทั้งหมด';
    _selectedCountry = 'ทั้งหมด';
    _selectedSource = SourceFilter.all;
    _selectedDietTag = null;
    _maxCookTime = null;
    _selectedDifficulty = null;
    _listMode = RecipeListMode.all;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// เพิ่มสูตรใหม่ (mock — เก็บใน memory)
  void addRecipe(Recipe recipe) {
    _allRecipes.insert(0, recipe);
    notifyListeners();
  }

  /// แก้ไขสูตร
  void updateRecipe(Recipe recipe) {
    final index = _allRecipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      _allRecipes[index] = recipe;
      notifyListeners();
    }
  }

  /// ลบสูตร
  void deleteRecipe(String id) {
    _allRecipes.removeWhere((r) => r.id == id);
    _favoriteIds.remove(id);
    notifyListeners();
    _persistFavorites();
  }

  /// สร้าง ID ใหม่
  String generateId() {
    final maxId = _allRecipes
        .map((r) => int.tryParse(r.id) ?? 0)
        .fold(0, (a, b) => a > b ? a : b);
    return '${maxId + 1}';
  }

  /// สร้างสูตรจากฟอร์ม
  Recipe buildRecipeFromForm({
    required String id,
    required String name,
    required String emoji,
    required String category,
    required String country,
    required int prepTime,
    required int cookTime,
    required String difficulty,
    required int servings,
    required List<String> steps,
    required List<IngredientItem> items,
    String? tips,
    String? platingTips,
    List<String> dietTags = const [],
    NutritionInfo? nutrition,
    bool isOfficial = false,
    String? uploaderName,
  }) {
    return Recipe(
      id: id,
      name: name,
      emoji: emoji,
      imageUrl: '',
      category: category,
      country: country,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      difficulty: difficulty,
      servings: servings,
      steps: steps,
      ingredients: items.map((i) => i.display).toList(),
      ingredientItems: items,
      tips: tips,
      platingTips: platingTips,
      dietTags: dietTags,
      nutrition: nutrition,
      isOfficial: isOfficial,
      uploaderName: uploaderName,
      createdAt: DateTime.now(),
    );
  }
}
