import 'package:flutter/foundation.dart';
import '../../data/repositories/preferences_repository.dart';

class PreferencesProvider extends ChangeNotifier {
  final PreferencesRepository _repository;

  PreferencesProvider(this._repository) {
    _loadPreferences();
  }

  Set<int> _likedIds = {};
  Set<int> _dislikedIds = {};
  bool _isLoading = true;

  Set<int> get likedIds => _likedIds;
  Set<int> get dislikedIds => _dislikedIds;
  bool get isLoading => _isLoading;

  Preference getPreference(int productId) {
    if (_likedIds.contains(productId)) return Preference.liked;
    if (_dislikedIds.contains(productId)) return Preference.disliked;
    return Preference.none;
  }

  Future<void> _loadPreferences() async {
    _likedIds = await _repository.getLikedIds();
    _dislikedIds = await _repository.getDislikedIds();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(int productId) async {
    if (_likedIds.contains(productId)) {
      // Already liked → remove
      _likedIds.remove(productId);
      await _repository.clearPreference(productId);
    } else {
      // Like it
      _likedIds.add(productId);
      _dislikedIds.remove(productId);
      await _repository.setLiked(productId);
    }
    notifyListeners();
  }

  Future<void> toggleDislike(int productId) async {
    if (_dislikedIds.contains(productId)) {
      // Already disliked → remove
      _dislikedIds.remove(productId);
      await _repository.clearPreference(productId);
    } else {
      // Dislike it
      _dislikedIds.add(productId);
      _likedIds.remove(productId);
      await _repository.setDisliked(productId);
    }
    notifyListeners();
  }
}
