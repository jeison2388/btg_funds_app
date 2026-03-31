import 'package:flutter/material.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';

class CategoryFilter extends StatelessWidget {
  final FundCategory? selectedCategory;
  final ValueChanged<FundCategory?> onCategoryChanged;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip(context, null, 'Todos'),
          const SizedBox(width: 8),
          ...FundCategory.values.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(context, cat, cat.label),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    FundCategory? category,
    String label,
  ) {
    final isSelected = selectedCategory == category;
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onCategoryChanged(category),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
