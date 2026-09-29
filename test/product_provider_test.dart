import 'package:flutter_test/flutter_test.dart';
import 'package:product_lens/models/product.dart';
import 'package:product_lens/models/product_page.dart';
import 'package:product_lens/providers/product_provider.dart';
import 'package:product_lens/repositories/product_repository.dart';

void main() {
  test('loads, searches, and filters products through the repository', () async {
    final repository = _FakeProductRepository();
    final provider = ProductProvider(repository, pageSize: 20);

    await provider.initialise();
    expect(provider.products, hasLength(1));
    expect(provider.categories, ['beauty']);

    await provider.search('phone');
    expect(repository.lastQuery, 'phone');
    expect(provider.query, 'phone');

    await provider.selectCategory('beauty');
    expect(repository.lastCategory, 'beauty');
    expect(provider.selectedCategory, 'beauty');
    expect(provider.query, isEmpty);

    provider.dispose();
    expect(repository.wasDisposed, isFalse);
    repository.dispose();
    expect(repository.wasDisposed, isTrue);
  });
}

class _FakeProductRepository implements ProductRepository {
  String lastQuery = '';
  String? lastCategory;
  bool wasDisposed = false;

  @override
  Future<DataResult<List<String>>> getCategories() async =>
      const DataResult.remote(['beauty']);

  @override
  Future<DataResult<Product>> getProduct(int id) async =>
      DataResult.remote(_product);

  @override
  Future<DataResult<ProductPage>> getProducts({
    required int skip,
    required int limit,
    String query = '',
    String? category,
  }) async {
    lastQuery = query;
    lastCategory = category;
    return DataResult.remote(
      ProductPage(products: [_product], total: 1, skip: skip, limit: limit),
    );
  }

  @override
  void dispose() => wasDisposed = true;

  Product get _product => const Product(
        id: 1,
        title: 'Product',
        description: 'Description',
        price: 10,
        discountPercentage: 0,
        rating: 4,
        stock: 2,
        brand: 'Brand',
        category: 'beauty',
        thumbnail: '',
        images: [],
        reviews: [],
      );
}
