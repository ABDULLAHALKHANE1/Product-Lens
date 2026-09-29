enum ApiErrorType {
  noInternet,
  timeout,
  notFound,
  rateLimited,
  server,
  malformedResponse,
  unexpected,
}

class ApiException implements Exception {
  const ApiException(this.type, this.message, {this.statusCode});

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  bool get isConnectivityFailure =>
      type == ApiErrorType.noInternet || type == ApiErrorType.timeout;

  @override
  String toString() => message;
}
