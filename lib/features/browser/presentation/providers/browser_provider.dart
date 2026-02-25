import 'package:flutter/foundation.dart';
import '../../data/repositories/browser_history_repository.dart';

class BrowserProvider extends ChangeNotifier {
  final BrowserHistoryRepository _repository;

  BrowserProvider(this._repository) {
    _loadHistory();
  }

  List<HistoryEntry> _history = [];
  bool _isLoading = true;

  List<HistoryEntry> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> _loadHistory() async {
    _history = await _repository.getHistory();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> recordVisit({required String url, required String title}) async {
    final entry = HistoryEntry(
      url: url,
      title: title,
      visitedAt: DateTime.now(),
    );
    await _repository.addEntry(entry);
    // Prepend to in-memory list (newest first)
    _history = [entry, ..._history];
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    _history = [];
    notifyListeners();
  }
}
