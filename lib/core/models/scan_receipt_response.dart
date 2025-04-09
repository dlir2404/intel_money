import 'dart:io';

import 'package:intel_money/core/models/wallet.dart';

import 'category.dart';

class TakePictureResponse {
  final File receiptImage;
  final ExtractedData? extractedData;

  TakePictureResponse({
    required this.receiptImage,
    this.extractedData,
  });
}

class ExtractedData {
  double? amount;
  Category? category;
  Wallet? sourceWallet;
  DateTime? date;
  String? description;

  ExtractedData({
    this.amount,
    this.category,
    this.sourceWallet,
    this.date,
    this.description,
  });
}