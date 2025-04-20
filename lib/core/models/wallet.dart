import 'package:intel_money/shared/const/icons/wallet_icon.dart';

import '../state/app_state.dart';
import 'app_icon.dart';

class Wallet {
  int id;
  String name;
  String? description;
  AppIcon icon;
  double balance;

  Wallet({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.balance
  });


  factory Wallet.fromContext(int? id) {
    return AppState().wallets.firstWhere((wallet) => wallet.id == id);
  }


  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: WalletIcon.getIcon(json['icon']),
      balance: double.parse(json['balance'].toString())
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'balance': balance
    };
  }
}