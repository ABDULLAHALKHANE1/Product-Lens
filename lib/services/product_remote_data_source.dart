import '../models/product.dart';
import '../models/product_page.dart';

abstract interface class ProductRemoteDataSource {
  Future<ProductPage> getProducts({
    required int skip,
    required int limit,
    String query = '',
    String? category,
  });

  Future<Product> getProduct(int id);
  Future<List<String>> getCategories();
  void dispose();
}
