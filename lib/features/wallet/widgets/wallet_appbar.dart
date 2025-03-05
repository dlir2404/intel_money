// lib/features/wallet/widgets/wallet_appbar.dart
import 'package:flutter/material.dart';

class WalletAppbar extends StatefulWidget implements PreferredSizeWidget {
  const WalletAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<WalletAppbar> createState() => _WalletAppbarState();
}

class _WalletAppbarState extends State<WalletAppbar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      title: _isSearching
          ? TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(fontSize: 16),
        onSubmitted: (value) {
          // Handle search submission
        },
      )
          : const Text('Wallet'),
      centerTitle: !_isSearching,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          if (!_isSearching) {
            setState(() {
              _isSearching = true;
            });
          }
        },
      ),
      actions: [
        if (_isSearching)
          TextButton(
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Add filter functionality
            },
          ),
      ],
    );
  }
}