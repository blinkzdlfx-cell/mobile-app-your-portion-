import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LearningLibraryScreen extends StatelessWidget {
  const LearningLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Text('Library',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 22)),
                  const Spacer(),
                  const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search articles, guides or topics...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.outlineVariant),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
                  Text('View All',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryContainer)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _CategoryCard(icon: Icons.eco_outlined, title: 'Agriculture', subtitle: 'Master the art of biblical farming.')),
                  const SizedBox(width: 12),
                  Expanded(child: _CategoryCard(icon: Icons.home_outlined, title: 'Real Estate', subtitle: 'Building foundations for the kingdom.')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _CategoryCard(icon: Icons.favorite_outline, title: 'Christian Living', subtitle: 'Daily walks in faith and grace.')),
                  const SizedBox(width: 12),
                  Expanded(child: _CategoryCard(icon: Icons.auto_awesome_outlined, title: 'Stewardship', subtitle: 'Managing resources with wisdom.')),
                ],
              ),
              const SizedBox(height: 32),
              Text('Featured Articles',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _ArticleCard(
                category: 'Stewardship',
                readTime: '5 min read',
                title: 'The Parable of the Talents',
                description: 'Understanding the responsibility of multiplying what you have been given.',
              ),
              const SizedBox(height: 16),
              _ArticleCard(
                category: 'Agriculture',
                readTime: '8 min read',
                title: 'Sustainable Farming Basics',
                description: 'A guide to eco-friendly agriculture based on biblical principles.',
              ),
              const SizedBox(height: 32),
              Text('Recently Added',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _ListItem(title: 'Understanding Property Rights in Scripture'),
              const SizedBox(height: 8),
              _ListItem(title: 'The Heart of a Faithful Steward'),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon; final String title, subtitle;

  const _CategoryCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppTheme.surfaceContainer, shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String category, readTime, title, description;

  const _ArticleCard({required this.category, required this.readTime, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(child: Icon(Icons.image_outlined, size: 48, color: AppTheme.outlineVariant)),
                Positioned(
                  top: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2))),
                    child: Text(category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.primaryContainer, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.schedule, size: 16, color: AppTheme.outline),
                  const SizedBox(width: 4),
                  Text(readTime, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.outline)),
                ]),
                const SizedBox(height: 12),
                Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface, fontSize: 20)),
                const SizedBox(height: 8),
                Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                Row(children: [
                  Text('Read Article', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryContainer)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 18, color: AppTheme.primaryContainer),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  const _ListItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.image_outlined, size: 24, color: AppTheme.outlineVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface)),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
        ],
      ),
    );
  }
}
