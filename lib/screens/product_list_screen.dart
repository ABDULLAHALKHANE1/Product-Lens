import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../navigation/app_routes.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_exception.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_skeleton.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadNextPage);
  }

  void _loadNextPage() {
    if (_scrollController.position.extentAfter < 500) {
      context.read<ProductProvider>().loadProducts();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => context.read<ProductProvider>().search(value),
    );
  }

  Future<void> _selectCategory(String? category) async {
    _searchDebounce?.cancel();
    _searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    await context.read<ProductProvider>().selectCategory(category);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Lens',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Find something worth keeping',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        toolbarHeight: 76,
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () {
              final isDark = theme.brightness == Brightness.dark;
              context.read<ThemeProvider>().toggle(!isDark);
            },
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
            ),
            _CategoryFilter(onSelected: _selectCategory),
            const _CacheStatusBanner(),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.products.isEmpty) {
                    return const _LoadingGrid();
                  }
                  if (provider.products.isEmpty) {
                    return _EmptyState(
                      error: provider.error,
                      onRetry: () => provider.loadProducts(refresh: true),
                    );
                  }
                  return RefreshIndicator.adaptive(
                    onRefresh: () => provider.loadProducts(refresh: true),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 900
                            ? 4
                            : constraints.maxWidth >= 600
                            ? 3
                            : 2;
                        return CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                              sliver: SliverGrid.builder(
                                itemCount: provider.products.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: .60,
                                    ),
                                itemBuilder: (context, index) {
                                  final product = provider.products[index];
                                  return ProductCard(
                                    product: product,
                                    onTap: () => _openDetails(product),
                                  );
                                },
                              ),
                            ),
                            if (provider.isLoadingMore)
                              const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 24),
                                  child: Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                ),
                              ),
                            if (provider.errorMessage != null)
                              SliverToBoxAdapter(
                                child: _PaginationError(
                                  message: provider.errorMessage,
                                  onRetry: provider.loadProducts,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(Product product) {
    context.pushNamed(
      AppRoutes.productDetails,
      pathParameters: {'id': '${product.id}'},
      extra: product,
    );
  }
}

class _CacheStatusBanner extends StatelessWidget {
  const _CacheStatusBanner();

  @override
  Widget build(BuildContext context) => Selector<ProductProvider, bool>(
    selector: (_, provider) => provider.isUsingCachedData,
    builder: (context, isUsingCache, _) => AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: isUsingCache
          ? Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Offline mode · showing saved products'),
                  ),
                  TextButton(
                    onPressed: () => context
                        .read<ProductProvider>()
                        .loadProducts(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    ),
  );
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.onSelected});

  final ValueChanged<String?> onSelected;

  @override
  Widget build(
    BuildContext context,
  ) => Selector<ProductProvider, ({List<String> categories, String? selected})>(
    selector: (_, provider) =>
        (categories: provider.categories, selected: provider.selectedCategory),
    builder: (context, data, _) {
      if (data.categories.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 42,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: data.categories.length + 1,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = index == 0 ? null : data.categories[index - 1];
            final selected = data.selected == category;
            return ChoiceChip(
              selected: selected,
              label: Text(category == null ? 'All' : _friendlyName(category)),
              onSelected: (_) => onSelected(category),
            );
          },
        ),
      );
    },
  );

  String _friendlyName(String value) => value
      .split('-')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
    itemCount: 6,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: .60,
    ),
    itemBuilder: (context, index) => const ProductCardSkeleton(),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.error, required this.onRetry});

  final ApiException? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final title = switch (error?.type) {
      ApiErrorType.noInternet => 'You’re offline',
      ApiErrorType.timeout => 'The request timed out',
      ApiErrorType.notFound => 'Products not found',
      ApiErrorType.rateLimited => 'Too many requests',
      ApiErrorType.server => 'The store is unavailable',
      ApiErrorType.malformedResponse => 'We couldn’t read the response',
      ApiErrorType.unexpected => 'Something went wrong',
      null => 'No products found',
    };
    final icon = switch (error?.type) {
      ApiErrorType.noInternet => Icons.cloud_off_rounded,
      ApiErrorType.timeout => Icons.timer_off_outlined,
      ApiErrorType.notFound => Icons.search_off_rounded,
      ApiErrorType.rateLimited => Icons.hourglass_top_rounded,
      ApiErrorType.server => Icons.dns_outlined,
      ApiErrorType.malformedResponse => Icons.data_object_rounded,
      ApiErrorType.unexpected => Icons.error_outline_rounded,
      null => Icons.search_off_rounded,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              error?.message ?? 'Try another search or browse all categories.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationError extends StatelessWidget {
  const _PaginationError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            message ?? 'Could not load more products.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
