import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../../preferences/presentation/providers/preferences_provider.dart';
import '../../../preferences/data/repositories/preferences_repository.dart';
import '../../../browser/presentation/screens/browser_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final prefProvider = context.watch<PreferencesProvider>();
    final pref = prefProvider.getPreference(product.id);
    final isLiked = pref == Preference.liked;
    final isDisliked = pref == Preference.disliked;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Collapsing App Bar with product image ─────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.surfaceVariant,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.image,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const ColoredBox(
                      color: AppTheme.surfaceVariant,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: AppTheme.surfaceVariant,
                      child: Icon(Icons.broken_image_outlined,
                          color: AppTheme.textSecondary, size: 48),
                    ),
                  ),
                  // Gradient overlay for readability
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.5, 1.0],
                        colors: [Colors.transparent, AppTheme.surface],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Rating row
                  Row(
                    children: [
                      _Chip(label: product.category),
                      const Spacer(),
                      Icon(Icons.star_rounded,
                          size: 18, color: Colors.amber[400]),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating.rate}  ·  ${product.rating.count} reviews',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(product.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),

                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.5,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Action buttons ─────────────────────────────────────
                  Row(
                    children: [
                      // Like
                      Expanded(
                        child: _PrimaryButton(
                          label: isLiked ? 'Liked ✓' : 'Like',
                          icon: Icons.thumb_up_alt_rounded,
                          isActive: isLiked,
                          activeColor: AppTheme.liked,
                          onTap: () => prefProvider.toggleLike(product.id),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Dislike
                      Expanded(
                        child: _PrimaryButton(
                          label: isDisliked ? 'Passed ✓' : 'Pass',
                          icon: Icons.thumb_down_alt_rounded,
                          isActive: isDisliked,
                          activeColor: AppTheme.disliked,
                          onTap: () =>
                              prefProvider.toggleDislike(product.id),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Open in browser
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BrowserScreen(
                              url: product.productUrl,
                              title: product.title,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_browser_rounded),
                      label: const Text('Open in Browser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.6), width: 0.8),
      ),
      child: Text(label,
          style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 13),
          foregroundColor: isActive ? activeColor : AppTheme.textSecondary,
          side: BorderSide(
            color: isActive
                ? activeColor
                : AppTheme.textSecondary.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1,
          ),
          backgroundColor:
              isActive ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
