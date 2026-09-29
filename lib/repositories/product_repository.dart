import '../models/product.dart';
import '../models/product_page.dart';

abstract interface class ProductRepository {
  Future<DataResult<ProductPage>> getProducts({
    required int skip,
    required int limit,
    String query = '',
    String? category,
  });

  Future<DataResult<Product>> getProduct(int id);

  Future<DataResult<List<String>>> getCategories();

  void dispose();
}

class DataResult<T> {
  const DataResult({required this.data, required this.isFromCache});

  const DataResult.remote(T data) : this(data: data, isFromCache: false);

  const DataResult.cached(T data) : this(data: data, isFromCache: true);

  final T data;
  final bool isFromCache;
}
