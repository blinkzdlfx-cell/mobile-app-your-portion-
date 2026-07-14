import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/supabase_service.dart';

class KingdomProjectsScreen extends StatefulWidget {
  const KingdomProjectsScreen({super.key});

  @override
  State<KingdomProjectsScreen> createState() => _KingdomProjectsScreenState();
}

class _KingdomProjectsScreenState extends State<KingdomProjectsScreen> {
  final _supabaseService = SupabaseService();
  bool _canSell = false;
  bool _myProjects = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['myProjects'] == true) {
        _myProjects = true;
      }
    }
  }

  Future<void> _loadRole() async {
    final canSell = await _supabaseService.canSell();
    if (mounted) setState(() => _canSell = canSell);
  }

  void _showVerificationNeeded() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_outlined, color: AppTheme.primaryContainer, size: 28),
            ),
            const SizedBox(height: 16),
            Text('Seller Verification Required',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 20)),
            const SizedBox(height: 8),
            Text('You need to be verified as a seller to submit kingdom projects. Contact an admin or apply in your profile settings.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.of(ctx).pop(); Navigator.pushNamed(context, '/profile'); },
                child: const Text('Go to Profile'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Text('Your Portion',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 22)),
                      const Spacer(),
                      const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                    ],
                  ),
                  const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 48),
                        Text(
                          _myProjects ? 'My Projects' : 'Kingdom Projects',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Search Kingdom projects...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ['Church Building', 'Evangelism', 'Missions', 'Orphan Care', 'Community Outreach', 'Education']
                            .map((c) => _FilterChip(label: c, isActive: c == 'Church Building'))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(_myProjects ? 'My Projects' : 'Featured Projects',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                    const SizedBox(height: 16),
                    _ProjectCard(
                      category: 'Church Building', location: 'Nairobi, Kenya',
                      title: 'Grace Community Sanctuary',
                      description: 'Funding the construction of a new sanctuary space designed to serve over 500 local families in peace and devotion.',
                      progress: 0.65, progressLabel: 'Funding Progress', status: 'Active',
                    ),
                    const SizedBox(height: 16),
                    _ProjectCard(
                      category: 'Education', location: 'Manila, Philippines',
                      title: 'Hope Academy Library',
                      description: 'Providing essential reading materials and a quiet, peaceful study environment for primary school students.',
                      progress: 0.42, progressLabel: 'Resource Collection', status: 'Ongoing',
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: _canSell
                          ? OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, '/create-kingdom-project'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.onSurface,
                                minimumSize: const Size(double.infinity, 56),
                                side: const BorderSide(color: AppTheme.outline),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Submit a Kingdom Project'),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => _showVerificationNeeded(),
                              icon: const Icon(Icons.lock_outline, size: 18),
                              label: const Text('Submit a Kingdom Project'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.onSurfaceVariant,
                                minimumSize: const Size(double.infinity, 56),
                                side: BorderSide(color: AppTheme.outlineVariant),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'All submitted projects are reviewed by the Your Portion team before they are published to ensure alignment with our covenant.',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/marketplace');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool isActive;
  const _FilterChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryContainer : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: isActive ? AppTheme.onPrimaryContainer : AppTheme.onSurface)),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String category, location, title, description, progressLabel, status;
  final double progress;

  const _ProjectCard({required this.category, required this.location, required this.title, required this.description, required this.progress, required this.progressLabel, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F2F2)),
        boxShadow: [AppTheme.ambientShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(child: Icon(Icons.image_outlined, size: 48, color: AppTheme.outlineVariant)),
                Positioned(
                  top: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 8, height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: status == 'Active' ? AppTheme.primaryContainer : AppTheme.outline)),
                      const SizedBox(width: 6),
                      Text(status, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.primary)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryContainer, letterSpacing: 1.2, fontSize: 12)),
                    Row(children: [
                      const Icon(Icons.location_on, size: 16, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(location, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                    ]),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
                const SizedBox(height: 8),
                Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(progressLabel, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
                  Text('${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryContainer, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer, foregroundColor: AppTheme.onPrimary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('View Project'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
