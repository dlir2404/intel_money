import 'package:flutter/material.dart';

import '../../../core/models/category.dart';
import '../../../features/category/screens/filter_category_screen.dart';
import '../../const/enum/category_type.dart';

class CategoriesFilter extends StatefulWidget {
  final List<Category>? selectedCategories;
  final CategoryType categoryType;
  final Function(List<Category>?) onSelectionChanged;

  const CategoriesFilter({
    super.key,
    required this.onSelectionChanged,
    this.selectedCategories,
    required this.categoryType,
  });

  @override
  State<CategoriesFilter> createState() => _CategoriesFilterState();
}

class _CategoriesFilterState extends State<CategoriesFilter> {
  List<Category>? _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = widget.selectedCategories;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final categories = await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => FilterCategoryScreen(
                  categoryType: widget.categoryType, // Pass null to use
                  selectedCategories:
                      _selectedCategories, // Pass null to use the default wallet state
                ),
          ),
        );

        widget.onSelectionChanged(categories);
        setState(() {
          _selectedCategories = categories;
        });
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.category, color: Colors.grey[400]),
            const SizedBox(width: 8),

            _selectedCategories == null
                ? Text('All categories', style: const TextStyle(fontSize: 16))
                : Text(
                  _selectedCategories!.isEmpty
                      ? 'No categories selected'
                      : _selectedCategories!.length > 1
                      ? '${_selectedCategories![0].name}, +${_selectedCategories!.length - 1} more'
                      : _selectedCategories![0].name,
                  style: const TextStyle(fontSize: 16),
                ),
            const SizedBox(width: 8),
            Expanded(child: const SizedBox()),

            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
