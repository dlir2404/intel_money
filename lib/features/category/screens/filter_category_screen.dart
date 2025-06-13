import 'package:flutter/material.dart';
import 'package:intel_money/core/state/category_state.dart';
import 'package:provider/provider.dart';

import '../../../core/models/category.dart';
import '../../../shared/component/filters/list_item_filter.dart';
import '../../../shared/const/enum/category_type.dart';

class FilterCategoryScreen extends StatefulWidget {
  final List<Category>? selectedCategories;
  final CategoryType categoryType;
  const FilterCategoryScreen({super.key, this.selectedCategories, required this.categoryType});

  @override
  State<FilterCategoryScreen> createState() => _FilterCategoryScreenState();
}

class _FilterCategoryScreenState extends State<FilterCategoryScreen> {
  List<Category>? _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = widget.selectedCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn danh mục'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(_selectedCategories);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<CategoryState>(
              builder: (context, state, _) {
                final allCategories = widget.categoryType == CategoryType.expense
                    ? state.expenseCategories
                    : state.incomeCategories;

                final flatCategories = [
                  ...allCategories, // Include all parent categories
                  ...allCategories.expand((category) => category.children) // Include all children
                ];

                return ListItemFilter(
                  items: flatCategories,
                  selectedItems: widget.selectedCategories,
                  getItemName: (item) => item.name,
                  onSelectionChanged: (selectedItems) {
                    setState(() {
                      _selectedCategories = selectedItems;
                    });
                  },
                  itemBuilder: (context, item, isSelected) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical:  8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.icon.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(item.icon.icon, color: item.icon.color, size: 24),
                          ),
                          const SizedBox(width: 16),

                          // Wallet Name
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedCategories);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xác nhận'),
            ),
          ),
        ],
      ),
    );
  }
}
