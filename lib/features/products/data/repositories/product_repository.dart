import '../models/product_model.dart';
import '../services/api_service.dart';

/// Repository that abstracts the data source from the presentation layer.
/// Currently uses the remote API, but could easily be extended with a cache.
class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  Future<List<Product>> getProducts() => _apiService.fetchProducts();
}
