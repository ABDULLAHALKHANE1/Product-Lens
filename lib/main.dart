import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'di/app_dependencies.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProductLensApp(dependencies: AppDependencies.production()));
}

class ProductLensApp extends StatefulWidget {
  const ProductLensApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<ProductLensApp> createState() => _ProductLensAppState();
}

class _ProductLensAppState extends State<ProductLensApp> {
  @override
  void dispose() {
    widget.dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => widget.dependencies.createThemeProvider(),
          ),
          ChangeNotifierProvider<ProductProvider>(
            create: (_) => widget.dependencies.createProductProvider(),
          ),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) => MaterialApp.router(
            title: 'Product Lens',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            routerConfig: widget.dependencies.router,
          ),
        ),
      );
}
