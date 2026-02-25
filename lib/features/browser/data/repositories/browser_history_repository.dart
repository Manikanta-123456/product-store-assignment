import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

class HistoryEntry {
  final String url;
  final String title;
  final DateTime visitedAt;

  const HistoryEntry({
    required this.url,
    required this.title,
    required this.visitedAt,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'visitedAt': visitedAt.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        url: json['url'] as String,
        title: json['title'] as String,
        visitedAt: DateTime.parse(json['visitedAt'] as String),
      );

  String encode() =>
      '${visitedAt.toIso8601String()}|||$url|||$title';

  factory HistoryEntry.decode(String raw) {
    final parts = raw.split('|||');
    return HistoryEntry(
      visitedAt: DateTime.parse(parts[0]),
      url: parts[1],
      title: parts[2],
    );
  }
}

/// Persists browsing history as a list of encoded strings in SharedPreferences.
class BrowserHistoryRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<HistoryEntry>> getHistory() async {
    final prefs = await _instance;
    final raw = prefs.getStringList(AppConstants.browsingHistoryKey) ?? [];
    return raw
        .map((e) => HistoryEntry.decode(e))
        .toList()
        .reversed
        .toList(); // newest first
  }

  Future<void> addEntry(HistoryEntry entry) async {
    final prefs = await _instance;
    final raw = prefs.getStringList(AppConstants.browsingHistoryKey) ?? [];
    raw.add(entry.encode());
    // Cap at maxHistoryEntries
    if (raw.length > AppConstants.maxHistoryEntries) {
      raw.removeRange(0, raw.length - AppConstants.maxHistoryEntries);
    }
    await prefs.setStringList(AppConstants.browsingHistoryKey, raw);
  }

  Future<void> clearHistory() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.browsingHistoryKey);
  }
}
