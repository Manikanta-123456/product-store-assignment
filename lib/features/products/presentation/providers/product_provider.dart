import 'package:flutter/foundation.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/api_service.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider(this._repository) {
    fetchProducts(); // auto-fetch on creation
  }

  ProductStatus _status = ProductStatus.initial;
  List<Product> _products = [];
  String _errorMessage = '';

  String _selectedCategory = 'all';

  // Getters
  ProductStatus get status => _status;
  List<Product> get allProducts => _products;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList()..sort();
    return ['all', ...cats];
  }

  List<Product> get filteredProducts {
    if (_selectedCategory == 'all') return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      _products = await _repository.getProducts();
      _status = ProductStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ProductStatus.failure;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _status = ProductStatus.failure;
    }

    notifyListeners();
  }
}
