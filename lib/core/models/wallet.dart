import 'package:intel_money/shared/const/icons/wallet_icon.dart';
import '../state/wallet_state.dart';
import 'app_icon.dart';

class Wallet {
  int id;
  String name;
  String? description;
  AppIcon icon;
  double balance;
  double baseBalance;

  Wallet({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.balance,
    required this.baseBalance,
  });


  factory Wallet.fromContext(int? id) {
    return WalletState().wallets.firstWhere((wallet) => wallet.id == id);
  }


  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: WalletIcon.getIcon(json['icon']),
      balance: double.parse(json['balance'].toString()),
      baseBalance: double.parse(json['baseBalance'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'balance': balance,
      'baseBalance': baseBalance,
    };
  }

  Wallet copyWith({
    int? id,
    String? name,
    String? description,
    AppIcon? icon,
    double? balance,
    double? baseBalance,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      balance: balance ?? this.balance,
      baseBalance: baseBalance ?? this.baseBalance,
    );
  }
}