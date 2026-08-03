import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool filled;

  const FilterChipWidget({
    super.key,
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
