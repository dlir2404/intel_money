import 'package:flutter/material.dart';
import 'package:intel_money/core/services/category_service.dart';
import 'package:intel_money/core/state/category_state.dart';
import 'package:intel_money/features/category/controller/category_controller.dart';
import 'package:intel_money/features/category/widgets/icon_picker.dart';
import 'package:intel_money/features/category/widgets/select_category_input.dart';
import 'package:intel_money/shared/component/input/form_input.dart';
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
  Category category = CategoryState().categories[0];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  AppIcon _selectedIcon = CategoryIcon.defaultIcon();

  bool _isLoading = false;

  final CategoryController _categoryController = CategoryController();

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
        AppToast.showError(context, "Có lỗi xảy ra");
      }

      setState(() {
        category = arguments!['category'] as Category;
        _nameController.text = category.name;
        _selectedIcon = category.icon;
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
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        AppToast.showSuccess(context, "Đã lưu");

        AdService().showAdIfEligible();
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

  Future<void> _deleteCategory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc muốn xóa danh mục này? Tất cả giao dịch liên quan sẽ bị xóa. Không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _categoryController.deleteCategory(category);
        AppToast.showSuccess(context, "Đã xóa danh mục");
        Navigator.of(context).pop();
      } catch (error) {
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
          'Chỉnh sửa danh mục',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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
                      'Lưu',
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
                          'Đổi biểu tượng',
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
                  'Tên danh mục',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),

                FormInput(
                  controller: _nameController,
                  placeholder: 'Điền tên danh mục',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tên không được để trống';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteCategory(),
                        label:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.red,
                                    ),
                                    strokeWidth: 2.0,
                                  ),
                                )
                                : Text(
                                  "Xóa",
                                  style: TextStyle(color: Colors.red),
                                ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
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
                                  'Lưu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
