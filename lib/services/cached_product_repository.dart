import '../models/product.dart';
import '../models/product_page.dart';
import '../repositories/product_repository.dart';
import 'api_exception.dart';
import 'product_cache.dart';
import 'product_remote_data_source.dart';

class CachedProductRepository implements ProductRepository {
  CachedProductRepository({
    required ProductRemoteDataSource remote,
    required ProductCache cache,
  })  : _remote = remote,
        _cache = cache;

  final ProductRemoteDataSource _remote;
  final ProductCache _cache;
  @override
  Future<DataResult<ProductPage>> getProducts({
    required int skip,
    required int limit,
    String query = '',
    String? category,
  }) async {
    try {
      final page = await _remote.getProducts(
        skip: skip,
        limit: limit,
        query: query,
        category: category,
      );
      try {
        await _cache.savePage(
          skip: skip,
          limit: limit,
          query: query,
          category: category,
          page: page,
        );
      } catch (_) {
        // A cache write must never turn a successful request into a failure.
      }
      return DataResult.remote(page);
    } on ApiException catch (error) {
      if (!error.isConnectivityFailure) rethrow;
      ProductPage? cachedPage;
      try {
        cachedPage = await _cache.readPage(
          skip: skip,
          limit: limit,
          query: query,
          category: category,
        );
      } catch (_) {
        throw error;
      }
      if (cachedPage == null) throw error;
      return DataResult.cached(cachedPage);
    }
  }

  @override
  Future<DataResult<Product>> getProduct(int id) async {
    try {
      final product = await _remote.getProduct(id);
      try {
        await _cache.saveProduct(product);
      } catch (_) {
        // Keep the live result even if local persistence is unavailable.
      }
      return DataResult.remote(product);
    } on ApiException catch (error) {
      if (!error.isConnectivityFailure) rethrow;
      Product? cachedProduct;
      try {
        cachedProduct = await _cache.readProduct(id);
      } catch (_) {
        throw error;
      }
      if (cachedProduct == null) throw error;
      return DataResult.cached(cachedProduct);
    }
  }

  @override
  Future<DataResult<List<String>>> getCategories() async {
    try {
      final categories = await _remote.getCategories();
      try {
        await _cache.saveCategories(categories);
      } catch (_) {
        // Category caching is optional.
      }
      return DataResult.remote(categories);
    } on ApiException catch (error) {
      if (!error.isConnectivityFailure) rethrow;
      List<String>? cachedCategories;
      try {
        cachedCategories = await _cache.readCategories();
      } catch (_) {
        throw error;
      }
      if (cachedCategories == null) throw error;
      return DataResult.cached(cachedCategories);
    }
  }

  @override
  void dispose() => _remote.dispose();
}
