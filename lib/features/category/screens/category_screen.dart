import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/types/category.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";

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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
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
          // Search field - Only show when needed, no extra space when hidden
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

          // Tab bar - Styled exactly like WalletScreen
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Expense categories
                _buildCategoryList(appState.categories.where((cat) =>
                  cat.type == CategoryType.expense).toList()),

                // Income categories
                _buildCategoryList(appState.categories.where((cat) =>
                  cat.type == CategoryType.income).toList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: SizedBox(
          height: 56,
          width: 56,
          child: FloatingActionButton(
            heroTag: 'create_category',
            onPressed: () {
              // Navigate to create category screen
            },
            elevation: 4.0,
            shape: const CircleBorder(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    // Filter categories based on search query
    if (_searchQuery.isNotEmpty) {
      categories = categories.where((category) =>
          category.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Separate parent and child categories
    final parentCategories = categories.where((cat) => cat.parentId == 0).toList();

    return parentCategories.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: parentCategories.length,
      itemBuilder: (context, index) {
        final parent = parentCategories[index];
        final childCategories = categories.where((cat) => cat.parentId == parent.id).toList();

        return _buildCategoryGroup(parent, childCategories);
      },
    );
  }

  Widget _buildCategoryGroup(Category parent, List<Category> children) {
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
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getCategoryColor(parent.icon).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(parent.icon),
                color: _getCategoryColor(parent.icon),
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parent.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: parent.editable ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey[600], size: 20),
              onPressed: () {
                // Edit category
              },
            ),
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.grey[700],
              ),
            ),
          ],
        ) : Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
        children: [
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'No subcategories',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(child.icon).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(child.icon),
                      color: _getCategoryColor(child.icon),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    child.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  trailing: child.editable ? IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey[500], size: 18),
                    onPressed: () {
                      // Edit subcategory
                    },
                  ) : null,
                  onTap: () {
                    // View category details
                  },
                );
              },
            ),
          if (parent.editable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add subcategory'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  // Add subcategory
                },
              ),
            ),
        ],
      ),
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
            child: Icon(
              Icons.category,
              size: 60,
              color: primaryColor,
            ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.white,),
            label: const Text('Add Category'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              // Navigate to create category screen
            },
          ),
        ],
      ),
    );
  }

  // Helper methods for category icons and colors
  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'food': return Icons.restaurant;
      case 'shopping': return Icons.shopping_bag;
      case 'transport': return Icons.directions_car;
      case 'entertainment': return Icons.movie;
      case 'health': return Icons.medical_services;
      case 'education': return Icons.school;
      case 'bills': return Icons.receipt;
      case 'salary': return Icons.work;
      case 'investment': return Icons.trending_up;
      case 'wallet': return Icons.account_balance_wallet;
      case 'savings': return Icons.savings;
      case 'card': return Icons.credit_card;
      case 'exchange': return Icons.currency_exchange;
      case 'money': return Icons.attach_money;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(String iconName) {
    // Using the icon name to determine color for visual consistency
    switch (iconName) {
      case 'food': return Color(0xFFFF5252);
      case 'shopping': return Color(0xFFFF9800);
      case 'transport': return Color(0xFF42A5F5);
      case 'entertainment': return Color(0xFF7C4DFF);
      case 'health': return Color(0xFF26A69A);
      case 'education': return Color(0xFF5C6BC0);
      case 'bills': return Color(0xFFEC407A);
      case 'salary': return Color(0xFF66BB6A);
      case 'investment': return Color(0xFF8D6E63);
      case 'wallet': return Color(0xFF5B6CF9);
      case 'savings': return Color(0xFF4ECDC4);
      case 'card': return Color(0xFF8E54E9);
      case 'exchange': return Color(0xFFFF6B6B);
      case 'money': return Color(0xFF01A3A4);
      default: return Theme.of(context).primaryColor;
    }
  }
}