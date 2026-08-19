import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/skeleton/skeleton_layouts.dart';
import '../../models/daily_portion.dart';

class DailyPortionScreen extends StatefulWidget {
  const DailyPortionScreen({super.key, this.initialPortionId});

  final String? initialPortionId;

  @override
  State<DailyPortionScreen> createState() => _DailyPortionScreenState();
}

class _DailyPortionScreenState extends State<DailyPortionScreen> {
  final _supabaseService = SupabaseService();
  final _reflectionCtrl = TextEditingController();

  DailyPortion? _portion;
  bool _loading = true;
  bool _isBookmarked = false;
  bool _isRead = false;
  bool _savingReflection = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reflectionCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final id = widget.initialPortionId;
      final portion = id != null
          ? await _supabaseService.getPortionById(id)
          : await _supabaseService.getTodayPortion();
      if (portion == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final results = await Future.wait([
        _supabaseService.isPortionBookmarked(portion.id),
        _supabaseService.isPortionRead(portion.id),
        _supabaseService.getPortionReflection(portion.id),
      ]);
      final bookmarked = results[0] as bool;
      final isRead = results[1] as bool;
      final reflection = results[2] as String?;
      if (mounted) {
        setState(() {
          _portion = portion;
          _isBookmarked = bookmarked;
          _isRead = isRead;
          _reflectionCtrl.text = reflection ?? '';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleBookmark() async {
    final portion = _portion;
    if (portion == null) return;
    if (_isBookmarked) {
      await _supabaseService.removeBookmarkedPortion(portion.id);
    } else {
      await _supabaseService.bookmarkPortion(portion.id);
    }
    if (mounted) setState(() => _isBookmarked = !_isBookmarked);
  }

  Future<void> _markRead() async {
    final portion = _portion;
    if (portion == null || _isRead) return;
    await _supabaseService.markPortionRead(portion.id);
    if (mounted) {
      setState(() => _isRead = true);
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text("Today's portion marked as read"),
          backgroundColor: AppTheme.primaryContainer,
        ),
      );
    }
  }

  Future<void> _saveReflection() async {
    final portion = _portion;
    if (portion == null || _reflectionCtrl.text.trim().isEmpty) return;
    setState(() => _savingReflection = true);
    await _supabaseService.savePortionReflection(portion.id, _reflectionCtrl.text);
    if (mounted) {
      setState(() => _savingReflection = false);
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('Reflection saved'),
          backgroundColor: AppTheme.primaryContainer,
        ),
      );
    }
  }

  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text('Sharing coming soon'),
        backgroundColor: AppTheme.secondaryContainer,
      ),
    );
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
                    icon:  Icon(Icons.arrow_back, color: AppTheme.primary),
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
                  IconButton(
                    onPressed: _portion != null ? _toggleBookmark : null,
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: _isBookmarked ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
                      fill: _isBookmarked ? 1 : 0,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _buildBody(),
            ),
            // Bottom actions
            if (_portion != null)
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
                          onPressed: _share,
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
                          onPressed: _isRead ? null : _markRead,
                          icon: Icon(
                            _isRead ? Icons.check_circle : Icons.done_all,
                            size: 20,
                          ),
                          label: Text(_isRead ? 'Read' : 'Mark as Read'),
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

  Widget _buildBody() {
    if (_loading) {
      return const SkeletonArticle();
    }
    final portion = _portion;
    if (portion == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories_outlined, size: 64, color: AppTheme.outlineVariant),
              const SizedBox(height: 16),
              Text(
                'No portion published yet',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for today\'s devotional.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final dateLabel = _formatDate(portion.publishDate);
    final scripture = portion.scriptureReference;
    final category = portion.category;

    return SingleChildScrollView(
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
                            category?.toUpperCase() ?? 'DEVOTIONAL',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.primaryContainer,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            portion.title,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppTheme.primary,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (dateLabel != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Published',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            dateLabel,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (scripture != null) ...[
                   Divider(height: 32, color: AppTheme.outlineVariant),
                  Row(
                    children: [
                      _InfoChip(icon: Icons.menu_book, label: 'Bible Text', value: scripture),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Scripture reading
          if (scripture != null) ...[
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
                          scripture,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
          // Portion content
          ..._buildContent(portion.paragraphs),
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
              controller: _reflectionCtrl,
              maxLines: 6,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Write your thoughts here...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.outlineVariant,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _savingReflection ? null : _saveReflection,
              icon: _savingReflection
                  ?  SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                    )
                  : const Icon(Icons.save_outlined, size: 20),
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
    );
  }

  List<Widget> _buildContent(List<String> paragraphs) {
    if (paragraphs.isEmpty) return const [];
    final widgets = <Widget>[];
    for (var i = 0; i < paragraphs.length; i++) {
      if (i > 0) widgets.add(const SizedBox(height: 16));
      widgets.add(
        Text(
          paragraphs[i],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceVariant,
            height: 1.8,
          ),
        ),
      );
    }
    return widgets;
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
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
