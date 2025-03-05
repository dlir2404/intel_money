import 'package:flutter/material.dart';

import 'bottom_appbar.dart';

class MainLayout extends StatefulWidget {
  final List<Widget> screens;
  final void Function()? onAddPressed;

  const MainLayout({
    super.key,
    required this.screens,
    this.onAddPressed,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true, // Add this line to allow content to extend below the FAB
      body: IndexedStack(
        index: _selectedIndex,
        children: widget.screens,
      ),
      floatingActionButton: SizedBox(
        height: 56, // Set a fixed size for FAB
        width: 56,
        child: FloatingActionButton(
          onPressed: widget.onAddPressed,
          elevation: 4.0,
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomAppBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}