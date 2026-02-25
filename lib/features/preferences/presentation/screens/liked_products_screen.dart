import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../providers/preferences_provider.dart';

class LikedProductsScreen extends StatelessWidget {
  const LikedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefProvider = context.watch<PreferencesProvider>();
    final productProvider = context.watch<ProductProvider>();

    final likedIds = prefProvider.likedIds;
    final likedProducts = productProvider.allProducts
        .where((p) => likedIds.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded,
                color: AppTheme.liked, size: 20),
            SizedBox(width: 8),
            Text('Liked Products'),
          ],
        ),
      ),
      body: likedProducts.isEmpty
          ? _EmptyState(isLoading: prefProvider.isLoading,)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Text(
                    '${likedProducts.length} product${likedProducts.length != 1 ? 's' : ''} liked',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: likedProducts.length,
                    itemBuilder: (context, index) =>
                        ProductCard(product: likedProducts[index]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isLoading;
  const _EmptyState({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border_rounded,
              size: 72, color: AppTheme.liked.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'No liked products yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the 👍 on any product to save it here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
