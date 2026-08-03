import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recipe_provider.dart';
import '../../theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final String hint;
  final bool showHistory;
  final VoidCallback? onSubmitted;

  const SearchBarWidget({
    super.key,
    this.hint = 'ค้นหาเมนูหรือวัตถุดิบ',
    this.showHistory = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Autocomplete<String>(
            optionsBuilder: (textEditingValue) {
              provider.updateSearchQuery(textEditingValue.text);
              return provider.getAutocompleteSuggestions(textEditingValue.text);
            },
            onSelected: (selection) {
              provider.updateSearchQuery(selection);
              provider.addToSearchHistory(selection);
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: provider.updateSearchQuery,
                onSubmitted: (value) {
                  provider.addToSearchHistory(value);
                  onSubmitted?.call();
                },
                decoration: InputDecoration(
                  hintText: hint,
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
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: provider.clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              );
            },
          ),
        ),
        if (showHistory && provider.searchHistory.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ...provider.searchHistory.map(
                (h) => ActionChip(
                  label: Text(h, style: const TextStyle(fontSize: 12)),
                  avatar: const Icon(Icons.history, size: 16),
                  onPressed: () => provider.updateSearchQuery(h),
                ),
              ),
              ActionChip(
                label: const Text('ล้างประวัติ', style: TextStyle(fontSize: 12)),
                onPressed: provider.clearSearchHistory,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
