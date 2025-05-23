import 'package:flutter/material.dart';
import 'package:intel_money/shared/helper/toast.dart';

import '../../../core/initialization/data_initializer.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/other/screens/other_screen.dart';
import '../../../features/reports/screens/report_screen.dart';
import '../../../features/transaction/screens/create_transaction_screen.dart';
import '../../../features/wallet/screens/wallet_screen.dart';
import 'main_layout.dart';

class AuthenticatedApp extends StatefulWidget {
  const AuthenticatedApp({super.key});

  @override
  State<AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<AuthenticatedApp> {
  Future<void> _loadData() async {
      await DataInitializer().loadAllData(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return MainLayout(
          screens: const [
            HomeScreen(),
            WalletScreen(),
            CreateTransactionScreen(),
            ReportScreen(),
            OtherScreen(),
          ]
        );
      }
    );
  }
}
