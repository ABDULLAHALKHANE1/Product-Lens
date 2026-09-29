import 'package:flutter/material.dart';

import '../../models/product.dart';

/// "About this product" section on the product detail screen.
class ProductDescription extends StatelessWidget {
  const ProductDescription({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this product',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
        ],
      );
}
