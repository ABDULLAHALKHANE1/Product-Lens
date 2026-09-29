import 'package:flutter/material.dart';

import '../../models/product.dart';

/// "Customer reviews" section. Falls back to a single placeholder review
/// when the product has none.
class ProductReviews extends StatelessWidget {
  const ProductReviews({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final reviews = product.reviews.isEmpty
        ? [
            ProductReview(
              rating: product.rating.round(),
              comment: 'A solid product that matches the description.',
              reviewerName: 'Verified customer',
            ),
          ]
        : product.reviews;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer reviews',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        ...reviews.map((review) => _ReviewCard(review: review)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    review.reviewerName.isEmpty
                        ? '?'
                        : review.reviewerName.substring(0, 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    review.reviewerName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 17,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(review.comment),
          ],
        ),
      ),
    ),
  );
}
