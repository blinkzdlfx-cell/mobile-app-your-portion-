import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class DailyPortionScreen extends StatefulWidget {
  const DailyPortionScreen({super.key});

  @override
  State<DailyPortionScreen> createState() => _DailyPortionScreenState();
}

class _DailyPortionScreenState extends State<DailyPortionScreen> {
  final _supabaseService = SupabaseService();
  bool _isBookmarked = false;
  bool _loaded = false;
  static const _portionId = '00000000-0000-0000-0000-000000000001';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadBookmarkStatus();
    }
  }

  Future<void> _loadBookmarkStatus() async {
    final bookmarked = await _supabaseService.isPortionBookmarked(_portionId);
    if (mounted) setState(() => _isBookmarked = bookmarked);
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await _supabaseService.removeBookmarkedPortion(_portionId);
    } else {
      await _supabaseService.bookmarkPortion(_portionId);
    }
    if (mounted) setState(() => _isBookmarked = !_isBookmarked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.02),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Today's Portion",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _toggleBookmark,
                        icon: Icon(
                          _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: _isBookmarked ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
                          fill: _isBookmarked ? 1 : 0,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined, color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sermon info card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBright,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF000000).withValues(alpha: 0.02),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOPIC',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: AppTheme.primaryContainer,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Walking by Faith',
                                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        color: AppTheme.primary,
                                        fontSize: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Thursday',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '25 June',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 32, color: AppTheme.outlineVariant),
                          Row(
                            children: [
                              _InfoChip(icon: Icons.person_outline, label: 'Minister', value: 'Pastor John Doe'),
                              const SizedBox(width: 16),
                              _InfoChip(icon: Icons.menu_book, label: 'Bible Text', value: 'Hebrews 11:1'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Scripture reading
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF2F2F2)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF000000).withValues(alpha: 0.03),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Scripture Reading',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.primary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'Hebrews 11:1',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '"Now faith is the substance of things hoped for, the evidence of things not seen."',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.onSurface,
                              fontStyle: FontStyle.italic,
                              height: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Sermon notes
                    _SectionTitle(text: 'Sermon Notes'),
                    const SizedBox(height: 16),
                    Text(
                      'Faith is not merely a mental ascent to a set of propositions. It is a profound, active trust in the character and promises of God. When the writer of Hebrews describes faith as "substance" and "evidence," they are speaking of a concrete reality that anchors our souls even when our circumstances seem uncertain.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'The Nature of Substance',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'To have substance means there is weight to our hope. It is not wishful thinking. Just as a title deed proves ownership of a property you may not yet occupy, faith proves the reality of the spiritual inheritance God has prepared for us.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Prayer points
                    _SectionTitle(text: 'Prayer Points'),
                    const SizedBox(height: 16),
                    _PrayerPoint(number: '1', text: 'Pray for wisdom to navigate daily challenges with a heavenly perspective.'),
                    const SizedBox(height: 12),
                    _PrayerPoint(number: '2', text: 'Pray for spiritual growth, that your roots may grow deep into God\'s love.'),
                    const SizedBox(height: 12),
                    _PrayerPoint(number: '3', text: 'Pray for the strength and courage to obey God\'s Word, even when it is difficult.'),
                    const SizedBox(height: 32),
                    // Key takeaways
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                        boxShadow: [AppTheme.ambientShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Key Takeaways',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _TakeawayItem(text: 'Faith provides concrete assurance for things we cannot yet see.'),
                          const SizedBox(height: 12),
                          _TakeawayItem(text: 'Hope is grounded in the unchanging character of God.'),
                          const SizedBox(height: 12),
                          _TakeawayItem(text: 'Walking by faith is an active, daily choice, not a passive state.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Reflection
                    _SectionTitle(text: "Today's Reflection"),
                    const SizedBox(height: 8),
                    Text(
                      "How does today's portion apply to your life right now?",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        maxLines: 6,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Write your thoughts here...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.outlineVariant,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.save_outlined, size: 20),
                        label: const Text('Save Reflection'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          minimumSize: const Size(160, 48),
                          side: BorderSide.none,
                          backgroundColor: AppTheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.9),
                border: Border(top: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.2))),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.ios_share, size: 20),
                        label: const Text("Share Today's Portion"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.onSurface,
                          minimumSize: const Size(double.infinity, 56),
                          backgroundColor: const Color(0xFFF8FAF9),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.done_all, size: 20),
                        label: const Text('Mark as Read'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryContainer,
                          foregroundColor: AppTheme.onPrimary,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: AppTheme.primaryContainer.withValues(alpha: 0.15),
                        ),
                      ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 20, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
              Text(value, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: AppTheme.primary,
      ),
    );
  }
}

class _PrayerPoint extends StatelessWidget {
  final String number;
  final String text;
  const _PrayerPoint({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TakeawayItem extends StatelessWidget {
  final String text;
  const _TakeawayItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppTheme.primaryContainer, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
