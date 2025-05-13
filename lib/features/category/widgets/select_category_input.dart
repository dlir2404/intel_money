import 'package:flutter/material.dart';

import '../../../core/models/category.dart';
import '../../../shared/const/enum/category_type.dart';
import '../../../shared/const/icons/category_icon.dart';
import '../controller/category_controller.dart';
import '../screens/select_category_screen.dart';

class SelectCategoryInput extends StatefulWidget {
  final String placeholder;
  final CategoryType categoryType;
  final Category? category;
  final Function(Category?) onCategorySelected;
  final bool? showChildren;

  const SelectCategoryInput({
    super.key,
    required this.categoryType,
    this.category,
    required this.onCategorySelected,
    this.placeholder = '',
    this.showChildren,
  });

  @override
  State<SelectCategoryInput> createState() => _SelectCategoryInputState();
}

class _SelectCategoryInputState extends State<SelectCategoryInput> {
  void _navigateToSelectParentCategory() async {
    if (widget.categoryType == CategoryType.lend ||
        widget.categoryType == CategoryType.borrow) {
      //do nothing
      return;
    }

    final selectedCategory = await Navigator.push<Category>(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectCategoryScreen(
              selectedCategory: widget.category,
              categoryType: widget.categoryType,
              showChildren: widget.showChildren ?? false,
            ),
      ),
    );

    if (selectedCategory != null) {
      widget.onCategorySelected(selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToSelectParentCategory,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    widget.category?.icon.color.withOpacity(0.15) ??
                    CategoryIcon.defaultIcon().color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.category?.icon.icon ?? CategoryIcon.defaultIcon().icon,
                color:
                    widget.category?.icon.color ??
                    CategoryIcon.defaultIcon().color,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.category?.name ?? widget.placeholder,
                style: TextStyle(
                  color: widget.category == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
