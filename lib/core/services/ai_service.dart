import 'package:intel_money/core/models/extract_transaction_info_response.dart';

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
}
