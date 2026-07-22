import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final bool isSaved;
  final VoidCallback? onSaveToggle;
  final VoidCallback? onTap;

  const PropertyCard({
    super.key,
    required this.property,
    this.isSaved = false,
    this.onSaveToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = property.images.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outlineVariant),
          boxShadow: [AppTheme.ambientShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: hasImages
                    ? _buildImage(context, property.images.first)
                    : _buildPlaceholder(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              property.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    property.location,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.formattedPrice,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Verified Seller',
                          style: TextStyle(color: AppTheme.onSurface),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 14, color: Colors.orange, fill: 1),
                        const SizedBox(width: 2),
                        const Text('4.8'),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceContainer,
                    foregroundColor: AppTheme.primary,
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('View Details', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: AppTheme.surfaceVariant,
          child: const Center(
            child: Icon(Icons.image_outlined, size: 48, color: AppTheme.outlineVariant),
          ),
        ),
        _buildCategoryBadge(context),
        if (onSaveToggle != null) _buildSaveButton(),
      ],
    );
  }

  Widget _buildImage(BuildContext context, String imageUrl) {
    return Stack(
      children: [
        Image.network(
          imageUrl,
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppTheme.surfaceVariant,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        ),
        _buildCategoryBadge(context),
        if (onSaveToggle != null) _buildSaveButton(),
      ],
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          property.category,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: GestureDetector(
        onTap: onSaveToggle,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isSaved ? Colors.red : AppTheme.outline,
          ),
        ),
      ),
    );
  }
}
