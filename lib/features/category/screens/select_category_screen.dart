import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/icons/icon_selected.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';
import 'package:provider/provider.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/category.dart';
import '../widgets/category_group.dart';

class SelectCategoryScreen extends StatefulWidget {
  final Category? selectedCategory;
  final CategoryType categoryType;
  final bool showChildren;

  const SelectCategoryScreen({
    super.key,
    required this.categoryType,
    this.selectedCategory,
    this.showChildren = false,
  });

  @override
  _SelectCategoryScreenState createState() =>
      _SelectCategoryScreenState();
}

class _SelectCategoryScreenState
    extends State<SelectCategoryScreen> {
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Parent Category'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final parentCategories =
              widget.categoryType == CategoryType.expense
                  ? appState.expenseCategories
                  : appState.incomeCategories;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: parentCategories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
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
                  child: ListTile(
                    title: const Text('(No item selected)'),
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                      Navigator.pop(context, null);
                    },
                    trailing: _selectedCategory == null ? IconSelected() : null,
                  ),
                );
              }
              final category = parentCategories[index - 1];
              return CategoryGroup(
                category: category,
                showChildren: widget.showChildren,
                onCategoryTap: (parent) {
                  setState(() {
                    _selectedCategory = parent;
                  });
                  Navigator.pop(context, parent);
                },
                onChildrenTap: (category) {},
                trailing: _selectedCategory == category ? IconSelected() : null,
              );
            },
          );
        },
      ),
    );
  }
}
