import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/product.dart';
import '../providers/product_detail_provider.dart';
import '../providers/product_detail_provider_factory.dart';
import '../widgets/network_product_image.dart';
import '../widgets/rating_badge.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    required this.productId,
    required this.providerFactory,
    this.initialProduct,
    super.key,
  });

  final int productId;
  final ProductDetailProviderFactory providerFactory;
  final Product? initialProduct;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => providerFactory.create()..load(productId),
        child: _ProductDetailView(
          productId: productId,
          fallbackProduct: initialProduct,
        ),
      );
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView({
    required this.productId,
    required this.fallbackProduct,
  });

  final int productId;
  final Product? fallbackProduct;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailProvider>();
    final product = provider.product ?? fallbackProduct;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product details')),
        body: Center(
          child: provider.isLoading
              ? const CircularProgressIndicator.adaptive()
              : Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage ?? 'Product details are unavailable.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => provider.load(productId),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar.large(
          //   pinned: true,
          //   title: Text(product.title),
          //   actions: [
          //     IconButton(
          //       tooltip: 'Refresh',
          //       onPressed: provider.isLoading ? null : () => provider.load(product.id),
          //       icon: const Icon(Icons.refresh_rounded),
          //     ),
          //     const SizedBox(width: 6),
          //   ],
          // ),
          if (provider.isLoading)
            const SliverToBoxAdapter(child: LinearProgressIndicator()),
          if (provider.isUsingCachedData)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: const Row(
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 20),
                    SizedBox(width: 10),
                    Expanded(child: Text('Offline mode · showing saved details')),
                  ],
                ),
              ),
            ),
          if (provider.errorMessage != null)
            SliverToBoxAdapter(
              child: MaterialBanner(
                content: Text(
                  'Showing saved product information. ${provider.errorMessage}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => provider.load(product.id),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          SliverToBoxAdapter(child: _ImageGallery(product: product)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProductHeading(product: product),
                const SizedBox(height: 20),
                _Description(product: product),
                const SizedBox(height: 22),
                _InformationGrid(product: product),
                const SizedBox(height: 30),
                _Reviews(product: product),
                const SizedBox(height: 30),
                _QrSection(product: product),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageGallery extends StatefulWidget {
  const _ImageGallery({required this.product});

  final Product product;

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _currentPage = 0;

  @override
  @override
  Widget build(BuildContext context) {
    final images = widget.product.images.isEmpty
        ? [widget.product.thumbnail]
        : widget.product.images;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 400,
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemBuilder: (context, index) => ColoredBox(
                  color: colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      top: 80
                    ),
                    child: index == 0
                        ? Hero(
                      tag: 'product-${widget.product.id}',
                      child: NetworkProductImage(url: images[index]),
                    )
                        : NetworkProductImage(url: images[index]),
                  ),
                ),
              ),
            ),
            // Back arrow overlay
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              child: IconButton.filledTonal(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ],
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: index == _currentPage ? 22 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index == _currentPage
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProductHeading extends StatelessWidget {
  const _ProductHeading({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                product.brand.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
            RatingBadge(rating: product.rating),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          product.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (product.discountPercentage > 0) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '${product.discountPercentage.toStringAsFixed(0)}% off',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.product});

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

class _InformationGrid extends StatelessWidget {
  const _InformationGrid({required this.product});

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

class _Reviews extends StatelessWidget {
  const _Reviews({required this.product});

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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
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

class _QrSection extends StatelessWidget {
  const _QrSection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 108,
              height: 108,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: product.qrCode?.isNotEmpty == true
                  ? NetworkProductImage(url: product.qrCode!)
                  : QrImageView(
                      data: 'https://dummyjson.com/products/${product.id}',
                      padding: EdgeInsets.zero,
                    ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product QR code',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Scan to quickly identify this product.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
