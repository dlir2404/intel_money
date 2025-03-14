import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intel_money/core/network/api_client.dart';
import 'package:intel_money/features/auth/login/login_view.dart';
import 'package:intel_money/features/auth/register/register_view.dart';
// Import your screens
import 'package:intel_money/shared/component/layout/main_layout.dart';

import 'core/config/flavor_config.dart';
import 'features/home/screens/home_screen.dart';
import 'features/other/screens/other_screen.dart';
import 'features/reports/screens/report_screen.dart';
import 'features/wallet/screens/wallet_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.dev');

  //Initialize flavor configuration
  FlavorConfig(
    flavor: Flavor.dev,
    name: 'DEV',
    apiBaseUrl: dotenv.env['API_URL'] ?? 'https://dev-api.intel-money.com',
  );

  //initialize the API client
  ApiClient.initialize(baseUrl: FlavorConfig.instance.apiBaseUrl);

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
      // home: RegisterView()
    );
  }
}