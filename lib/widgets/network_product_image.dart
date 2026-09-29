import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkProductImage extends StatelessWidget {
  const NetworkProductImage({
    required this.url,
    this.fit = BoxFit.contain,
    this.borderRadius,
    super.key,
  });

  final String url;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = url.isEmpty
        ? const _ImageFallback()
        : CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            errorWidget: (context, url, error) => const _ImageFallback(),
            progressIndicatorBuilder: (context, url, progress) => Center(
              child: CircularProgressIndicator.adaptive(
                value: progress.progress,
              ),
            ),
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Center(child: Icon(Icons.image_not_supported_outlined)),
  );
}
