import 'package:intel_money/shared/const/enum/category_type.dart';

import '../../shared/const/icons/category_icon.dart';
import '../state/app_state.dart';
import 'app_icon.dart';

class Category{
  final int id;
  final String name;
  final AppIcon icon;
  final CategoryType type;
  final int? parentId;
  final bool editable;
  final List<Category> children = [];

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.parentId,
    required this.editable,
  });

  factory Category.fromContext(int? id) {
    final List<Category> nestedCategories = AppState().categories;
    for (var i = 0; i < nestedCategories.length; i++) {
      if (nestedCategories[i].id == id) {
        return nestedCategories[i];
      } else {
        for (var j = 0; j < nestedCategories[i].children.length; j++) {
          if (nestedCategories[i].children[j].id == id) {
            return nestedCategories[i].children[j];
          }
        }
      }
    }

    //fallback to first category
    return AppState().expenseCategories[0];
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: CategoryIcon.getIcon(json['icon']),
      type: json['type'] == 'EXPENSE' ? CategoryType.expense : json['type'] == 'INCOME' ? CategoryType.income : CategoryType.expense,
      parentId: json['parentId'],
      editable: json['editable'] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.value,
      'parentId': parentId,
      'editable': editable,
    };
  }

  void addChildren(List<Category> categories) {
    clearChildren();
    for (var category in categories) {
      children.add(category);
    }
  }

  void addChild(Category category){
    children.add(category);
  }

  void removeChild(Category category){
    children.remove(category);
  }

  void clearChildren(){
    children.clear();
  }
}