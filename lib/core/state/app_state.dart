import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/models/system_config.dart';
import 'package:intel_money/core/models/user.dart';
import 'package:intel_money/core/services/ad_service.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  List<String> _timezones = [];
  List<String> get timezones => _timezones;
  void setTimezones(List<String> tzs) {
    _timezones = tzs;
    notifyListeners();
  }

  String? _userTimezone;
  String? get userTimezone => _userTimezone;
  void setUserTimezone(String tz) {
    _userTimezone = tz;
    _user?.preferences.timezone = tz;
    notifyListeners();
  }

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

    AdService().setVipStatus(user.isVip);
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

  void decreaseUserTotalDebt(double amount) {
    _user!.totalDebt -= amount;
    notifyListeners();
  }

  void increaseUserTotalDebt(double amount) {
    _user!.totalDebt += amount;
    notifyListeners();
  }

  SystemConfig config = SystemConfig.defaultValue();
  void setSystemConfig(SystemConfig newConfig) {
    config = newConfig;
    AdService().setAdProbability(newConfig.adsConfig.adProbability);
    AdService().setMinTimeBetweenAds(newConfig.adsConfig.minTimeBetweenAds ~/ 60);
    notifyListeners();
  }


  void clear() {
    _user = null;
    notifyListeners();
  }
}
