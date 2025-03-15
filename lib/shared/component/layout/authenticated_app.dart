import 'package:flutter/material.dart';
import 'package:intel_money/shared/helper/toast.dart';

import '../../../features/home/screens/home_screen.dart';
import '../../../features/other/screens/other_screen.dart';
import '../../../features/reports/screens/report_screen.dart';
import '../../../features/wallet/screens/wallet_screen.dart';
import 'main_layout.dart';

class AuthenticatedApp extends StatelessWidget {
  const AuthenticatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      screens: const [
        HomeScreen(),
        WalletScreen(),
        SizedBox(), // This won't be visible (placeholder for the + button)
        ReportScreen(),
        OtherScreen(),
      ],
      onAddPressed: () {
        // Handle the center plus button tap
        // Show a modal or navigate to add transaction screen
        AppToast.showSuccess(context, "Test message");
      },
    );
  }
}
