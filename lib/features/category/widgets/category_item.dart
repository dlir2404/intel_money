import 'package:flutter/material.dart';
import 'package:intel_money/features/category/controller/category_controller.dart';

import '../../../core/models/category.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final Function(Category) onCategoryTap;
  final bool isSelectable;

  const CategoryItem({
    Key? key,
    required this.category,
    required this.onCategoryTap,
    this.isSelectable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.transparent,
      highlightColor: CategoryController.getCategoryColor(
        category.icon,
      ).withOpacity(0.05),
      onTap: () => onCategoryTap(category),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CategoryController.getCategoryColor(
                    category.icon,
                  ).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CategoryController.getCategoryIcon(category.icon),
                  color: CategoryController.getCategoryColor(category.icon),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
