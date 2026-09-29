import 'package:flutter/material.dart';

import '../../models/product.dart';

/// Wraps a grid of [_InfoTile]s describing availability, category,
/// shipping, warranty and return-policy information for a product.
class ProductInformationGrid extends StatelessWidget {
  const ProductInformationGrid({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final details = <({IconData icon, String label, String value})>[
      (
        icon: product.isInStock ? Icons.inventory_2_outlined : Icons.block,
        label: 'Availability',
        value: product.isInStock ? 'In Stock (${product.stock})' : 'Out of Stock',
      ),
      (icon: Icons.category_outlined, label: 'Category', value: product.category),
      if (product.shippingInformation != null)
        (
          icon: Icons.local_shipping_outlined,
          label: 'Shipping',
          value: product.shippingInformation!,
        ),
      if (product.warrantyInformation != null)
        (
          icon: Icons.verified_user_outlined,
          label: 'Warranty',
          value: product.warrantyInformation!,
        ),
      if (product.returnPolicy != null)
        (
          icon: Icons.assignment_return_outlined,
          label: 'Returns',
          value: product.returnPolicy!,
        ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: details
          .map(
            (detail) => SizedBox(
              width: (MediaQuery.sizeOf(context).width - 50) / 2,
              child: _InfoTile(
                icon: detail.icon,
                label: detail.label,
                value: detail.value,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
