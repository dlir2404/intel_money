import 'package:flutter/material.dart';
import 'package:intel_money/features/wallet/screens/wallet_list_tab.dart';
import 'package:intel_money/features/wallet/widgets/wallet_appbar.dart';
import 'package:provider/provider.dart';

import '../../../core/config/routes.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/state/app_state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateWalletScreen() {
    AdService().showAdIfEligible();

    Navigator.of(context).pushNamed(AppRoutes.createWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const WalletAppbar(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'create_wallet',
            onPressed: () => _showCreateWalletScreen(),
            elevation: 4.0,
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add_card),
          ),

          const SizedBox(height: 76),
        ],
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
          ),

          const SizedBox(height: 80),
        ],
      )
    );
  }
}