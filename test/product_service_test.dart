import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:product_lens/core/product_configuration.dart';
import 'package:product_lens/services/product_service.dart';

void main() {
  test('uses injected HTTP client and API configuration', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'example.test');
      expect(request.url.path, '/products');
      expect(request.url.queryParameters['limit'], '10');
      expect(request.url.queryParameters['skip'], '20');
      return http.Response(
        '{"products": [], "total": 0, "skip": 20, "limit": 10}',
        200,
      );
    });
    final service = ProductService(
      client: client,
      configuration: const ProductConfiguration(
        apiBaseUrl: 'https://example.test',
        requestTimeout: Duration(seconds: 1),
        pageSize: 10,
      ),
    );

    final result = await service.getProducts(skip: 20, limit: 10);

    expect(result.products, isEmpty);
    service.dispose();
  });
}
