import 'package:flutter/material.dart';

import '../controller/category_controller.dart';

class IconPicker extends StatelessWidget {
  final List<Map<String, dynamic>> iconOptions;
  final String? selectedIcon;
  final Function(String) onItemTap;

  const IconPicker({
    super.key,
    required this.iconOptions,
    this.selectedIcon,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
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
              itemCount: iconOptions.length,
              itemBuilder: (context, index) {
                final iconData = iconOptions[index];
                final isSelected = selectedIcon == iconData['name'];

                return InkWell(
                  onTap: () {
                    onItemTap(iconData['name']);
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
                                  ? CategoryController.getIconColor(
                                    iconData['name'],
                                  )
                                  : CategoryController.getIconColor(
                                    iconData['name'],
                                  ).withOpacity(0.15),
                          shape: BoxShape.circle,
                          border:
                              isSelected
                                  ? Border.all(
                                    color: CategoryController.getIconColor(
                                      iconData['name'],
                                    ),
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: Icon(
                          iconData['icon'],
                          color:
                              isSelected
                                  ? Colors.white
                                  : CategoryController.getIconColor(
                                    iconData['name'],
                                  ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
