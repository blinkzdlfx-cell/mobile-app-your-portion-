import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  final _supabaseService = SupabaseService();
  String _type = 'seller';
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) _type = args;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await _supabaseService.getPendingVerificationRequests();
    final filtered = all.where((r) => r['request_type'] == _type).toList();
    if (mounted) setState(() { _requests = filtered; _loading = false; });
  }

  String get _title => _type == 'seller' ? 'Seller Requests' : 'Trusted Member Requests';

  Future<void> _approve(Map<String, dynamic> req) async {
    await _supabaseService.approveVerificationRequest(
      req['id'] as String,
      req['user_id'] as String,
      _type,
    );
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_type == 'seller' ? 'Seller' : 'Trusted Member'} approved'),
          backgroundColor: AppTheme.primaryContainer));
    }
  }

  void _reject(Map<String, dynamic> req) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Request'),
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
              await _supabaseService.rejectVerificationRequest(req['id'] as String, noteController.text.trim());
              _load();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request rejected'), backgroundColor: AppTheme.error));
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
                  Text(_title,
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
                  : _requests.isEmpty
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.outlineVariant),
                            const SizedBox(height: 16),
                            Text('No pending requests',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                          ]),
                        ))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          itemCount: _requests.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final r = _requests[i];
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(r['request_type'] == 'seller' ? 'SELLER' : 'TRUSTED MEMBER',
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: AppTheme.primaryContainer, fontWeight: FontWeight.w600)),
                                      ),
                                      Text('Pending',
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: AppTheme.onSurfaceVariant)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(r['full_name'] as String? ?? 'Unknown',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                  if (r['phone'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text('Phone: ${r['phone']}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                                  ],
                                  if (r['reason'] != null && (r['reason'] as String).isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(r['reason'] as String,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                                  ],
                                  const SizedBox(height: 16),
                                  Row(children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _approve(r),
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
                                        onPressed: () => _reject(r),
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