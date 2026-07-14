import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class AdminProjectsScreen extends StatefulWidget {
  const AdminProjectsScreen({super.key});

  @override
  State<AdminProjectsScreen> createState() => _AdminProjectsScreenState();
}

class _AdminProjectsScreenState extends State<AdminProjectsScreen> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final projects = await _supabaseService.getPendingProjects();
    if (mounted) setState(() { _projects = projects; _loading = false; });
  }

  Future<void> _approve(String id) async {
    await _supabaseService.approveProject(id);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project approved'), backgroundColor: AppTheme.primaryContainer));
    }
  }

  void _reject(String id) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Project'),
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
              await _supabaseService.rejectProject(id, noteController.text.trim());
              _load();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project rejected'), backgroundColor: AppTheme.error));
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
                  Text('Project Approvals',
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
                  : _projects.isEmpty
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.outlineVariant),
                            const SizedBox(height: 16),
                            Text('No pending projects',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                          ]),
                        ))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          itemCount: _projects.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final p = _projects[i];
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
                                  if (p['description'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(p['description'] as String,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                  if (p['goal_amount'] != null) ...[
                                    const SizedBox(height: 8),
                                    Text('Goal: \$${(p['goal_amount'] as num).toStringAsFixed(0)}',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryContainer)),
                                  ],
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