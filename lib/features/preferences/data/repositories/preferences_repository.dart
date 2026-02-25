import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

enum Preference { liked, disliked, none }

/// Persists like/dislike decisions for products.
/// Stores sets of product IDs under separate keys.
class PreferencesRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Set<int>> getLikedIds() async {
    final prefs = await _instance;
    final raw = prefs.getStringList(AppConstants.likedProductsKey) ?? [];
    return raw.map(int.parse).toSet();
  }

  Future<Set<int>> getDislikedIds() async {
    final prefs = await _instance;
    final raw = prefs.getStringList(AppConstants.dislikedProductsKey) ?? [];
    return raw.map(int.parse).toSet();
  }

  Future<void> setLiked(int productId) async {
    final prefs = await _instance;
    final liked = await getLikedIds()..add(productId);
    final disliked = await getDislikedIds()..remove(productId);
    await prefs.setStringList(
      AppConstants.likedProductsKey,
      liked.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      AppConstants.dislikedProductsKey,
      disliked.map((e) => e.toString()).toList(),
    );
  }

  Future<void> setDisliked(int productId) async {
    final prefs = await _instance;
    final disliked = await getDislikedIds()..add(productId);
    final liked = await getLikedIds()..remove(productId);
    await prefs.setStringList(
      AppConstants.dislikedProductsKey,
      disliked.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      AppConstants.likedProductsKey,
      liked.map((e) => e.toString()).toList(),
    );
  }

  Future<void> clearPreference(int productId) async {
    final prefs = await _instance;
    final liked = await getLikedIds()..remove(productId);
    final disliked = await getDislikedIds()..remove(productId);
    await prefs.setStringList(
      AppConstants.likedProductsKey,
      liked.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      AppConstants.dislikedProductsKey,
      disliked.map((e) => e.toString()).toList(),
    );
  }
}
