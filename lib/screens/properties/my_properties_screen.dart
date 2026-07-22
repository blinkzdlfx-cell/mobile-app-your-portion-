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
    setState(() => _loading = true);
    final props = await _supabaseService.getMyProperties();
    if (mounted) setState(() { _properties = props; _loading = false; });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return const Color(0xFF137333);
      case 'pending': return const Color(0xFFB06000);
      case 'rejected': return const Color(0xFFC62828);
      case 'draft': return const Color(0xFF5C6BC0);
      case 'archived': return const Color(0xFF757575);
      default: return AppTheme.onSurfaceVariant;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'approved': return const Color(0xFFE6F4EA);
      case 'pending': return const Color(0xFFFFF3E0);
      case 'rejected': return const Color(0xFFFFEBEE);
      case 'draft': return const Color(0xFFE8EAF6);
      case 'archived': return const Color(0xFFF5F5F5);
      default: return AppTheme.surfaceContainerLow;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle;
      case 'pending': return Icons.hourglass_top;
      case 'rejected': return Icons.cancel;
      case 'draft': return Icons.edit_note;
      case 'archived': return Icons.inventory_2;
      default: return Icons.circle;
    }
  }

  Future<void> _confirmDelete(Property p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${p.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _supabaseService.deleteProperty(p.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property deleted'), backgroundColor: AppTheme.primaryContainer),
          );
          _load();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  Future<void> _confirmArchive(Property p) async {
    try {
      await _supabaseService.archiveProperty(p.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property archived'), backgroundColor: AppTheme.primaryContainer),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to archive: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _confirmReactivate(Property p) async {
    try {
      await _supabaseService.reactivateProperty(p.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property reactivated'), backgroundColor: AppTheme.primaryContainer),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reactivate: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
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
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant)),
                  const Spacer(),
                  Text('My Properties',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 22)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.primary),
                    onPressed: _load,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
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
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, i) => _buildPropertyCard(_properties[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72, height: 72,
                  child: p.images.isNotEmpty
                      ? Image.network(p.images.first, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _thumbnailPlaceholder())
                      : _thumbnailPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('\$${p.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryContainer, fontWeight: FontWeight.w600, fontSize: 18)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 14, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(child: Text(p.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _statusBg(p.status), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(p.status), size: 14, color: _statusColor(p.status)),
                    const SizedBox(width: 4),
                    Text(p.status.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: _statusColor(p.status), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),

          // Rejection reason
          if (p.status == 'rejected' && p.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFFC62828)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p.rejectionReason!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFC62828)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Actions per status
          const SizedBox(height: 12),
          _buildActions(p),
        ],
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: AppTheme.surfaceVariant,
      child: const Icon(Icons.image_outlined, size: 32, color: AppTheme.outlineVariant),
    );
  }

  Widget _buildActions(Property p) {
    final actions = <Widget>[];

    switch (p.status) {
      case 'draft':
        actions.addAll([
          _ActionButton(label: 'Edit', icon: Icons.edit, color: AppTheme.primary, onTap: () => _editProperty(p)),
          _ActionButton(label: 'Submit', icon: Icons.send, color: const Color(0xFF137333), onTap: () => _submitDraft(p)),
          _ActionButton(label: 'Delete', icon: Icons.delete_outline, color: AppTheme.error, onTap: () => _confirmDelete(p)),
        ]);
      case 'pending':
        actions.addAll([
          _ActionButton(label: 'Edit', icon: Icons.edit, color: AppTheme.primary, onTap: () => _editProperty(p)),
          _ActionButton(label: 'Delete', icon: Icons.delete_outline, color: AppTheme.error, onTap: () => _confirmDelete(p)),
        ]);
      case 'approved':
        actions.addAll([
          _ActionButton(label: 'Edit', icon: Icons.edit, color: AppTheme.primary, onTap: () => _editProperty(p)),
          _ActionButton(label: 'Archive', icon: Icons.archive_outlined, color: const Color(0xFF757575), onTap: () => _confirmArchive(p)),
          _ActionButton(label: 'Delete', icon: Icons.delete_outline, color: AppTheme.error, onTap: () => _confirmDelete(p)),
        ]);
      case 'rejected':
        actions.addAll([
          _ActionButton(label: 'Edit & Resubmit', icon: Icons.edit, color: AppTheme.primary, onTap: () => _editProperty(p)),
          _ActionButton(label: 'Delete', icon: Icons.delete_outline, color: AppTheme.error, onTap: () => _confirmDelete(p)),
        ]);
      case 'archived':
        actions.addAll([
          _ActionButton(label: 'Reactivate', icon: Icons.unarchive_outlined, color: const Color(0xFF137333), onTap: () => _confirmReactivate(p)),
          _ActionButton(label: 'Delete', icon: Icons.delete_outline, color: AppTheme.error, onTap: () => _confirmDelete(p)),
        ]);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions,
    );
  }

  void _editProperty(Property p) {
    Navigator.pushNamed(context, '/create-property', arguments: p).then((_) => _load());
  }

  Future<void> _submitDraft(Property p) async {
    try {
      await _supabaseService.updateProperty(p.id, {'status': 'pending', 'rejection_reason': null});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property submitted for review'), backgroundColor: AppTheme.primaryContainer),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
