import 'product.dart';

class ProductPage {
  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final items = json['products'] as List<dynamic>? ?? const [];
    return ProductPage(
      products: items
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false),
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'products': products.map((product) => product.toJson()).toList(),
        'total': total,
        'skip': skip,
        'limit': limit,
      };
}
