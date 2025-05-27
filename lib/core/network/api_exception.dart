class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic error;

  ApiException({
    required this.message,
    this.statusCode = 0,
    this.error,
  });

  @override
  String toString() => message;
}