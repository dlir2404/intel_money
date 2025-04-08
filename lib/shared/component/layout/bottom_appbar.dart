import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kBottomNavigationBarHeight,
      child: BottomAppBar(
        padding: EdgeInsets.zero,
        notchMargin: 8.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(context, 1, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Wallet'),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(context, 3, Icons.bar_chart_outlined, Icons.bar_chart, 'Report'),
            _buildNavItem(context, 4, Icons.grid_view_outlined, Icons.grid_view, 'Other'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final isSelected = selectedIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? primaryColor : Colors.grey,
              size: 24,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}