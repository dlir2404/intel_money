import 'package:flutter/material.dart';
import 'package:intel_money/core/services/category_service.dart';
import 'package:intel_money/features/category/widgets/icon_picker.dart';
import 'package:intel_money/features/category/widgets/select_category_input.dart';
import 'package:intel_money/shared/component/input/form_input.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/models/category.dart';

import '../../../core/models/app_icon.dart';
import '../../../core/services/ad_service.dart';
import '../../../shared/const/icons/category_icon.dart';
import '../../../shared/helper/toast.dart';

class EditCategoryScreen extends StatefulWidget {
  const EditCategoryScreen({super.key});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  Category category = AppState().categories[0];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  Category? _parentCategory;
  AppIcon _selectedIcon = CategoryIcon.defaultIcon();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Get arguments if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments == null ||
          arguments.isEmpty ||
          !arguments.containsKey('category')) {
        AppToast.showError(context, "Error occur, no category selected");
      }

      setState(() {
        category = arguments!['category'] as Category;
        _nameController.text = category.name;
        _selectedIcon = category.icon;

        if (category.parentId != null && category.parentId != 0) {
          _parentCategory = Category.fromContext(category.parentId);
        }
      });
    });
  }

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
          icons: CategoryIcon.icons,
          selectedIcon: _selectedIcon,
          onItemTap: (icon) {
            setState(() {
              _selectedIcon = icon;
            });
          },
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
      await CategoryService().updateCategory(
        category,
        _nameController.text.trim(),
        _selectedIcon.name,
        category.type,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Category',
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
                            color: _selectedIcon.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _selectedIcon.icon,
                            color: _selectedIcon.color,
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
                            color: Theme.of(context).primaryColor,
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

                FormInput(
                  controller: _nameController,
                  placeholder: 'Enter category name',
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

                SelectCategoryInput(
                  category: _parentCategory,
                  placeholder: 'Select Parent Category',
                  categoryType: category.type,
                  onCategorySelected: (category) {
                    if (category != null) {
                      setState(() {
                        _parentCategory = category;
                      });
                    }
                  },
                ),
                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
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
                              'Save',
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
