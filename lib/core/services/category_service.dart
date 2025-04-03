import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/network/api_client.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';

import '../state/app_state.dart';
import '../models/category.dart';

class CategoryService {
  final AppState _appState;
  final ApiClient _apiClient;

  CategoryService({required AppState appState, ApiClient? apiClient})
      : _appState = appState,
        _apiClient = apiClient ?? ApiClient.instance;

  Future<void> getCategories() async {
    final response = await _apiClient.get('/category');

    final categoriesData =
        response.map((category) => Category.fromJson(category)).toList();
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
      'type': type.name,
      'parentId': parentId,
    });

    final category = Category.fromJson(response);
    _appState.addCategory(category);
  }

  Future<void> updateCategory(
    int id,
    String name,
    String icon,
    CategoryType type, {
    int? parentId,
  }) async {
    await _apiClient.put('/category/$id', {
      'name': name,
      'icon': icon,
      'type': type,
      'parentId': parentId,
    });

    final category = Category(
      id: id,
      name: name,
      icon: icon,
      type: type,
      parentId: parentId ?? 0,
      editable: true,
    );
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
