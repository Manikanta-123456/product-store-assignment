class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String productsEndpoint = '/products';

  // SharedPreferences keys
  static const String likedProductsKey = 'liked_products';
  static const String dislikedProductsKey = 'disliked_products';
  static const String browsingHistoryKey = 'browsing_history';

  // Misc
  static const int maxHistoryEntries = 100;
}
