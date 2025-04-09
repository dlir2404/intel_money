import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../core/models/scan_receipt_response.dart';

class TransactionController {
  static Future<TakePictureResponse> extractTransactionDataFromImage(CroppedFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);

    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    final String scannedText = recognizedText.text;

    final extractedData = extractTransactionDataFromText(scannedText);

    return TakePictureResponse(
      receiptImage: File(image.path),
      extractedData: ExtractedData(
        amount: extractedData['amount'],
        // category: Category.fromString(extractedData['category']),
        // sourceWallet: Wallet.fromString(extractedData['store']),
        date: extractedData['date'],
        description: extractedData['fullText'],
      ),
    );
  }

  static Map<String, dynamic> extractTransactionDataFromText(String text){
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
}