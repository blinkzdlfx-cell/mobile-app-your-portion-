import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../models/property.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final _supabaseService = SupabaseService();
  List<Property> _properties = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final props = await _supabaseService.getMyProperties();
    if (mounted) setState(() { _properties = props; _loading = false; });
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
                  Text('My Properties',
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
                                Icon(Icons.home_outlined, size: 64, color: AppTheme.outlineVariant),
                                const SizedBox(height: 16),
                                Text('No properties yet',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                                const SizedBox(height: 8),
                                Text('Create your first listing to get started.',
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
                                        child: Text(p.title,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: p.status == 'approved' ? const Color(0xFFE6F4EA) : AppTheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(p.status.toUpperCase(),
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: p.status == 'approved' ? const Color(0xFF137333) : AppTheme.onSurfaceVariant,
                                          )),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('\$${p.price.toStringAsFixed(0)}',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: AppTheme.primaryContainer, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    const Icon(Icons.location_on, size: 16, color: AppTheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(p.location,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant))),
                                  ]),
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