import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../network_product_image.dart';

/// Swipeable image gallery for the product detail screen.
///
/// Shows a page indicator when there is more than one image and overlays
/// a back button on top of the image stack (there is no AppBar on this
/// screen, so this is the only way back).
class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({required this.product, super.key});

  final Product product;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _currentPage = 0;

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
                      top: 80,
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
            // Back arrow overlay.
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
