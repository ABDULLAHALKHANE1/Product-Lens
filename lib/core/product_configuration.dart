class ProductConfiguration {
  const ProductConfiguration({
    required this.apiBaseUrl,
    required this.requestTimeout,
    required this.pageSize,
  });

  final String apiBaseUrl;
  final Duration requestTimeout;
  final int pageSize;
}
