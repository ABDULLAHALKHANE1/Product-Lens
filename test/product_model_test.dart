import 'package:flutter_test/flutter_test.dart';
import 'package:product_lens/models/product.dart';

void main() {
  test('parses product values and derives availability from stock', () {
    final product = Product.fromJson({
      'id': 7,
      'title': 'Desk lamp',
      'description': 'Warm adjustable light',
      'price': 49.95,
      'discountPercentage': 10,
      'rating': 4.6,
      'stock': 12,
      'category': 'home-decoration',
      'thumbnail': 'https://example.com/lamp.png',
      'images': ['https://example.com/lamp.png'],
      'reviews': [
        {
          'rating': 5,
          'comment': 'Looks great',
          'reviewerName': 'Sam',
        },
      ],
      'meta': {'qrCode': 'https://example.com/qr.png'},
    });

    expect(product.title, 'Desk lamp');
    expect(product.brand, 'Independent');
    expect(product.isInStock, isTrue);
    expect(product.reviews.single.reviewerName, 'Sam');
    expect(product.qrCode, 'https://example.com/qr.png');
    expect(product.discountedPrice, closeTo(44.955, .001));
  });
}
