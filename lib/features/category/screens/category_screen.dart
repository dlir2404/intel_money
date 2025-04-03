import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intel_money/core/config/routes.dart';
import 'package:provider/provider.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/models/category.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';

import '../widgets/category_group.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";

  // Mock categories for testing
  final List<Category> _mockCategories = [
    Category(
      id: 1,
      name: 'Food & Dining',
      icon: 'food',
      type: CategoryType.expense,
      parentId: 0,
      editable: true,
    ),
    Category(
      id: 2,
      name: 'Groceries',
      icon: 'shopping',
      type: CategoryType.expense,
      parentId: 1,
      editable: true,
    ),
    Category(
      id: 3,
      name: 'Restaurants',
      icon: 'food',
      type: CategoryType.expense,
      parentId: 1,
      editable: true,
    ),
    Category(
      id: 4,
      name: 'Transportation',
      icon: 'transport',
      type: CategoryType.expense,
      parentId: 0,
      editable: true,
    ),
    Category(
      id: 5,
      name: 'Income',
      icon: 'salary',
      type: CategoryType.income,
      parentId: 0,
      editable: true,
    ),
    Category(
      id: 6,
      name: 'Salary',
      icon: 'money',
      type: CategoryType.income,
      parentId: 5,
      editable: true,
    ),
  ];

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
        'categoryType':
            _tabController.index == 0
                ? CategoryType.expense
                : CategoryType.income,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Set system UI for proper ad display
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
          // Search field - Only show when needed
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

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Expense categories - Using mock data
                _buildCategoryList(
                  _mockCategories
                      .where((cat) => cat.type == CategoryType.expense)
                      .toList(),
                ),

                // Income categories - Using mock data
                _buildCategoryList(
                  _mockCategories
                      .where((cat) => cat.type == CategoryType.income)
                      .toList(),
                ),
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

  Widget _buildCategoryList(List<Category> categories) {
    // Filter categories based on search query
    if (_searchQuery.isNotEmpty) {
      categories =
          categories
              .where(
                (category) => category.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    // Separate parent and child categories
    final parentCategories =
        categories.where((cat) => cat.parentId == 0).toList();

    return parentCategories.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: parentCategories.length,
          itemBuilder: (context, index) {
            final parent = parentCategories[index];
            final childCategories =
                categories.where((cat) => cat.parentId == parent.id).toList();

            return CategoryGroup(
              parent: parent,
              children: childCategories,
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
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Center(
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
          const SizedBox(height: 20),
          Text(
            'No Categories Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Add categories to organize your transactions',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            onPressed: _navigateToCreateCategory,
          ),
        ],
      ),
    );
  }
}
