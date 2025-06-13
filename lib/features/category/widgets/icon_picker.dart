import 'package:flutter/material.dart';

import '../../../core/models/app_icon.dart';
import '../../../shared/const/icons/category_icon.dart';
import '../controller/category_controller.dart';

class IconPicker extends StatelessWidget {
  final List<AppIcon> icons;
  final AppIcon? selectedIcon;
  final Function(AppIcon icon) onItemTap;

  const IconPicker({
    super.key,
    required this.icons,
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
              'Chọn biểu tượng',
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
              itemCount: icons.length,
              itemBuilder: (context, index) {
                final icon = icons[index];
                final isSelected = selectedIcon == icon;

                return InkWell(
                  onTap: () {
                    onItemTap(icon);
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
                                  ? icon.color
                                  : icon.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border:
                              isSelected
                                  ? Border.all(
                                    color: CategoryController.getIconColor(
                                      icon.name,
                                    ),
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: Icon(
                          icon.icon,
                          color:
                              isSelected
                                  ? Colors.white
                                  : CategoryController.getIconColor(
                                    icon.name,
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
