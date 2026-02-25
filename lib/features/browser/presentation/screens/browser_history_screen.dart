import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/browser_history_repository.dart';
import '../providers/browser_provider.dart';
import 'browser_screen.dart';

class BrowserHistoryScreen extends StatelessWidget {
  const BrowserHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final browserProvider = context.watch<BrowserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded,
                color: AppTheme.primary, size: 20),
            SizedBox(width: 8),
            Text('Browsing History'),
          ],
        ),
        actions: [
          if (browserProvider.history.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: AppTheme.accent),
              onPressed: () => _confirmClear(context, browserProvider),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: browserProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : browserProvider.history.isEmpty
              ? const _EmptyHistory()
              : _HistoryList(history: browserProvider.history),
    );
  }

  void _confirmClear(BuildContext context, BrowserProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Clear History',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This will permanently delete all browsing history.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Clear',
                style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<HistoryEntry> history;
  const _HistoryList({required this.history});

  @override
  Widget build(BuildContext context) {
    // Group by date
    final Map<String, List<HistoryEntry>> grouped = {};
    for (final entry in history) {
      final key = _formatDate(entry.visitedAt);
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    final sections = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      itemCount: sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = sections[sectionIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Text(
                section.key,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...section.value.map(
              (entry) => _HistoryTile(entry: entry),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDay = DateTime(dt.year, dt.month, dt.day);

    if (entryDay == today) return 'Today';
    if (entryDay == yesterday) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryVariant.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child:
            const Icon(Icons.language_rounded, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        entry.title,
        style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        entry.url,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(entry.visitedAt),
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                BrowserScreen(url: entry.url, title: entry.title),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded,
              size: 72, color: AppTheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No browsing history yet',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Open a product in the browser to track your visits.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
