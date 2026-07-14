import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Search everything...',
                          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
                          suffixIcon: const Icon(Icons.close, color: AppTheme.onSurfaceVariant),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(label: 'All', isActive: true),
                    _FilterChip(label: 'Daily Portions'),
                    _FilterChip(label: 'Properties'),
                    _FilterChip(label: 'Kingdom Projects'),
                    _FilterChip(label: 'Library'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search Results',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onBackground)),
                    const SizedBox(height: 16),
                    _SearchResultCard(
                      icon: Icons.menu_book_rounded,
                      iconBg: AppTheme.surfaceContainer,
                      badge: 'Daily Portion',
                      title: 'Walking by Faith',
                      subtitle: 'A devotional on trusting God\'s timing and navigating life\'s uncertainties with a steadfast heart grounded in scripture.',
                    ),
                    const SizedBox(height: 12),
                    _SearchResultCard(
                      icon: Icons.home_rounded,
                      iconBg: AppTheme.surfaceContainer,
                      badge: 'Property',
                      title: 'Serene Valley Farm',
                      subtitle: 'Sustainable 5-acre farmland in Lagos suitable for diverse agricultural development and long-term stewardship initiatives.',
                    ),
                    const SizedBox(height: 12),
                    _SearchResultCard(
                      icon: Icons.favorite_rounded,
                      iconBg: AppTheme.surfaceContainer,
                      badge: 'Kingdom Project',
                      title: 'Water for All',
                      subtitle: 'Clean water initiative providing sustainable borehole systems for rural communities lacking basic infrastructure.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _FilterChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryContainer : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: isActive ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant,
      )),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String badge;
  final String title;
  final String subtitle;

  const _SearchResultCard({required this.icon, required this.iconBg, required this.badge, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primaryContainer, fill: 1),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(20)),
                  child: Text(badge, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                ),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.onBackground)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}
