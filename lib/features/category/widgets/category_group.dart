import 'package:flutter/material.dart';

import '../../../core/models/category.dart';
import '../controller/category_controller.dart';
import 'category_item.dart';

class CategoryGroup extends StatelessWidget {
  final Category parent;
  final List<Category> children;
  final Function(Category) onCategoryTap;
  final Function(Category)? onParentTap;
  final bool isSelectable;

  const CategoryGroup({
    Key? key,
    required this.parent,
    required this.children,
    required this.onCategoryTap,
    this.onParentTap,
    this.isSelectable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If there are no children, use a regular Container instead of ExpansionTile
    if (children.isEmpty) {
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (parent.editable && onParentTap != null) {
                onParentTap!(parent);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CategoryController.getCategoryColor(parent.icon).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CategoryController.getCategoryIcon(parent.icon),
                      color: CategoryController.getCategoryColor(parent.icon),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      parent.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (!parent.editable)
                    Icon(Icons.lock, color: Colors.grey[400], size: 20),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Use ExpansionTile when there are subcategories
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ExpansionTile(
            initiallyExpanded: true,
            maintainState: true,
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CategoryController.getCategoryColor(parent.icon).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CategoryController.getCategoryIcon(parent.icon),
                    color: CategoryController.getCategoryColor(parent.icon),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  parent.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            trailing: parent.editable
                ? null
                : Icon(Icons.lock, color: Colors.grey[400], size: 20),
            children: [
              Padding(
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
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return CategoryItem(
                      category: child,
                      onCategoryTap: onCategoryTap,
                      isSelectable: isSelectable,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}