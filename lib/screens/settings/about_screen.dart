import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('About Your Portion',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.eco_outlined, size: 44, color: AppTheme.onPrimary),
            ),
            const SizedBox(height: 20),
            Text('Your Portion',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 28)),
            const SizedBox(height: 4),
            Text('Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            _infoCard(context, Icons.auto_stories_outlined, 'Our Mission',
                'To create a faithful community where believers can grow spiritually through daily devotionals, '
                'and steward their resources through ethical property and project marketplace.'),
            const SizedBox(height: 16),
            _infoCard(context, Icons.visibility_outlined, 'Our Vision',
                'A world where faith and stewardship converge — empowering believers to build, '
                'invest, and grow together with integrity and purpose.'),
            const SizedBox(height: 16),
            _infoCard(context, Icons.favorite_outline, 'Our Values',
                'Faith, Community, Stewardship, Transparency, and Integrity guide everything we build.'),
            const SizedBox(height: 32),
            Text('Built with Flutter & Supabase',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.outline)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, IconData icon, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.secondary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariant, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
