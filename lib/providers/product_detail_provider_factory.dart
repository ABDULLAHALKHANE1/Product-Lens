import '../repositories/product_repository.dart';
import 'product_detail_provider.dart';

abstract interface class ProductDetailProviderFactory {
  ProductDetailProvider create();
}

class DefaultProductDetailProviderFactory
    implements ProductDetailProviderFactory {
  const DefaultProductDetailProviderFactory(this._repository);

  final ProductRepository _repository;

  @override
  ProductDetailProvider create() => ProductDetailProvider(_repository);
}
