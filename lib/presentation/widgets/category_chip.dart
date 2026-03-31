import 'package:flutter/material.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';

class CategoryChip extends StatelessWidget {
  final FundCategory category;

  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isFpv = category == FundCategory.fpv;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isFpv
            ? const Color(0xFF1565C0).withValues(alpha: 0.1)
            : const Color(0xFF2E7D32).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFpv
              ? const Color(0xFF1565C0).withValues(alpha: 0.3)
              : const Color(0xFF2E7D32).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isFpv ? const Color(0xFF1565C0) : const Color(0xFF2E7D32),
        ),
      ),
    );
  }
}
