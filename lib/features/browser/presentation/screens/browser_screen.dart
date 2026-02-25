import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../presentation/providers/browser_provider.dart';

class BrowserScreen extends StatefulWidget {
  final String url;
  final String title;

  const BrowserScreen({super.key, required this.url, required this.title});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;
  String _currentTitle = '';
  String _currentUrl = '';
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    _currentUrl = widget.url;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onProgress: (progress) {
            setState(() => _loadingProgress = progress);
          },
          onPageFinished: (url) async {
            final title = await _controller.getTitle() ?? url;
            final canBack = await _controller.canGoBack();
            final canForward = await _controller.canGoForward();
            if (!mounted) return;

            setState(() {
              _isLoading = false;
              _currentTitle = title;
              _currentUrl = url;
              _canGoBack = canBack;
              _canGoForward = canForward;
            });

            // Record in browsing history
            if (mounted) {
              context.read<BrowserProvider>().recordVisit(
                    url: url,
                    title: title,
                  );
            }
          },
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load: ${error.description}')),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentTitle.isNotEmpty ? _currentTitle : 'Loading…',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _currentUrl,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: AppTheme.surfaceVariant,
                  color: AppTheme.primary,
                  minHeight: 3,
                ),
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
      bottomNavigationBar: Container(
        height: 52,
        color: AppTheme.surfaceVariant,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: _canGoBack ? AppTheme.textPrimary : AppTheme.textSecondary,
              onPressed: _canGoBack ? () => _controller.goBack() : null,
            ),
            IconButton(
              icon:
                  const Icon(Icons.arrow_forward_ios_rounded, size: 20),
              color:
                  _canGoForward ? AppTheme.textPrimary : AppTheme.textSecondary,
              onPressed:
                  _canGoForward ? () => _controller.goForward() : null,
            ),
            IconButton(
              icon: const Icon(Icons.home_rounded, size: 22),
              color: AppTheme.textPrimary,
              onPressed: () =>
                  _controller.loadRequest(Uri.parse(widget.url)),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 20),
              color: AppTheme.primary,
              tooltip: 'Current URL: $_currentUrl',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: SelectableText(_currentUrl),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
