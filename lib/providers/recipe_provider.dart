import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import '../data/recipe_data.dart';

/// ตัวเลือกกรองตามแหล่งที่มาของสูตร
enum SourceFilter { all, official, user }

/// จัดการ state ของแอป: รายการสูตรอาหาร, favorites, การค้นหา, หมวดหมู่,
/// ประเทศ และแหล่งที่มา (ทางการ/ผู้ใช้)
///
/// favorites ถูกเก็บแยกตามผู้ใช้แต่ละคน (key ตามอีเมล หรือ 'guest' สำหรับผู้เยี่ยมชม)
/// ต้องเรียก loadFavoritesForUser() ทุกครั้งที่มีการล็อกอิน/ล็อกเอาต์/สลับบัญชี
class RecipeProvider extends ChangeNotifier {
  static const _favoritesKeyPrefix = 'favorites_';

  final List<Recipe> _allRecipes = RecipeData.recipes;
  Set<String> _favoriteIds = {};
  String _currentUserKey = 'guest';

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

  /// รายการสูตรอาหารที่ถูก favorite ไว้ (เฉพาะของผู้ใช้ปัจจุบัน)
  List<Recipe> get favoriteRecipes {
    return _allRecipes.where((r) => _favoriteIds.contains(r.id)).toList();
  }

  bool isFavorite(String recipeId) => _favoriteIds.contains(recipeId);

  /// โหลดรายการ favorites ของผู้ใช้ที่ระบุ (ใช้ email เป็น key)
  /// ส่ง null เมื่อไม่มีผู้ใช้ล็อกอิน (จะใช้ key 'guest' แทน)
  /// ต้องเรียกทุกครั้งหลังล็อกอิน สมัครสมาชิก ล็อกอินแบบ guest หรือล็อกเอาต์
  Future<void> loadFavoritesForUser(String? userKey) async {
    _currentUserKey = userKey ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('$_favoritesKeyPrefix$_currentUserKey') ?? [];
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

  void toggleFavorite(String recipeId) {
    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
    }
    notifyListeners();
    _persistFavorites();
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
