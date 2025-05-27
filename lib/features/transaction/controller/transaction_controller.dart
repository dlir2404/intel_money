import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intel_money/core/models/extract_transaction_info_response.dart';
import 'package:intel_money/core/services/ai_service.dart';

import '../../../core/models/category.dart';
import '../../../core/models/scan_receipt_response.dart';
import '../../../core/models/wallet.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/related_user_state.dart';
import '../../../core/state/statistic_state.dart';
import '../../../core/state/transaction_state.dart';
import '../../../core/state/wallet_state.dart';

class TransactionController {
  final TransactionService _transactionService = TransactionService();
  final AppState _appState = AppState();
  final TransactionState _transactionState = TransactionState();
  final WalletState _walletState = WalletState();
  final StatisticState _statisticState = StatisticState();
  final RelatedUserState _relatedUserState = RelatedUserState();

  static Future<TakePictureResponse> extractTransactionDataFromImage(
    CroppedFile image,
  ) async {
    //Scan text from image
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    final String scannedText = recognizedText.text;

    //call AI to extract
    final ExtractTransactionInfoResponse transInfo =
        await extractTransactionDataFromText(scannedText);

    final Category category = Category.fromContext(transInfo.categoryId);
    final Wallet wallet = Wallet.fromContext(transInfo.walletId);

    return TakePictureResponse(
      receiptImage: File(image.path),
      extractedData: ExtractedData(
        amount: transInfo.amount,
        category: category,
        sourceWallet: wallet,
        date: transInfo.date,
        description: transInfo.description ?? scannedText,
      ),
    );
  }

  static Future<ExtractTransactionInfoResponse> extractTransactionDataFromText(
    String text,
  ) async {
    return extractTransactionOnline(text);
  }

  static Future<ExtractTransactionInfoResponse> extractTransactionOnline(
    String text,
  ) async {
    return await AIService().extractTransactionInfo(text);
  }

  static Map<String, dynamic> extractTransactionOffline(String text) {
    // This is a simple implementation - you'll need to improve this
    // based on the format of receipts you're expecting to scan

    final lines = text.split('\n');
    double? totalAmount;
    DateTime? date;
    String? storeName;

    // Try to find store name (usually at the top)
    if (lines.isNotEmpty) {
      storeName = lines[0];
    }

    // Look for date
    for (final line in lines) {
      // Simple regex for date formats like DD/MM/YYYY or YYYY-MM-DD
      RegExp dateRegex = RegExp(r'(\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4})');
      final dateMatch = dateRegex.firstMatch(line);
      if (dateMatch != null) {
        try {
          // Try to parse the date - this is simplified
          final dateStr = dateMatch.group(0)!;
          // You'll need more robust date parsing logic based on your locale
          date = DateTime.parse(dateStr);
        } catch (e) {
          // Fallback to current date if parsing fails
          date = DateTime.now();
        }
      }
    }

    // Look for total amount
    for (final line in lines) {
      if (line.toLowerCase().contains('total') ||
          line.toLowerCase().contains('amount') ||
          line.toLowerCase().contains('sum')) {
        // Extract numbers from the line
        RegExp amountRegex = RegExp(r'(\d+[,.]\d+)');
        final amountMatch = amountRegex.firstMatch(line);
        if (amountMatch != null) {
          try {
            String amountStr = amountMatch.group(0)!;
            amountStr = amountStr.replaceAll(',', '.');
            totalAmount = double.parse(amountStr);
          } catch (e) {
            print('Error parsing amount: $e');
          }
        }
      }
    }

    return {
      'store': storeName ?? 'Unknown Store',
      'date': date ?? DateTime.now(),
      'amount': totalAmount ?? 0.0,
      'fullText': text,
    };
  }

  Future<void> deleteTransaction(int transactionId) async {
    await _transactionService.deleteTransaction(transactionId);

    _transactionState.removeTransaction(transactionId);
    //TODO: change user balance & wallet balance here
  }
}
