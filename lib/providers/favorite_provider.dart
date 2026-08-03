import 'package:flutter/foundation.dart';

import '../models/favorite_folder.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

/// จัดการโฟลเดอร์สูตรโปรด, แชร์, ดาวน์โหลด (mock)
class FavoriteProvider extends ChangeNotifier {
  final List<FavoriteFolder> _folders = [
    FavoriteFolder(
      id: 'f1',
      name: 'เมนูโปรด',
      emoji: '❤️',
      recipeIds: ['1', '2'],
      createdAt: DateTime(2025, 6, 1),
    ),
    FavoriteFolder(
      id: 'f2',
      name: 'เมนูสุขภาพ',
      emoji: '🥗',
      recipeIds: ['2', '13'],
      createdAt: DateTime(2025, 6, 15),
    ),
    FavoriteFolder(
      id: 'f3',
      name: 'เมนูเด็ก',
      emoji: '👶',
      recipeIds: ['10'],
      createdAt: DateTime(2025, 7, 1),
    ),
  ];

  List<FavoriteFolder> get folders => List.unmodifiable(_folders);

  FavoriteFolder? getFolder(String id) {
    try {
      return _folders.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Recipe> recipesInFolder(String folderId, RecipeProvider recipeProvider) {
    final folder = getFolder(folderId);
    if (folder == null) return [];
    return folder.recipeIds
        .map((id) => recipeProvider.getById(id))
        .whereType<Recipe>()
        .toList();
  }

  void createFolder(String name, {String emoji = '📁'}) {
    _folders.add(FavoriteFolder(
      id: 'f${_folders.length + 1}',
      name: name,
      emoji: emoji,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void deleteFolder(String id) {
    _folders.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  void addRecipeToFolder(String folderId, String recipeId) {
    final index = _folders.indexWhere((f) => f.id == folderId);
    if (index == -1) return;
    final folder = _folders[index];
    if (folder.recipeIds.contains(recipeId)) return;
    _folders[index] = folder.copyWith(
      recipeIds: [...folder.recipeIds, recipeId],
    );
    notifyListeners();
  }

  void removeRecipeFromFolder(String folderId, String recipeId) {
    final index = _folders.indexWhere((f) => f.id == folderId);
    if (index == -1) return;
    final folder = _folders[index];
    _folders[index] = folder.copyWith(
      recipeIds: folder.recipeIds.where((id) => id != recipeId).toList(),
    );
    notifyListeners();
  }

  /// mock — แชร์สูตร (คืนลิงก์จำลอง)
  String shareRecipe(Recipe recipe) {
    return 'https://recipe-app.demo/share/${recipe.id}';
  }

  /// mock — ดาวน์โหลดสูตร (คืนชื่อไฟล์จำลอง)
  String downloadRecipe(Recipe recipe) {
    return '${recipe.name.replaceAll(' ', '_')}.pdf';
  }
}
