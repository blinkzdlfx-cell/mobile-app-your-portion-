import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../models/property.dart';

class SavedPropertiesScreen extends StatefulWidget {
  const SavedPropertiesScreen({super.key});

  @override
  State<SavedPropertiesScreen> createState() => _SavedPropertiesScreenState();
}

class _SavedPropertiesScreenState extends State<SavedPropertiesScreen> {
  final _supabaseService = SupabaseService();
  List<Property> _properties = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await _supabaseService.getSavedPropertyIds();
    final all = await _supabaseService.getProperties();
    final saved = all.where((p) => ids.contains(p.id)).toList();
    if (mounted) setState(() { _properties = saved; _loading = false; });
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
                  Text('Saved Properties',
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
                  : _properties.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite_outline, size: 64, color: AppTheme.outlineVariant),
                                const SizedBox(height: 16),
                                Text('No saved properties',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                                const SizedBox(height: 8),
                                Text('Tap the heart icon on any property to save it here.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          itemCount: _properties.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final p = _properties[i];
                            final initials = p.title.isNotEmpty ? p.title[0].toUpperCase() : '?';
                            return Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                                boxShadow: [AppTheme.ambientShadow],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceVariant,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(child: Text(initials,
                                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                            color: AppTheme.outlineVariant, fontSize: 48))),
                                        Positioned(
                                          top: 16, right: 16,
                                          child: Container(
                                            width: 32, height: 32,
                                            decoration: BoxDecoration(
                                              color: AppTheme.errorContainer,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.favorite, size: 18, color: AppTheme.onErrorContainer, fill: 1),
                                              onPressed: () async {
                                                await _supabaseService.unsaveProperty(p.id);
                                                _load();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.title,
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            color: AppTheme.onSurface)),
                                        const SizedBox(height: 8),
                                        Row(children: [
                                          const Icon(Icons.location_on, size: 20, color: AppTheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(p.location,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant))),
                                        ]),
                                        const SizedBox(height: 12),
                                        Text(p.formattedPrice,
                                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                            color: AppTheme.primaryContainer, fontWeight: FontWeight.w600, fontSize: 28)),
                                      ],
                                    ),
                                  ),
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