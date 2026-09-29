import 'dart:convert';

import '../models/product.dart';
import '../models/product_page.dart';
import '../storage/key_value_store.dart';

abstract interface class ProductCache {
  Future<void> savePage({
    required int skip,
    required int limit,
    required String query,
    required String? category,
    required ProductPage page,
  });

  Future<ProductPage?> readPage({
    required int skip,
    required int limit,
    required String query,
    required String? category,
  });

  Future<void> saveProduct(Product product);
  Future<Product?> readProduct(int id);
  Future<void> saveCategories(List<String> categories);
  Future<List<String>?> readCategories();
}

class PersistentProductCache implements ProductCache {
  const PersistentProductCache({required KeyValueStore store}) : _store = store;

  static const _categoriesKey = 'cache.categories';
  final KeyValueStore _store;

  @override
  Future<void> savePage({
    required int skip,
    required int limit,
    required String query,
    required String? category,
    required ProductPage page,
  }) async {
    await _store.setString(
      _pageKey(skip, limit, query, category),
      jsonEncode(page.toJson()),
    );
    await Future.wait(page.products.map(saveProduct));
  }

  @override
  Future<ProductPage?> readPage({
    required int skip,
    required int limit,
    required String query,
    required String? category,
  }) async {
    final value = await _store.getString(
      _pageKey(skip, limit, query, category),
    );
    if (value == null) return null;
    try {
      return ProductPage.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProduct(Product product) => _store.setString(
        'cache.product.${product.id}',
        jsonEncode(product.toJson()),
      );

  @override
  Future<Product?> readProduct(int id) async {
    final value = await _store.getString('cache.product.$id');
    if (value == null) return null;
    try {
      return Product.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCategories(List<String> categories) =>
      _store.setString(_categoriesKey, jsonEncode(categories));

  @override
  Future<List<String>?> readCategories() async {
    final value = await _store.getString(_categoriesKey);
    if (value == null) return null;
    try {
      final decoded = jsonDecode(value) as List<dynamic>;
      return decoded.whereType<String>().toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  String _pageKey(int skip, int limit, String query, String? category) {
    final scope = query.trim().isNotEmpty
        ? 'search.${query.trim().toLowerCase()}'
        : 'category.${category ?? 'all'}';
    return 'cache.page.$scope.$skip.$limit';
  }
}
