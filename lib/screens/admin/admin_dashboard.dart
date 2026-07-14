import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _supabaseService = SupabaseService();
  int _pendingSellerRequests = 0;
  int _pendingTrustedRequests = 0;
  int _pendingProperties = 0;
  int _pendingProjects = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final requests = await _supabaseService.getPendingVerificationRequests();
    final sellerCount = requests.where((r) => r['request_type'] == 'seller').length;
    final trustedCount = requests.where((r) => r['request_type'] == 'trusted_member').length;
    final props = await _supabaseService.getPendingProperties();
    final projects = await _supabaseService.getPendingProjects();
    if (mounted) setState(() {
      _pendingSellerRequests = sellerCount;
      _pendingTrustedRequests = trustedCount;
      _pendingProperties = props.length;
      _pendingProjects = projects.length;
    });
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
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                  ),
                  const Spacer(),
                  Text('Admin Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 22)),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadCounts,
                    icon: const Icon(Icons.refresh, color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _StatCard(
                        label: 'Seller Requests',
                        count: _pendingSellerRequests,
                        icon: Icons.storefront_outlined,
                        color: AppTheme.primaryContainer,
                        onTap: () => Navigator.pushNamed(context, '/admin-requests', arguments: 'seller'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        label: 'Trusted Requests',
                        count: _pendingTrustedRequests,
                        icon: Icons.verified_user_outlined,
                        color: AppTheme.tertiary,
                        onTap: () => Navigator.pushNamed(context, '/admin-requests', arguments: 'trusted_member'),
                      )),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _StatCard(
                        label: 'Property Approvals',
                        count: _pendingProperties,
                        icon: Icons.home_outlined,
                        color: const Color(0xFF4A6572),
                        onTap: () => Navigator.pushNamed(context, '/admin-properties'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        label: 'Project Approvals',
                        count: _pendingProjects,
                        icon: Icons.diversity_1_outlined,
                        color: const Color(0xFF6B4A6B),
                        onTap: () => Navigator.pushNamed(context, '/admin-projects'),
                      )),
                    ]),
                    const SizedBox(height: 32),
                    Text('Actions',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                    const SizedBox(height: 16),
                    _ActionTile(
                      icon: Icons.storefront_outlined,
                      title: 'Seller Verification Requests',
                      subtitle: '$_pendingSellerRequests pending',
                      onTap: () => Navigator.pushNamed(context, '/admin-requests', arguments: 'seller'),
                    ),
                    _ActionTile(
                      icon: Icons.verified_user_outlined,
                      title: 'Trusted Member Requests',
                      subtitle: '$_pendingTrustedRequests pending',
                      onTap: () => Navigator.pushNamed(context, '/admin-requests', arguments: 'trusted_member'),
                    ),
                    _ActionTile(
                      icon: Icons.home_outlined,
                      title: 'Property Approvals',
                      subtitle: '$_pendingProperties pending',
                      onTap: () => Navigator.pushNamed(context, '/admin-properties'),
                    ),
                    _ActionTile(
                      icon: Icons.diversity_1_outlined,
                      title: 'Kingdom Project Approvals',
                      subtitle: '$_pendingProjects pending',
                      onTap: () => Navigator.pushNamed(context, '/admin-projects'),
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

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({required this.label, required this.count, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text('$count', style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppTheme.onSurface, fontSize: 32, fontWeight: FontWeight.w600)),
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.primaryContainer),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}