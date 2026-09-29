import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/api_exception.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._repository, {required int pageSize})
      : _pageSize = pageSize;

  final ProductRepository _repository;
  final int _pageSize;
  final List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  ApiException? _error;
  bool _isUsingCachedData = false;
  int _total = 0;
  String _query = '';
  String? _selectedCategory;
  int _requestVersion = 0;
  bool _isDisposed = false;

  List<Product> get products => List.unmodifiable(_products);
  List<String> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  ApiException? get error => _error;
  String? get errorMessage => _error?.message;
  bool get isUsingCachedData => _isUsingCachedData;
  String get query => _query;
  String? get selectedCategory => _selectedCategory;
  bool get canLoadMore => _products.length < _total;

  Future<void> initialise() async {
    await Future.wait([_reload(), _loadCategories()]);
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) return _reload();
    if (_products.isEmpty) {
      if (!_isLoading) return _reload();
      return;
    }
    if (_isLoading || _isLoadingMore || !canLoadMore) return;

    final requestVersion = _requestVersion;
    _isLoadingMore = true;
    _error = null;
    _notifyListeners();
    print(_requestVersion);
    print(requestVersion);
    try {
      final result = await _repository.getProducts(
        skip: _products.length,
        limit: _pageSize,
        query: _query,
        category: _query.isEmpty ? _selectedCategory : null,
      );
      if (requestVersion != _requestVersion) return;
      _products.addAll(result.data.products);
      _total = result.data.total;
      _isUsingCachedData = result.isFromCache;
    } catch (error) {
      if (requestVersion != _requestVersion) return;
      _error = _asApiException(error);
    } finally {
      if (requestVersion == _requestVersion) {
        _isLoadingMore = false;
        _notifyListeners();
      }
    }
  }

  Future<void> search(String value) async {
    final cleanValue = value.trim();
    if (_query == cleanValue) return;
    _query = cleanValue;
    if (_query.isNotEmpty) _selectedCategory = null;
    await _reload();
  }

  Future<void> selectCategory(String? category) async {
    if (_selectedCategory == category && _query.isEmpty) return;
    _selectedCategory = category;
    _query = '';
    await _reload();
  }

  Future<void> _reload() async {
    final requestVersion = ++_requestVersion;
    _products.clear();
    _total = 0;
    _isLoading = true;
    _isLoadingMore = false;
    _error = null;
    _isUsingCachedData = false;
    _notifyListeners();

    try {
      final result = await _repository.getProducts(
        skip: 0,
        limit: _pageSize,
        query: _query,
        category: _query.isEmpty ? _selectedCategory : null,
      );
      if (requestVersion != _requestVersion) return;
      _products.addAll(result.data.products);
      _total = result.data.total;
      _isUsingCachedData = result.isFromCache;
    } catch (error) {
      if (requestVersion != _requestVersion) return;
      _error = _asApiException(error);
    } finally {
      if (requestVersion == _requestVersion) {
        _isLoading = false;
        _notifyListeners();
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await _repository.getCategories();
      _categories = result.data;
      _notifyListeners();
    } catch (_) {
      // Category filters are optional; the product feed can still be used.
    }
  }

  ApiException _asApiException(Object error) => error is ApiException
      ? error
      : const ApiException(
          ApiErrorType.unexpected,
          'Something unexpected happened. Please try again.',
        );

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
