import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/network/api_client.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';

import '../../shared/const/icons/category_icon.dart';
import '../state/app_state.dart';
import '../models/category.dart';

class CategoryService {
  final AppState _appState = AppState();
  final ApiClient _apiClient = ApiClient.instance;

  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  Future<void> getCategories() async {
    final response = await _apiClient.get('/category');

    final List<Category> categoriesData = (response as List)
        .map((category) => Category.fromJson(category as Map<String, dynamic>))
        .toList();

    final categories = handleCategories(categoriesData);
    _appState.setCategories(categories);
  }

  Future<void> createCategory(
    String name,
    String icon,
    CategoryType type, {
    int? parentId,
  }) async {
    final response = await _apiClient.post('/category', {
      'name': name,
      'icon': icon,
      'type': type.value,
      'parentId': parentId,
    });

    final category = Category.fromJson(response);
    _appState.addCategory(category);
  }

  Future<void> updateCategory(
    Category oldCategory,
    String name,
    String icon,
    CategoryType type, {
    int? parentId,
  }) async {
    await _apiClient.put('/category/${oldCategory.id}', {
      'name': name,
      'icon': icon,
      'parentId': parentId,
    });

    final category = Category(
      id: oldCategory.id,
      name: name,
      icon: CategoryIcon.getIcon(icon),
      type: type,
      parentId: parentId ?? 0,
      editable: true,
    );

    if (oldCategory.children.isNotEmpty){
      category.addChildren(oldCategory.children);
    }
    _appState.updateCategory(category);
  }

  Future<void> deleteCategory(int id) async {
    await _apiClient.delete('/category/$id');
    _appState.removeCategory(id);
  }

  List<Category> handleCategories(List<Category> categories) {
    final List<Category> result = [];
    for (final category in categories) {
      if (category.parentId == null) {
        result.add(category);
      } else {
        final parent = result.firstWhere(
          (element) => element.id == category.parentId,
        );
        parent.addChild(category);
      }
    }
    return result;
  }
}
