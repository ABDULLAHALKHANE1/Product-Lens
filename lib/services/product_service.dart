import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/product_configuration.dart';
import '../models/product.dart';
import '../models/product_page.dart';
import 'api_exception.dart';
import 'product_remote_data_source.dart';

class ProductService implements ProductRemoteDataSource {
  const ProductService({
    required http.Client client,
    required ProductConfiguration configuration,
  }) : _client = client,
       _configuration = configuration;

  final http.Client _client;
  final ProductConfiguration _configuration;

  @override
  Future<ProductPage> getProducts({
    required int skip,
    required int limit,
    String query = '',
    String? category,
  }) async {
    final path = query.trim().isNotEmpty
        ? '/products/search'
        : category != null
        ? '/products/category/${Uri.encodeComponent(category)}'
        : '/products';
    final parameters = <String, String>{
      'limit': '$limit',
      'skip': '$skip',
      if (query.trim().isNotEmpty) 'q': query.trim(),
    };
    final uri = Uri.parse(
      '${_configuration.apiBaseUrl}$path',
    ).replace(queryParameters: parameters);

    return _parse(() async => ProductPage.fromJson(await _getJson(uri)));
  }

  @override
  Future<Product> getProduct(int id) async {
    final uri = Uri.parse('${_configuration.apiBaseUrl}/products/$id');
    return _parse(() async => Product.fromJson(await _getJson(uri)));
  }

  @override
  Future<List<String>> getCategories() async {
    final uri = Uri.parse(
      '${_configuration.apiBaseUrl}/products/category-list',
    );
    final response = await _get(uri);
    final decoded = _decode(response.body);
    if (decoded is! List<dynamic>) {
      throw const ApiException(
        ApiErrorType.malformedResponse,
        'The server returned an unexpected response.',
      );
    }
    return decoded.whereType<String>().toList(growable: false);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await _get(uri);
    final decoded = _decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        ApiErrorType.malformedResponse,
        'The server returned an unexpected response.',
      );
    }
    return decoded;
  }

  dynamic _decode(String source) {
    try {
      return jsonDecode(source);
    } on FormatException {
      throw const ApiException(
        ApiErrorType.malformedResponse,
        'The server returned an unreadable response.',
      );
    }
  }

  Future<T> _parse<T>(Future<T> Function() parser) async {
    try {
      return await parser();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        ApiErrorType.malformedResponse,
        'Some product information was missing or invalid.',
      );
    }
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_configuration.requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == 404) {
          throw const ApiException(
            ApiErrorType.notFound,
            'The requested product could not be found.',
            statusCode: 404,
          );
        }
        if (response.statusCode == 408) {
          throw const ApiException(
            ApiErrorType.timeout,
            'The server took too long to respond. Please try again.',
            statusCode: 408,
          );
        }
        if (response.statusCode == 429) {
          throw const ApiException(
            ApiErrorType.rateLimited,
            'Too many requests were sent. Please wait a moment and retry.',
            statusCode: 429,
          );
        }
        throw ApiException(
          ApiErrorType.server,
          'The server returned ${response.statusCode}. Please try again.',
          statusCode: response.statusCode,
        );
      }
      return response;
    } on TimeoutException {
      throw const ApiException(
        ApiErrorType.timeout,
        'The request took too long. Please try again.',
      );
    } on SocketException {
      throw const ApiException(
        ApiErrorType.noInternet,
        'No internet connection. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        ApiErrorType.noInternet,
        'Unable to reach the server. Check your connection and try again.',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        ApiErrorType.unexpected,
        'Something unexpected happened. Please try again.',
      );
    }
  }

  @override
  void dispose() => _client.close();
}
