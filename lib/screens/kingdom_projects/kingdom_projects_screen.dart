import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class KingdomProjectsScreen extends StatelessWidget {
  const KingdomProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text('Your Portion',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 22)),
                  const Spacer(),
                  const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                ],
              ),
            ),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    size: 40,
                    color: AppTheme.primaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Coming Soon',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Kingdom Projects is on its way! We\'re building a way for you to support and fund faith-driven initiatives in your community.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Icon(
                  Icons.favorite_outline_rounded,
                  size: 48,
                  color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/marketplace');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool isActive;
  const _FilterChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryContainer : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: isActive ? AppTheme.onPrimaryContainer : AppTheme.onSurface)),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String category, location, title, progressLabel, status;
  final String? description;
  final double progress;

  const _ProjectCard({required this.category, required this.location, required this.title, this.description, required this.progress, required this.progressLabel, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F2F2)),
        boxShadow: [AppTheme.ambientShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(child: Icon(Icons.image_outlined, size: 48, color: AppTheme.outlineVariant)),
                Positioned(
                  top: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 8, height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: status == 'Active' ? AppTheme.primaryContainer : AppTheme.outline)),
                      const SizedBox(width: 6),
                      Text(status, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.primary)),
                    ]),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryContainer, letterSpacing: 1.2, fontSize: 12)),
                    Row(children: [
                      const Icon(Icons.location_on, size: 16, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(location, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                    ]),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                const SizedBox(height: 8),
                Text(description ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(progressLabel, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
                  Text('${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryContainer, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer, foregroundColor: AppTheme.onPrimary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('View Project'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
