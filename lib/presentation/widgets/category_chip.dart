import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/category.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = category.id == 'all' || category.id == 'uncategorized'
        ? AppColors.primary
        : Color(category.colorValue);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? catColor.withOpacity(0.18)
                  : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? catColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? catColor
                        : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
