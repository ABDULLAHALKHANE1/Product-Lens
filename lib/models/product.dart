class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
    required this.reviews,
    this.qrCode,
    this.warrantyInformation,
    this.shippingInformation,
    this.returnPolicy,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;
  final List<ProductReview> reviews;
  final String? qrCode;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? returnPolicy;

  bool get isInStock => stock > 0;

  double get discountedPrice => price * (1 - discountPercentage / 100);

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? const [];
    final rawReviews = json['reviews'] as List<dynamic>? ?? const [];
    final meta = json['meta'] as Map<String, dynamic>?;

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: (json['brand'] as String?)?.trim().isNotEmpty == true
          ? json['brand'] as String
          : 'Independent',
      category: json['category'] as String? ?? 'Uncategorized',
      thumbnail: json['thumbnail'] as String? ?? '',
      images: rawImages.whereType<String>().toList(growable: false),
      reviews: rawReviews
          .whereType<Map<String, dynamic>>()
          .map(ProductReview.fromJson)
          .toList(growable: false),
      qrCode: meta?['qrCode'] as String?,
      warrantyInformation: json['warrantyInformation'] as String?,
      shippingInformation: json['shippingInformation'] as String?,
      returnPolicy: json['returnPolicy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'stock': stock,
        'brand': brand,
        'category': category,
        'thumbnail': thumbnail,
        'images': images,
        'reviews': reviews.map((review) => review.toJson()).toList(),
        'meta': {'qrCode': qrCode},
        'warrantyInformation': warrantyInformation,
        'shippingInformation': shippingInformation,
        'returnPolicy': returnPolicy,
      };
}

class ProductReview {
  const ProductReview({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    this.date,
  });

  final int rating;
  final String comment;
  final String reviewerName;
  final DateTime? date;

  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] as String? ?? 'No comment provided.',
        reviewerName: json['reviewerName'] as String? ?? 'Verified customer',
        date: DateTime.tryParse(json['date'] as String? ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'comment': comment,
        'reviewerName': reviewerName,
        'date': date?.toIso8601String(),
      };
}
