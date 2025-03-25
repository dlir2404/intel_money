import 'package:flutter/material.dart';
import 'package:intel_money/core/services/category_service.dart';
import 'package:provider/provider.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/types/category.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';

import '../../../shared/helper/toast.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({Key? key}) : super(key: key);

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late final CategoryService _categoryService;

  String _selectedIcon = 'category';
  CategoryType _categoryType = CategoryType.expense;
  int? _parentId;
  String _parentName = 'None';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'category', 'icon': Icons.category, 'label': 'General'},
    {'name': 'food', 'icon': Icons.restaurant, 'label': 'Food'},
    {'name': 'shopping', 'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'name': 'transport', 'icon': Icons.directions_car, 'label': 'Transport'},
    {'name': 'entertainment', 'icon': Icons.movie, 'label': 'Entertainment'},
    {'name': 'health', 'icon': Icons.medical_services, 'label': 'Health'},
    {'name': 'education', 'icon': Icons.school, 'label': 'Education'},
    {'name': 'bills', 'icon': Icons.receipt, 'label': 'Bills'},
    {'name': 'salary', 'icon': Icons.work, 'label': 'Salary'},
    {'name': 'investment', 'icon': Icons.trending_up, 'label': 'Investment'},
    {'name': 'wallet', 'icon': Icons.account_balance_wallet, 'label': 'Wallet'},
    {'name': 'savings', 'icon': Icons.savings, 'label': 'Savings'},
    {'name': 'card', 'icon': Icons.credit_card, 'label': 'Card'},
    {'name': 'exchange', 'icon': Icons.currency_exchange, 'label': 'Exchange'},
    {'name': 'money', 'icon': Icons.attach_money, 'label': 'Money'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _getIconColor(String iconName) {
    switch (iconName) {
      case 'food':
        return const Color(0xFFFF5252);
      case 'shopping':
        return const Color(0xFFFF9800);
      case 'transport':
        return const Color(0xFF42A5F5);
      case 'entertainment':
        return const Color(0xFF7C4DFF);
      case 'health':
        return const Color(0xFF26A69A);
      case 'education':
        return const Color(0xFF5C6BC0);
      case 'bills':
        return const Color(0xFFEC407A);
      case 'salary':
        return const Color(0xFF66BB6A);
      case 'investment':
        return const Color(0xFF8D6E63);
      case 'wallet':
        return const Color(0xFF5B6CF9);
      case 'savings':
        return const Color(0xFF4ECDC4);
      case 'card':
        return const Color(0xFF8E54E9);
      case 'exchange':
        return const Color(0xFFFF6B6B);
      case 'money':
        return const Color(0xFF01A3A4);
      default:
        return Theme.of(context).primaryColor;
    }
  }

  void _showIconSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Select Icon',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _iconOptions.length,
                  itemBuilder: (context, index) {
                    final iconData = _iconOptions[index];
                    final isSelected = _selectedIcon == iconData['name'];

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconData['name'];
                        });
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? _getIconColor(iconData['name'])
                                      : _getIconColor(
                                        iconData['name'],
                                      ).withOpacity(0.15),
                              shape: BoxShape.circle,
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: _getIconColor(iconData['name']),
                                        width: 2,
                                      )
                                      : null,
                            ),
                            child: Icon(
                              iconData['icon'],
                              color:
                                  isSelected
                                      ? Colors.white
                                      : _getIconColor(iconData['name']),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            iconData['label'],
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showParentSelectionBottomSheet() {
    final appState = Provider.of<AppState>(context, listen: false);
    final List<Category> parentCategories =
        appState.categories
            .where((cat) => cat.parentId == 0 && cat.type == _categoryType)
            .toList();

    if (parentCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No parent categories available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Select Parent Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: parentCategories.length + 1,
                  // +1 for "None" option
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // "None" option
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: const Text('None (Top-level category)'),
                        onTap: () {
                          setState(() {
                            _parentId = 0;
                            _parentName = 'None';
                          });
                          Navigator.pop(context);
                        },
                      );
                    }

                    final category = parentCategories[index - 1];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getIconColor(category.icon).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconOptions.firstWhere(
                            (element) => element['name'] == category.icon,
                            orElse: () => _iconOptions[0],
                          )['icon'],
                          color: _getIconColor(category.icon),
                        ),
                      ),
                      title: Text(category.name),
                      onTap: () {
                        setState(() {
                          _parentId = category.id;
                          _parentName = category.name;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _categoryService.createCategory(
        _nameController.text.trim(),
        _selectedIcon,
        _categoryType,
        parentId: _parentId,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        AppToast.showSuccess(context, "Category created successfully");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppToast.showError(context, error.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Get arguments if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        setState(() {
          // Set category type if provided (required)
          if (arguments.containsKey('categoryType')) {
            _categoryType = arguments['categoryType'] as CategoryType;
          }

          // Set parent category if provided
          if (arguments.containsKey('parentId') &&
              arguments.containsKey('parentName')) {
            _parentId = arguments['parentId'] as int;
            _parentName = arguments['parentName'] as String;
          }
        });
      }

      final appState = Provider.of<AppState>(context, listen: false);
      _categoryService = CategoryService(appState: appState);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Determine screen title based on category type
    final screenTitle =
        'Create ${_categoryType == CategoryType.income ? 'Income' : 'Expense'} Category';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          screenTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCategory,
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            )
                : const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon selection
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showIconSelectionBottomSheet,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _getIconColor(
                              _selectedIcon,
                            ).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _iconOptions.firstWhere(
                              (element) => element['name'] == _selectedIcon,
                              orElse: () => _iconOptions[0],
                            )['icon'],
                            color: _getIconColor(_selectedIcon),
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _showIconSelectionBottomSheet,
                        child: Text(
                          'Change Icon',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Category Name
                const Text(
                  'Category Name',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter category name',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                // Parent Category
                const Text(
                  'Parent Category',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showParentSelectionBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _parentName,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0,
                      ),
                    )
                        : const Text(
                      'Create Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
