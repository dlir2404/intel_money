import 'package:flutter/material.dart';

import '../../../core/models/category.dart';

class CategoriesFilter extends StatefulWidget {
  final Function(List<Category>)? onChanged;
  const CategoriesFilter({super.key, this.onChanged});

  @override
  State<CategoriesFilter> createState() => _CategoriesFilterState();
}

class _CategoriesFilterState extends State<CategoriesFilter> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.category, color: Colors.grey[400]),
            const SizedBox(width: 8),

            Text(
              'All categories',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Expanded(child: const SizedBox()),

            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
