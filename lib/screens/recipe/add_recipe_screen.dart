import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recipe.dart';
import '../../models/ingredient.dart';
import '../../theme/app_theme.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/recipe_data.dart';
import '../../utils/constants.dart';

/// เพิ่มสูตรอาหารใหม่ (mock — เก็บใน memory)
class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController(text: '🍽️');
  final _tipsController = TextEditingController();
  final _platingController = TextEditingController();
  final _stepsController = TextEditingController();

  String _category = RecipeData.categories.length > 1 ? RecipeData.categories[1] : 'อาหารจานเดียว';
  String _country = RecipeData.countries.length > 1 ? RecipeData.countries[1] : 'ไทย';
  String _difficulty = 'ง่าย';
  int _prepTime = 10;
  int _cookTime = 20;
  int _servings = 2;
  final List<String> _selectedDietTags = [];

  final List<IngredientItem> _ingredients = [
    const IngredientItem(name: '', amount: '', unit: 'กรัม'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _tipsController.dispose();
    _platingController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มสูตรอาหาร')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _PlaceholderImage(),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'ชื่อเมนู *'),
              validator: (v) => v?.trim().isEmpty == true ? 'กรุณากรอกชื่อเมนู' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emojiController,
              decoration: const InputDecoration(labelText: 'Emoji (placeholder รูป)'),
            ),
            const SizedBox(height: 12),
            _Dropdown('ประเภท', _category, RecipeData.categories.where((c) => c != 'ทั้งหมด').toList(),
                (v) => setState(() => _category = v!)),
            _Dropdown('ประเทศ', _country, RecipeData.countries.where((c) => c != 'ทั้งหมด').toList(),
                (v) => setState(() => _country = v!)),
            _Dropdown('ความยาก', _difficulty, AppConstants.difficulties,
                (v) => setState(() => _difficulty = v!)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _NumberField('เตรียม (นาที)', _prepTime, (v) => _prepTime = v)),
                const SizedBox(width: 12),
                Expanded(child: _NumberField('ปรุง (นาที)', _cookTime, (v) => _cookTime = v)),
                const SizedBox(width: 12),
                Expanded(child: _NumberField('เสิร์ฟ', _servings, (v) => _servings = v)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('แท็กอาหาร', style: TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              children: AppConstants.dietTags.map((tag) {
                final selected = _selectedDietTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (s) => setState(() {
                    if (s) {
                      _selectedDietTags.add(tag);
                    } else {
                      _selectedDietTags.remove(tag);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('วัตถุดิบ', style: TextStyle(fontWeight: FontWeight.w600)),
            ..._ingredients.asMap().entries.map((e) => _IngredientRow(
                  index: e.key,
                  item: e.value,
                  onChanged: (item) => setState(() => _ingredients[e.key] = item),
                  onRemove: _ingredients.length > 1
                      ? () => setState(() => _ingredients.removeAt(e.key))
                      : null,
                )),
            TextButton.icon(
              onPressed: () => setState(() => _ingredients.add(
                    const IngredientItem(name: '', amount: '', unit: 'กรัม'),
                  )),
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มวัตถุดิบ'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stepsController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'ขั้นตอน (แยกบรรทัด) *',
                alignLabelWithHint: true,
              ),
              validator: (v) => v?.trim().isEmpty == true ? 'กรุณากรอกขั้นตอน' : null,
            ),
            TextFormField(
              controller: _tipsController,
              decoration: const InputDecoration(labelText: 'เคล็ดลับ'),
            ),
            TextFormField(
              controller: _platingController,
              decoration: const InputDecoration(labelText: 'วิธีจัดจาน'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('บันทึกสูตร'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RecipeProvider>();
    final auth = context.read<AuthProvider>();
    final steps = _stepsController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
    final items = _ingredients.where((i) => i.name.trim().isNotEmpty).toList();

    final recipe = provider.buildRecipeFromForm(
      id: provider.generateId(),
      name: _nameController.text.trim(),
      emoji: _emojiController.text.trim().isEmpty ? '🍽️' : _emojiController.text.trim(),
      category: _category,
      country: _country,
      prepTime: _prepTime,
      cookTime: _cookTime,
      difficulty: _difficulty,
      servings: _servings,
      steps: steps,
      items: items,
      tips: _tipsController.text.trim().isEmpty ? null : _tipsController.text.trim(),
      platingTips: _platingController.text.trim().isEmpty ? null : _platingController.text.trim(),
      dietTags: _selectedDietTags,
      isOfficial: false,
      uploaderName: auth.currentUser?.name ?? 'ผู้เยี่ยมชม',
    );

    provider.addRecipe(recipe);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('เพิ่มสูตรเรียบร้อย (mock)')),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppTheme.primary),
            SizedBox(height: 8),
            Text('Placeholder รูปภาพ', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown(this.label, this.value, this.items, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumberField(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: '$value',
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) => onChanged(int.tryParse(v) ?? value),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final int index;
  final IngredientItem item;
  final ValueChanged<IngredientItem> onChanged;
  final VoidCallback? onRemove;

  const _IngredientRow({
    required this.index,
    required this.item,
    required this.onChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: item.amount,
              decoration: const InputDecoration(hintText: 'ปริมาณ', isDense: true),
              onChanged: (v) => onChanged(IngredientItem(name: item.name, amount: v, unit: item.unit)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              initialValue: item.unit,
              decoration: const InputDecoration(hintText: 'หน่วย', isDense: true),
              onChanged: (v) => onChanged(IngredientItem(name: item.name, amount: item.amount, unit: v)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: item.name,
              decoration: InputDecoration(hintText: 'วัตถุดิบ ${index + 1}', isDense: true),
              onChanged: (v) => onChanged(IngredientItem(name: v, amount: item.amount, unit: item.unit)),
            ),
          ),
          if (onRemove != null)
            IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: onRemove),
        ],
      ),
    );
  }
}
