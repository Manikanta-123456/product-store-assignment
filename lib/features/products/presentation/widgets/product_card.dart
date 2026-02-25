import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../../preferences/presentation/providers/preferences_provider.dart';
import '../../../preferences/data/repositories/preferences_repository.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final prefProvider = context.watch<PreferencesProvider>();
    final pref = prefProvider.getPreference(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + preference overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Container(
                        color: AppTheme.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.surfaceVariant,
                        child: const Icon(Icons.broken_image_outlined,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ),
                // Preference badge
                if (pref != Preference.none)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _PreferenceBadge(preference: pref),
                  ),
                // Category chip
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryVariant.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontSize: 18),
                      ),
                      const Spacer(),
                      // Star rating
                      Icon(Icons.star_rounded,
                          size: 16, color: Colors.amber[400]),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating.rate}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.rating.count})',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Like / Dislike buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Like',
                          icon: Icons.thumb_up_alt_rounded,
                          isActive: pref == Preference.liked,
                          activeColor: AppTheme.liked,
                          onTap: () =>
                              prefProvider.toggleLike(product.id),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          label: 'Pass',
                          icon: Icons.thumb_down_alt_rounded,
                          isActive: pref == Preference.disliked,
                          activeColor: AppTheme.disliked,
                          onTap: () =>
                              prefProvider.toggleDislike(product.id),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceBadge extends StatelessWidget {
  final Preference preference;
  const _PreferenceBadge({required this.preference});

  @override
  Widget build(BuildContext context) {
    final isLiked = preference == Preference.liked;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLiked
            ? AppTheme.liked.withValues(alpha: 0.9)
            : AppTheme.disliked.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLiked
                ? Icons.thumb_up_alt_rounded
                : Icons.thumb_down_alt_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isLiked ? 'Liked' : 'Passed',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ActionButton({
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
          foregroundColor: isActive ? activeColor : AppTheme.textSecondary,
          side: BorderSide(
            color: isActive ? activeColor : AppTheme.textSecondary.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1,
          ),
          backgroundColor:
              isActive ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
