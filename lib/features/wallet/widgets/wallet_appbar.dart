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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      title: const Text('Ví'),
      centerTitle: true,
      elevation: 0,
    );
  }
}