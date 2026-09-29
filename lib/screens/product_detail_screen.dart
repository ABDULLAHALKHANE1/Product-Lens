import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_detail_provider.dart';
import '../providers/product_detail_provider_factory.dart';
import '../widgets/product_detail/product_description.dart';
import '../widgets/product_detail/product_heading.dart';
import '../widgets/product_detail/product_image_gallery.dart';
import '../widgets/product_detail/product_information_grid.dart';
import '../widgets/product_detail/product_qr_section.dart';
import '../widgets/product_detail/product_reviews.dart';

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
      return _ProductDetailEmptyState(
        provider: provider,
        productId: productId,
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (provider.isLoading)
            const SliverToBoxAdapter(child: LinearProgressIndicator()),
          if (provider.isUsingCachedData)
            const SliverToBoxAdapter(child: _OfflineBanner()),
          if (provider.errorMessage != null)
            SliverToBoxAdapter(
              child: _RetryBanner(
                message: provider.errorMessage!,
                onRetry: () => provider.load(product.id),
              ),
            ),
          SliverToBoxAdapter(child: ProductImageGallery(product: product)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ProductHeading(product: product),
                const SizedBox(height: 20),
                ProductDescription(product: product),
                const SizedBox(height: 22),
                ProductInformationGrid(product: product),
                const SizedBox(height: 30),
                ProductReviews(product: product),
                const SizedBox(height: 30),
                ProductQrSection(product: product),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen loading / error state shown while no product data
/// (fresh or cached) is available yet.
class _ProductDetailEmptyState extends StatelessWidget {
  const _ProductDetailEmptyState({
    required this.provider,
    required this.productId,
  });

  final ProductDetailProvider provider;
  final int productId;

  @override
  Widget build(BuildContext context) => Scaffold(
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

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: const Row(
          children: [
            Icon(Icons.cloud_off_rounded, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text('Offline mode · showing saved details')),
          ],
        ),
      );
}

class _RetryBanner extends StatelessWidget {
  const _RetryBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MaterialBanner(
        content: Text('Showing saved product information. $message'),
        actions: [
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
}
