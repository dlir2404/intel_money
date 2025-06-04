import 'package:intel_money/core/models/extract_transaction_info_response.dart';

import '../../shared/const/enum/transaction_type.dart';
import '../models/message.dart';
import '../models/transaction.dart';
import '../network/api_client.dart';
import '../state/app_state.dart';
import '../state/statistic_state.dart';
import '../state/transaction_state.dart';
import '../state/wallet_state.dart';

class AIService {
  final ApiClient _apiClient = ApiClient.instance;
  final TransactionState _transactionState = TransactionState();
  final WalletState _walletState = WalletState();
  final AppState _appState = AppState();
  final StatisticState _statisticState = StatisticState();

  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  Future<ExtractTransactionInfoResponse> extractTransactionInfo(String text) async {
    final response = await _apiClient.post(
      '/ai/openai/extract-transaction-info',
      {'text': text},
    );

    final ExtractTransactionInfoResponse transactionInfo =
        ExtractTransactionInfoResponse.fromJson(response);

    return transactionInfo;
  }

  Future<Message> registerTransactionFromChat(String text) async {
    final response = await _apiClient.post(
      '/ai/openai/register-transaction-from-chat',
      {'text': text},
    );

    List<Transaction> transactions = [];
    if (response['transactions'] != null) {
      transactions = (response['transactions'] as List)
          .map((transaction) => Transaction.fromJson(transaction))
          .toList();
    }

    for (var transaction in transactions) {
      _transactionState.addTransaction(transaction);
      if (transaction.type == TransactionType.expense) {
        _appState.decreaseUserBalance(transaction.amount);
        _walletState.decreateWalletBalance(transaction.sourceWallet.id, transaction.amount);
        _statisticState.updateStatisticDataAfterCreateTransaction(transaction);
      } else if (transaction.type == TransactionType.income) {
        _appState.increaseUserBalance(transaction.amount);
        _walletState.increaseWalletBalance(transaction.sourceWallet.id, transaction.amount);
        _statisticState.updateStatisticDataAfterCreateTransaction(transaction);
      }
    }

    final Message message = Message.newAgentMessage(
      content: response['advice'],
      transactions: transactions
    );

    return message;
  }
}
