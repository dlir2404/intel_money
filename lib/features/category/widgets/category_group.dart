import 'package:flutter/material.dart';

import '../../../core/models/category.dart';
import '../controller/category_controller.dart';
import 'category_item.dart';

class CategoryGroup extends StatelessWidget {
  final Category category;
  final bool showChildren;
  final Function(Category)? onCategoryTap;
  final Function(Category) onChildrenTap;
  final Widget? trailing;
  final bool showLockIcon;

  const CategoryGroup({
    super.key,
    required this.category,
    this.showChildren = true,
    this.onCategoryTap,
    required this.onChildrenTap,
    this.trailing,
    this.showLockIcon = true,
  });

  Widget _buildParentCategory() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (onCategoryTap != null) {
          onCategoryTap!(category);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: category.icon.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon.icon,
                color: category.icon.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (!category.editable && showLockIcon)
              Icon(Icons.lock, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: category.children.length,
        itemBuilder: (context, index) {
          final child = category.children[index];
          return CategoryItem(category: child, onCategoryTap: onChildrenTap);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildParentCategory(),
          if (showChildren && category.children.isNotEmpty)
            _buildChildrenCategories(),
        ],
      ),
    );
  }
}
