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