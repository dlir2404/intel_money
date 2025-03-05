import 'package:flutter/material.dart';
// Import your screens
import 'package:intel_money/shared/component/layout/main_layout.dart';

import 'features/home/screens/home_screen.dart';
import 'features/other/screens/other_screen.dart';
import 'features/reports/screens/report_screen.dart';
import 'features/wallet/screens/wallet_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intel Money',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MainLayout(
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
        },
      ),
    );
  }
}