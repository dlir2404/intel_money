import 'package:flutter/material.dart';
import 'package:intel_money/core/services/category_service.dart';
import 'package:intel_money/features/category/controller/category_controller.dart';
import 'package:intel_money/features/category/widgets/icon_picker.dart';
import 'package:provider/provider.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/models/category.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';

import '../../../core/services/ad_service.dart';
import '../../../shared/helper/toast.dart';
import 'select_category_screen.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  CategoryType _categoryType = CategoryType.expense;

  late final CategoryService _categoryService;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _parentCategoryController =
      TextEditingController();
  Category? _parentCategory;
  String _selectedIcon = 'category';

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showIconSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return IconPicker(
          iconOptions: CategoryController.iconOptions,
          selectedIcon: _selectedIcon,
          onItemTap: (iconName) {
            setState(() {
              _selectedIcon = iconName;
            });
          },
        );
      },
    );
  }

  void _navigateToSelectParentCategory() async {
    final selectedCategory = await Navigator.push<Category>(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectCategoryScreen(
              selectedCategory: _parentCategory,
              categoryType: _categoryType,
              showChildren: false,
            ),
      ),
    );

    if (selectedCategory != null) {
      setState(() {
        _parentCategory = selectedCategory;
        _parentCategoryController.text = selectedCategory.name;
      });
    }
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
        parentId: _parentCategory?.id,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        AppToast.showSuccess(context, "Category created successfully");

        AdService().showInterstitialAd();

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
            child:
                _isLoading
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
                            color: CategoryController.getIconColor(
                              _selectedIcon,
                            ).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CategoryController.getCategoryIcon(_selectedIcon),
                            color: CategoryController.getIconColor(
                              _selectedIcon,
                            ),
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
                const SizedBox(height: 10),
                const Text(
                  'Parent Category',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _navigateToSelectParentCategory,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _parentCategory?.name ?? 'Select Parent Category',
                          style: TextStyle(
                            color:
                                _parentCategory == null
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
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
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
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
