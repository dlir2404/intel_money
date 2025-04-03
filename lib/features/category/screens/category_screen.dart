import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intel_money/core/config/routes.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_state.dart';
import '../widgets/category_group.dart';
import 'category_list_tab.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreateCategory() {
    Navigator.pushNamed(
      context,
      AppRoutes.createCategory,
      arguments: {
        'categoryType': _tabController.index == 0
            ? CategoryType.expense
            : CategoryType.income,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.search_off : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search field
          if (_isSearching)
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ),
              ),
            ),

          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [Tab(text: 'Expense'), Tab(text: 'Income')],
          ),

          // Tab content with real data from AppState
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Filtered view wrapper for expense categories
                _isSearching && _searchQuery.isNotEmpty
                    ? _buildFilteredView(CategoryType.expense)
                    : const CategoryListTab(categoryType: CategoryType.expense),

                // Filtered view wrapper for income categories
                _isSearching && _searchQuery.isNotEmpty
                    ? _buildFilteredView(CategoryType.income)
                    : const CategoryListTab(categoryType: CategoryType.income),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          heroTag: 'create_category',
          onPressed: _navigateToCreateCategory,
          elevation: 4.0,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilteredView(CategoryType type) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final categories = type == CategoryType.expense
            ? appState.expenseCategories
            : appState.incomeCategories;

        final filteredCategories = categories
            .where((category) => category.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        if (filteredCategories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No matches found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Separate parent and child categories
        final parentCategories = filteredCategories
            .where((cat) => cat.parentId == 0 || cat.parentId == null)
            .toList();

        // For search results, also include parent categories of matching children
        final childCategories = filteredCategories
            .where((cat) => cat.parentId != 0 && cat.parentId != null)
            .toList();

        // Add parents of matching children if they're not already included
        for (final child in childCategories) {
          if (!parentCategories.any((parent) => parent.id == child.parentId)) {
            final parent = categories
                .firstWhere((cat) => cat.id == child.parentId, orElse: () => child);
            parentCategories.add(parent);
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: parentCategories.length,
          itemBuilder: (context, index) {
            final parent = parentCategories[index];
            final matchingChildren = categories
                .where((cat) => cat.parentId == parent.id)
                .where((cat) => cat.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

            return CategoryGroup(
              parent: parent,
              children: matchingChildren,
              onCategoryTap: (category) {
                if (category.editable) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.createCategory,
                    arguments: {'category': category},
                  );
                }
              },
              onParentTap: (parent) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.createCategory,
                  arguments: {'category': parent},
                );
              },
            );
          },
        );
      },
    );
  }
}
