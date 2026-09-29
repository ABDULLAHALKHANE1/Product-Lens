import 'package:flutter_test/flutter_test.dart';
import 'package:product_lens/models/product.dart';
import 'package:product_lens/models/product_page.dart';
import 'package:product_lens/services/api_exception.dart';
import 'package:product_lens/services/cached_product_repository.dart';
import 'package:product_lens/services/product_cache.dart';
import 'package:product_lens/services/product_remote_data_source.dart';

void main() {
  test('returns a cached page when the device is offline', () async {
    final cachedPage = ProductPage(
      products: [_product],
      total: 1,
      skip: 0,
      limit: 20,
    );
    final repository = CachedProductRepository(
      remote: _FailingRepository(ApiErrorType.noInternet),
      cache: _MemoryProductCache(page: cachedPage),
    );

    final result = await repository.getProducts(skip: 0, limit: 20);

    expect(result.data.products.single.title, 'Cached product');
    expect(result.isFromCache, isTrue);
  });

  test('does not hide a non-connectivity API failure with cached data', () async {
    final repository = CachedProductRepository(
      remote: _FailingRepository(ApiErrorType.server),
      cache: _MemoryProductCache(
        page: ProductPage(
          products: [_product],
          total: 1,
          skip: 0,
          limit: 20,
        ),
      ),
    );

    await expectLater(
      repository.getProducts(skip: 0, limit: 20),
      throwsA(
        isA<ApiException>().having(
          (error) => error.type,
          'type',
          ApiErrorType.server,
        ),
      ),
    );
  });
}

const _product = Product(
  id: 1,
  title: 'Cached product',
  description: 'Available without a connection',
  price: 15,
  discountPercentage: 0,
  rating: 4.5,
  stock: 3,
  brand: 'Local',
  category: 'test',
  thumbnail: '',
  images: [],
  reviews: [],
);

class _FailingRepository implements ProductRemoteDataSource {
  _FailingRepository(this.errorType);

  final ApiErrorType errorType;

  @override
  Future<List<String>> getCategories() => throw _error;

  @override
  Future<Product> getProduct(int id) => throw _error;

  @override
  Future<ProductPage> getProducts({
    required int skip,
    required int limit,
    String query = '',
    String? category,
  }) =>
      throw _error;

  ApiException get _error => ApiException(errorType, 'Request failed.');

  @override
  void dispose() {}
}

class _MemoryProductCache implements ProductCache {
  _MemoryProductCache({required this.page});

  final ProductPage page;

  @override
  Future<ProductPage?> readPage({
    required int skip,
    required int limit,
    required String query,
    required String? category,
  }) async =>
      page;

  @override
  Future<List<String>?> readCategories() async => null;

  @override
  Future<Product?> readProduct(int id) async => null;

  @override
  Future<void> saveCategories(List<String> categories) async {}

  @override
  Future<void> savePage({
    required int skip,
    required int limit,
    required String query,
    required String? category,
    required ProductPage page,
  }) async {}

  @override
  Future<void> saveProduct(Product product) async {}
}
