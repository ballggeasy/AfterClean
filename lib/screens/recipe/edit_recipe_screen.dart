import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recipe.dart';
import '../../theme/app_theme.dart';
import '../../providers/recipe_provider.dart';

/// แก้ไขสูตรอาหาร (mock)
class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _tipsController;
  late TextEditingController _cookTimeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe.name);
    _tipsController = TextEditingController(text: widget.recipe.tips ?? '');
    _cookTimeController = TextEditingController(text: '${widget.recipe.cookTimeMinutes}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tipsController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขสูตร'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('บันทึก', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(widget.recipe.emoji, style: const TextStyle(fontSize: 48))),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'ชื่อเมนู'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cookTimeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'เวลาปรุง (นาที)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tipsController,
            decoration: const InputDecoration(labelText: 'เคล็ดลับ'),
          ),
        ],
      ),
    );
  }

  void _save() {
    final cookTime = int.tryParse(_cookTimeController.text) ?? widget.recipe.cookTimeMinutes;
    final updated = widget.recipe.copyWith(
      name: _nameController.text.trim(),
      cookTimeMinutes: cookTime,
      tips: _tipsController.text.trim().isEmpty ? null : _tipsController.text.trim(),
    );
    context.read<RecipeProvider>().updateRecipe(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('แก้ไขสูตรเรียบร้อย (mock)')),
    );
  }
}
