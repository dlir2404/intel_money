import 'package:flutter/material.dart';
import 'package:intel_money/features/wallet/screens/wallet_list_tab.dart';
import 'package:intel_money/features/wallet/widgets/wallet_appbar.dart';
import 'package:provider/provider.dart';

import '../../../core/config/routes.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/state/app_state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late WalletService _walletService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      _walletService = WalletService(appState: appState);
      _loadWallets();
    });
  }

  Future<void> _loadWallets() async {
    try {
      await _walletService.getWallets();
    } catch (e) {
      // Handle error (you might want to show a snackbar or dialog)
      debugPrint('Error fetching wallets: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateWalletScreen() {
    Navigator.of(context).pushNamed(AppRoutes.createWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const WalletAppbar(),
        floatingActionButton: SizedBox(
          height: 56, // Set a fixed size for FAB
          width: 56,
          child: FloatingActionButton(
            onPressed: () => _showCreateWalletScreen(),
            elevation: 4.0,
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add_card),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'Wallet'),
                Tab(text: 'Savings'),
                Tab(text: 'Accumulate'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  WalletListTab(),
                  Center(child: Text('Savings')),
                  Center(child: Text('Accumulate')),
                ],
              ),
            )
          ],
        )
      ),
    );
  }
}