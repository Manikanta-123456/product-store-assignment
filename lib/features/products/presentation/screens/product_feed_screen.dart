import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../presentation/providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../../../preferences/presentation/screens/liked_products_screen.dart';
import '../../../browser/presentation/screens/browser_history_screen.dart';

class ProductFeedScreen extends StatelessWidget {
  const ProductFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront_rounded,
                  color: Colors.white, size: 17),
            ),
            const SizedBox(width: 8),
            const Text('StyleStore'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Liked products',
            icon: const Icon(Icons.favorite_rounded, color: AppTheme.liked),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const LikedProductsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Browsing history',
            icon: const Icon(Icons.history_rounded, color: AppTheme.primary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const BrowserHistoryScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          switch (provider.status) {
            case ProductStatus.initial:
            case ProductStatus.loading:
              return const _LoadingView();
            case ProductStatus.failure:
              return _ErrorView(
                message: provider.errorMessage,
                onRetry: provider.fetchProducts,
              );
            case ProductStatus.success:
              return _ProductList(provider: provider);
          }
        },
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 16),
          Text('Fetching products…',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 64, color: AppTheme.accent.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text('Oops!',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final ProductProvider provider;
  const _ProductList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final categories = provider.categories;
    final products = provider.filteredProducts;

    return Column(
      children: [
        // Category filter chips
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final cat = categories[i];
              final isSelected = provider.selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => provider.setCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      _formatCategory(cat),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Product list
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Text(
                    'No products in this category.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: provider.fetchProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: products.length,
                    itemBuilder: (context, index) =>
                        ProductCard(product: products[index]),
                  ),
                ),
        ),
      ],
    );
  }

  String _formatCategory(String cat) {
    if (cat == 'all') return 'All';
    return cat
        .split(' ')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }
}
