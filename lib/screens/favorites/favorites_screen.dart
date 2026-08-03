import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../providers/recipe_provider.dart';
import '../../models/recipe.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/common/empty_state.dart';
import '../recipe/detail_screen.dart';

/// ระบบ Favorite — บันทึกสูตรโปรด, โฟลเดอร์, แชร์, ดาวน์โหลด
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    final favProvider = context.watch<FavoriteProvider>();
    final favorites = recipeProvider.favoriteRecipes;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('สูตรโปรด'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ทั้งหมด'),
              Tab(text: 'โฟลเดอร์'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AllFavoritesTab(favorites: favorites),
            _FoldersTab(favProvider: favProvider, recipeProvider: recipeProvider),
          ],
        ),
      ),
    );
  }
}

class _AllFavoritesTab extends StatelessWidget {
  final List favorites;

  const _AllFavoritesTab({required this.favorites});

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const EmptyState(emoji: '🤍', message: 'ยังไม่มีเมนูที่บันทึกไว้');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final recipe = favorites[index];
        return RecipeCard(
          recipe: recipe,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(recipe: recipe)),
          ),
        );
      },
    );
  }
}

class _FoldersTab extends StatelessWidget {
  final FavoriteProvider favProvider;
  final RecipeProvider recipeProvider;

  const _FoldersTab({required this.favProvider, required this.recipeProvider});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: () => _createFolder(context),
          icon: const Icon(Icons.create_new_folder_outlined),
          label: const Text('สร้างโฟลเดอร์ใหม่'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...favProvider.folders.map((folder) {
          final recipes = favProvider.recipesInFolder(folder.id, recipeProvider);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              leading: Text(folder.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(folder.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${recipes.length} เมนู'),
              children: recipes.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('ยังไม่มีสูตรในโฟลเดอร์นี้', style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    ]
                  : recipes.map((recipe) {
                      return ListTile(
                        title: Text(recipe.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share_outlined, size: 20),
                              onPressed: () {
                                final link = favProvider.shareRecipe(recipe);
                                Clipboard.setData(ClipboardData(text: link));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('คัดลอกลิงก์แล้ว: $link')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.download_outlined, size: 20),
                              onPressed: () {
                                final file = favProvider.downloadRecipe(recipe);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('ดาวน์โหลด (mock): $file')),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(recipe: recipe)),
                        ),
                      );
                    }).toList(),
            ),
          );
        }),
      ],
    );
  }

  void _createFolder(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('สร้างโฟลเดอร์'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'ชื่อโฟลเดอร์'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<FavoriteProvider>().createFolder(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('สร้าง'),
          ),
        ],
      ),
    );
  }
}
