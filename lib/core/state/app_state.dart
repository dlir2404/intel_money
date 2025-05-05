import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/models/user.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  //system config
  Currency? _currency = CurrencyService().findByCode("VND");
  Currency? get currency => _currency;
  void setCurrency(Currency? currency) {
    _currency = currency;
    notifyListeners();
  }

  User? _user;
  User? get user => _user;
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void decreaseUserBalance(double amount) {
    _user!.totalBalance -= amount;
    notifyListeners();
  }

  void increaseUserBalance(double amount) {
    _user!.totalBalance += amount;
    notifyListeners();
  }

  void decreaseUserTotalLoan(double amount) {
    _user!.totalLoan -= amount;
    notifyListeners();
  }

  void increaseUserTotalLoan(double amount) {
    _user!.totalLoan += amount;
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
