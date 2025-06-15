import 'package:flutter/cupertino.dart';

import '../models/related_user.dart';

class RelatedUserState extends ChangeNotifier {
  static final RelatedUserState _instance = RelatedUserState._internal();
  factory RelatedUserState() => _instance;
  RelatedUserState._internal();

  List<RelatedUser> _relatedUsers = [];

  List<RelatedUser> get relatedUsers => _relatedUsers;

  void setRelatedUsers(List<RelatedUser> relatedUsers) {
    _relatedUsers = relatedUsers;
    notifyListeners();
  }

  void addRelatedUser(RelatedUser relatedUser) {
    _relatedUsers.add(relatedUser);
    notifyListeners();
  }

  void updateRelatedUser(RelatedUser relatedUser) {
    final index = _relatedUsers.indexWhere((element) => element.id == relatedUser.id);
    _relatedUsers[index].name = relatedUser.name;
    _relatedUsers[index].email = relatedUser.email;
    _relatedUsers[index].phone = relatedUser.phone;
    notifyListeners();
  }

  void removeRelatedUser(int id) {
    _relatedUsers.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void increaseRelatedUserTotalLoan(int id, double amount) {
    final index = _relatedUsers.indexWhere((element) => element.id == id);
    _relatedUsers[index].totalLoan += amount;
    notifyListeners();
  }

  void increaseRelatedUserTotalDebt(int id, double amount) {
    final index = _relatedUsers.indexWhere((element) => element.id == id);
    _relatedUsers[index].totalDebt += amount;
    notifyListeners();
  }

  void increaseRelatedUserTotalCollected(int id, double amount) {
    final index = _relatedUsers.indexWhere((element) => element.id == id);
    _relatedUsers[index].totalCollected += amount;
    notifyListeners();
  }

  void increaseRelatedUserTotalPaid(int id, double amount) {
    final index = _relatedUsers.indexWhere((element) => element.id == id);
    _relatedUsers[index].totalPaid += amount;
    notifyListeners();
  }

  void decreaseRelatedUserTotalLoan(int id, double amount) {
    final index = _relatedUsers.indexWhere((element) => element.id == id);
    _relatedUsers[index].totalLoan -= amount;
    notifyListeners();
  }

  void decreaseRelatedUserTotalDebt(int id, double amount) {
    final index = _relatedUsers.indexWhere((element) => element.id == id);
    _relatedUsers[index].totalDebt -= amount;
    notifyListeners();
  }

  void decreaseRelatedUserTotalCollected(int id, double amount) {
    final index = _relatedUsers.indexWhere((element) => element.id == id);
    _relatedUsers[index].totalCollected -= amount;
    notifyListeners();
  }

  void decreaseRelatedUserTotalPaid(int id, double amount) {
    final index = _relatedUsers.indexWhere((element) => element.id == id);
    _relatedUsers[index].totalPaid -= amount;
    notifyListeners();
  }
}