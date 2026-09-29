import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/product_configuration.dart';
import '../navigation/app_router.dart';
import '../providers/product_detail_provider_factory.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../repositories/product_repository.dart';
import '../services/cached_product_repository.dart';
import '../services/product_cache.dart';
import '../services/product_service.dart';
import '../services/theme_preferences.dart';
import '../storage/key_value_store.dart';

class AppDependencies {
  AppDependencies({
    required this.productRepository,
    required this.themePreferences,
    required this.productConfiguration,
    required this.productDetailProviderFactory,
    required this.router,
  });

  factory AppDependencies.production() {
    const productConfiguration = ProductConfiguration(
      apiBaseUrl: 'https://dummyjson.com',
      requestTimeout: Duration(seconds: 15),
      pageSize: 20,
    );
    final keyValueStore = SharedPreferencesKeyValueStore(
      SharedPreferencesAsync(),
    );
    final productRepository = CachedProductRepository(
      remote: ProductService(
        client: http.Client(),
        configuration: productConfiguration,
      ),
      cache: PersistentProductCache(store: keyValueStore),
    );
    final productDetailProviderFactory = DefaultProductDetailProviderFactory(
      productRepository,
    );

    return AppDependencies(
      productRepository: productRepository,
      themePreferences: LocalThemePreferences(keyValueStore),
      productConfiguration: productConfiguration,
      productDetailProviderFactory: productDetailProviderFactory,
      router: AppRouter.create(
        detailProviderFactory: productDetailProviderFactory,
      ),
    );
  }

  final ProductRepository productRepository;
  final ThemePreferences themePreferences;
  final ProductConfiguration productConfiguration;
  final ProductDetailProviderFactory productDetailProviderFactory;
  final GoRouter router;

  ProductProvider createProductProvider() => ProductProvider(
    productRepository,
    pageSize: productConfiguration.pageSize,
  )..initialise();

  ThemeProvider createThemeProvider() => ThemeProvider(themePreferences);

  void dispose() {
    router.dispose();
    productRepository.dispose();
  }
}
