// Apple-style skeleton layouts that mirror the real screen structure,
// so the placeholder "fades into" the loaded UI.
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'skeleton.dart';

/// Home — "Today's Portion" card (label, title, scripture, snippet, button).
class SkeletonPortionCard extends StatelessWidget {
  const SkeletonPortionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [AppTheme.ambientShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox(width: 130, height: 12, radius: 6),
            SizedBox(height: 16),
            SkeletonLines(lines: 2, lineHeight: 22, gap: 8),
            SizedBox(height: 12),
            SkeletonBox(width: 90, height: 14, radius: 6),
            SizedBox(height: 16),
            SkeletonLines(lines: 3, lineHeight: 14, gap: 8),
            SizedBox(height: 24),
            SkeletonBox(height: 56, radius: 12),
          ],
        ),
      ),
    );
  }
}

/// Home — category card row (4 items).
class SkeletonCategoryRow extends StatelessWidget {
  const SkeletonCategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Row(
        children: List.generate(
          4,
          (i) => Expanded(
            child: Container(
              height: 120,
              margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SkeletonCircle(size: 48),
                  SizedBox(height: 10),
                  SkeletonBox(width: 64, height: 12, radius: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Daily Portion — full article (title, scripture, paragraphs).
class SkeletonArticle extends StatelessWidget {
  const SkeletonArticle({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
      child: Skeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonLines(lines: 3, lineHeight: 26, gap: 10),
            SizedBox(height: 16),
            SkeletonBox(width: 160, height: 14, radius: 6),
            SizedBox(height: 32),
            SkeletonLines(lines: 4, lineHeight: 16, gap: 10),
            SizedBox(height: 18),
            SkeletonLines(lines: 4, lineHeight: 16, gap: 10),
            SizedBox(height: 18),
            SkeletonLines(lines: 3, lineHeight: 16, gap: 10),
            SizedBox(height: 18),
            SkeletonLines(lines: 4, lineHeight: 16, gap: 10),
            SizedBox(height: 32),
            SkeletonBox(height: 56, radius: 12),
          ],
        ),
      ),
    );
  }
}

/// Bookmarked portions — icon + two text lines per row.
class SkeletonPortionRow extends StatelessWidget {
  const SkeletonPortionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: const Row(
          children: [
            SkeletonCircle(size: 44),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: double.infinity, height: 16, radius: 6),
                  SizedBox(height: 8),
                  SkeletonBox(width: 140, height: 12, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonPortionList extends StatelessWidget {
  const SkeletonPortionList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const SkeletonPortionRow(),
    );
  }
}

/// Property card — mirrors PropertyCard (image, title, location, price).
class SkeletonPropertyCard extends StatelessWidget {
  const SkeletonPropertyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
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
          children: const [
            SkeletonBox(width: double.infinity, height: 160, radius: 8),
            SizedBox(height: 14),
            SkeletonBox(width: 200, height: 20, radius: 6),
            SizedBox(height: 10),
            SkeletonBox(width: 130, height: 12, radius: 6),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 110, height: 26, radius: 6),
                    SizedBox(height: 8),
                    SkeletonBox(width: 150, height: 12, radius: 6),
                  ],
                ),
                SkeletonBox(width: 100, height: 40, radius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonPropertyList extends StatelessWidget {
  const SkeletonPropertyList({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i < itemCount - 1 ? 12 : 0),
          child: const SkeletonPropertyCard(),
        ),
      ),
    );
  }
}

/// Notifications — leading icon + title/subtitle lines per row.
class SkeletonNotificationList extends StatelessWidget {
  const SkeletonNotificationList({super.key, this.itemCount = 7});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 18),
        itemBuilder: (_, _) => const Row(
          children: [
            SkeletonCircle(size: 40),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: double.infinity, height: 14, radius: 6),
                  SizedBox(height: 8),
                  SkeletonBox(width: 180, height: 12, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile — gradient card with avatar, name and badges.
class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.surfaceVariant.withValues(alpha: 0.5)),
          boxShadow: [AppTheme.ambientShadow],
        ),
        child: Column(
          children: const [
            SkeletonCircle(size: 88),
            SizedBox(height: 14),
            SkeletonBox(width: 160, height: 22, radius: 6),
            SizedBox(height: 8),
            SkeletonBox(width: 110, height: 12, radius: 6),
            SizedBox(height: 18),
            SkeletonBox(width: 220, height: 40, radius: 20),
          ],
        ),
      ),
    );
  }
}

/// Kingdom projects — title, progress bar, goal rows.
class SkeletonKingdomProjectCard extends StatelessWidget {
  const SkeletonKingdomProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonLines(lines: 2, lineHeight: 18, gap: 8),
            SizedBox(height: 14),
            SkeletonBox(width: double.infinity, height: 10, radius: 5),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 90, height: 12, radius: 6),
                SkeletonBox(width: 70, height: 12, radius: 6),
              ],
            ),
            SizedBox(height: 14),
            SkeletonBox(width: 160, height: 12, radius: 6),
          ],
        ),
      ),
    );
  }
}

class SkeletonKingdomProjectList extends StatelessWidget {
  const SkeletonKingdomProjectList({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i < itemCount - 1 ? 12 : 0),
          child: const SkeletonKingdomProjectCard(),
        ),
      ),
    );
  }
}

/// Property detail — full-width gallery block.
class SkeletonDetailGallery extends StatelessWidget {
  const SkeletonDetailGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Container(
        width: double.infinity,
        height: 300,
        color: AppTheme.surfaceContainerHigh,
      ),
    );
  }
}

/// Settings / create-property — form-like rows (label + inputs).
class SkeletonFormLines extends StatelessWidget {
  const SkeletonFormLines({super.key, this.inputs = 4});

  final int inputs;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(inputs, (i) => Padding(
            padding: EdgeInsets.only(bottom: i < inputs - 1 ? 20 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 120, height: 12, radius: 6),
                SizedBox(height: 8),
                SkeletonBox(width: double.infinity, height: 52, radius: 12),
              ],
            ),
          )),
          const SizedBox(height: 8),
          const SkeletonBox(width: double.infinity, height: 56, radius: 12),
        ],
      ),
    );
  }
}

/// Search results — mixed property/portion/project rows.
class SkeletonSearchResults extends StatelessWidget {
  const SkeletonSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Skeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header('Daily Portions'),
            const SkeletonPortionRow(),
            const SizedBox(height: 18),
            _header('Properties'),
            const SkeletonPropertyCard(),
            const SizedBox(height: 18),
            const SkeletonPropertyCard(),
            const SizedBox(height: 18),
            _header('Kingdom Projects'),
            const SkeletonKingdomProjectCard(),
          ],
        ),
      ),
    );
  }

  Widget _header(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SkeletonBox(width: 140, height: 18, radius: 6),
    );
  }
}

/// Auth / session check — centered avatar + name lines.
class SkeletonSessionCheck extends StatelessWidget {
  const SkeletonSessionCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Skeleton(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SkeletonCircle(size: 72),
            SizedBox(height: 16),
            SkeletonBox(width: 150, height: 16, radius: 6),
            SizedBox(height: 8),
            SkeletonBox(width: 110, height: 12, radius: 6),
          ],
        ),
      ),
    );
  }
}