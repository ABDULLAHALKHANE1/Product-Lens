import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/api_exception.dart';

class ProductDetailProvider extends ChangeNotifier {
  ProductDetailProvider(this._repository);

  final ProductRepository _repository;
  Product? _product;
  bool _isLoading = false;
  ApiException? _error;
  bool _isUsingCachedData = false;
  bool _isDisposed = false;

  Product? get product => _product;

  bool get isLoading => _isLoading;

  ApiException? get error => _error;

  String? get errorMessage => _error?.message;

  bool get isUsingCachedData => _isUsingCachedData;

  Future<void> load(int id) async {
    _isLoading = true;
    _error = null;
    _isUsingCachedData = false;
    _notifyListeners();
    try {
      final result = await _repository.getProduct(id);
      _product = result.data;
      _isUsingCachedData = result.isFromCache;
    } catch (error) {
      _error = error is ApiException
          ? error
          : const ApiException(
              ApiErrorType.unexpected,
              'Something unexpected happened. Please try again.',
            );
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
