import 'package:intel_money/shared/const/enum/category_type.dart';

class Category{
  final int id;
  final String name;
  final String icon;
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

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      type: json['type'] == 'expense' ? CategoryType.expense : CategoryType.income,
      parentId: json['parentId'],
      editable: json['editable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type,
      'parentId': parentId,
      'editable': editable,
    };
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