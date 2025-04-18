import 'package:flutter/material.dart';
import 'package:intel_money/core/services/category_service.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/models/category.dart';
import 'package:provider/provider.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';

import '../../../core/config/routes.dart';
import '../widgets/category_group.dart';

class CategoryListTab extends StatelessWidget {
  final CategoryType categoryType;

  const CategoryListTab({Key? key, required this.categoryType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final categories = categoryType == CategoryType.expense
            ? appState.expenseCategories
            : appState.incomeCategories;

        return RefreshIndicator(
          onRefresh: () async {
            final appState = Provider.of<AppState>(context, listen: false);
            final categoryService = CategoryService(appState: appState);
            await categoryService.getCategories();
          },
          child: categories.isEmpty
              ? _buildEmptyState(context)
              : _buildCategoryList(context, categories),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.category, size: 60, color: primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                'No Categories Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to create your first category',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => _navigateToCreateCategory(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context, List<Category> categories) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final parent = categories[index];

        return CategoryGroup(
          category: parent,
          showChildren: true,
          onCategoryTap: (parent) {
            _navigateToEditCategory(context, parent);
          },
          onChildrenTap: (category) {
            if (category.editable) {
              _navigateToEditCategory(context, category);
            }
          },
        );
      },
    );
  }

  void _navigateToCreateCategory(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.createCategory,
      arguments: {'categoryType': categoryType},
    );
  }

  void _navigateToEditCategory(BuildContext context, Category category) {
    Navigator.pushNamed(
      context,
      AppRoutes.createCategory,
      arguments: {'category': category},
    );
  }
}