import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class AdminPropertiesScreen extends StatefulWidget {
  const AdminPropertiesScreen({super.key});

  @override
  State<AdminPropertiesScreen> createState() => _AdminPropertiesScreenState();
}

class _AdminPropertiesScreenState extends State<AdminPropertiesScreen> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _properties = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final props = await _supabaseService.getPendingProperties();
    if (mounted) setState(() { _properties = props; _loading = false; });
  }

  Future<void> _approve(String id) async {
    await _supabaseService.approveProperty(id);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property approved'), backgroundColor: AppTheme.primaryContainer));
    }
  }

  void _reject(String id) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Property'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(hintText: 'Reason for rejection...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _supabaseService.rejectProperty(id, noteController.text.trim());
              _load();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Property rejected'), backgroundColor: AppTheme.error));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: AppTheme.onError),
            child: const Text('Reject'),
          ),
        ],
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Text('Property Approvals',
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
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.outlineVariant),
                            const SizedBox(height: 16),
                            Text('No pending properties',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                          ]),
                        ))
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
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['title'] as String? ?? '',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('\$${(p['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: AppTheme.primaryContainer, fontWeight: FontWeight.w600, fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    const Icon(Icons.location_on, size: 16, color: AppTheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(p['location'] as String? ?? '',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                                  ]),
                                  const SizedBox(height: 16),
                                  Row(children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _approve(p['id'] as String),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryContainer, foregroundColor: AppTheme.onPrimary,
                                          minimumSize: const Size(double.infinity, 44),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _reject(p['id'] as String),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.error,
                                          side: const BorderSide(color: AppTheme.error),
                                          minimumSize: const Size(double.infinity, 44),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ),
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