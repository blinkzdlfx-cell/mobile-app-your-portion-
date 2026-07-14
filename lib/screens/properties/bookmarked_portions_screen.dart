import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class BookmarkedPortionsScreen extends StatefulWidget {
  const BookmarkedPortionsScreen({super.key});

  @override
  State<BookmarkedPortionsScreen> createState() => _BookmarkedPortionsScreenState();
}

class _BookmarkedPortionsScreenState extends State<BookmarkedPortionsScreen> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _portions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final portions = await _supabaseService.getBookmarkedPortions();
    if (mounted) setState(() { _portions = portions; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Text('Bookmarked Portions',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 22)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _portions.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bookmark_border, size: 64, color: AppTheme.outlineVariant),
                                const SizedBox(height: 16),
                                Text('No bookmarked portions',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                                const SizedBox(height: 8),
                                Text('Bookmark your favorite daily portions to read them later.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          itemCount: _portions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final p = _portions[i];
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(p['title'] as String? ?? '',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.bookmark, color: AppTheme.primaryContainer, fill: 1),
                                        onPressed: () async {
                                          final id = p['id'] as String?;
                                          if (id != null) {
                                            await _supabaseService.removeBookmarkedPortion(id);
                                            _load();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  if (p['content'] != null) ...[
                                    const SizedBox(height: 8),
                                    Text(p['content'] as String,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                                      maxLines: 3, overflow: TextOverflow.ellipsis),
                                  ],
                                ],
                              ),
                            );
                          }),
            ),
          ],
        ),
      ),
    );
  }
}