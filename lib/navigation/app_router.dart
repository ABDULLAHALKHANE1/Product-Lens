import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../providers/product_detail_provider_factory.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_list_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create({
    required ProductDetailProviderFactory detailProviderFactory,
  }) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.products,
        builder: (context, state) => const ProductListScreen(),
        routes: [
          GoRoute(
            path: 'products/:id',
            name: AppRoutes.productDetails,
            builder: (context, state) {
              final productId = int.tryParse(state.pathParameters['id'] ?? '');
              if (productId == null || productId <= 0) {
                return const _InvalidProductRoute();
              }
              return ProductDetailScreen(
                productId: productId,
                initialProduct:
                    state.extra is Product ? state.extra as Product : null,
                providerFactory: detailProviderFactory,
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _RouteErrorScreen(message: state.error),
  );
}

class _InvalidProductRoute extends StatelessWidget {
  const _InvalidProductRoute();

  @override
  Widget build(BuildContext context) => const _RouteErrorScreen(
        message: 'That product link is invalid.',
      );
}

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({required this.message});

  final Object? message;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'We couldn’t open this page',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  message?.toString() ?? 'The requested page does not exist.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.goNamed(AppRoutes.products),
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Text('Browse products'),
                ),
              ],
            ),
          ),
        ),
      );
}
