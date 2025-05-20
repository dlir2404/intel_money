import 'package:intel_money/core/models/extract_transaction_info_response.dart';

import '../models/message.dart';
import '../models/transaction.dart';
import '../network/api_client.dart';

class AIService {
  final ApiClient _apiClient = ApiClient.instance;

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

    final Message message = Message.newAgentMessage(
      content: response['advice'],
      transactions: transactions
    );

    return message;
  }
}
