import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/notification_bell.dart';
import '../../services/supabase_service.dart';
import '../../widgets/skeleton/skeleton_layouts.dart';
import '../../models/kingdom_project.dart';

class KingdomProjectsScreen extends StatefulWidget {
  const KingdomProjectsScreen({super.key});

  @override
  State<KingdomProjectsScreen> createState() => _KingdomProjectsScreenState();
}

class _KingdomProjectsScreenState extends State<KingdomProjectsScreen> {
  final _supabaseService = SupabaseService();
  bool _initialized = false;
  bool _isLoading = false;
  String _activeFilter = 'All';
  List<KingdomProject> _allProjects = [];

  List<KingdomProject> get _filteredProjects {
    if (_activeFilter == 'All') return _allProjects;
    return _allProjects.where((p) => p.status == _activeFilter.toLowerCase()).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final projects = await _supabaseService.getProjects();
      if (mounted) setState(() => _allProjects = projects);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showProjectDetails(KingdomProject project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final progress = project.progressPercent;
        final raised = project.raisedAmount;
        final goal = project.goalAmount ?? 0;
        final isCompleted = project.status == 'completed';
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  project.category?.toUpperCase() ?? 'KINGDOM PROJECT',
                  style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryContainer,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  project.title,
                  style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  project.description ?? 'No description provided.',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${raised.toStringAsFixed(0)} raised',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w600,
                      )),
                    Text(isCompleted
                        ? 'Completed'
                        : '\$${goal.toStringAsFixed(0)} goal',
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      )),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor:  AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${(progress * 100).toInt()}% funded',
                  style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  )),
                if (project.contactWhatsapp != null || project.contactPhone != null || project.contactEmail != null) ...[
                  const SizedBox(height: 24),
                  Text('Contact the creator',
                    style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    )),
                  const SizedBox(height: 8),
                  if (project.contactPhone != null)
                    _ContactRow(icon: Icons.phone_outlined, text: project.contactPhone!),
                  if (project.contactWhatsapp != null)
                    _ContactRow(icon: Icons.chat_outlined, text: project.contactWhatsapp!),
                  if (project.contactEmail != null)
                    _ContactRow(icon: Icons.mail_outline, text: project.contactEmail!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = _filteredProjects;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon:  Icon(Icons.arrow_back, color: AppTheme.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text('Your Portion',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 22)),
                  const Spacer(),
                   NotificationBell(iconColor: AppTheme.primary),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kingdom Projects',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 22)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/create-kingdom-project'),
                    child: const Text('+ New'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ['All', 'Active', 'Completed'].map((label) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = label),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeFilter == label
                              ? AppTheme.primaryContainer
                              : AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          border: _activeFilter == label
                              ? null
                              : Border.all(color: AppTheme.outlineVariant),
                          boxShadow: _activeFilter == label ? [AppTheme.ambientShadow] : null,
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: _activeFilter == label
                                  ? AppTheme.onPrimary
                                  : AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const SkeletonKingdomProjectList()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.primary,
                      child: projects.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 120),
                                Icon(Icons.campaign_rounded,
                                  size: 56,
                                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.4)),
                                const SizedBox(height: 16),
                                Center(
                                  child: Text('No Kingdom Projects yet',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.onSurfaceVariant,
                                    )),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text('Verified sellers can start a project from the + New button.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.onSurfaceVariant,
                                    )),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                final project = projects[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _ProjectCard(
                                    project: project,
                                    onTap: () => _showProjectDetails(project),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-kingdom-project'),
        backgroundColor: AppTheme.primaryContainer,
        child:  Icon(Icons.add, color: AppTheme.onPrimary, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

class _ProjectCard extends StatelessWidget {
  final KingdomProject project;
  final VoidCallback? onTap;

  const _ProjectCard({required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = project.progressPercent;
    final isActive = project.status == 'active';
    final isCompleted = project.status == 'completed';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant),
          boxShadow: [AppTheme.ambientShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration:  BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                   Center(child: Icon(Icons.construction_rounded, size: 48, color: AppTheme.outlineVariant)),
                  Positioned(
                    top: 16, left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? AppTheme.primaryContainer
                                  : isCompleted
                                      ? Colors.blueGrey
                                      : AppTheme.outline,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isActive ? 'Active' : isCompleted ? 'Completed' : project.status,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
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
                  Text(
                    (project.category ?? 'KINGDOM PROJECT').toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.primaryContainer,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${(project.raisedAmount).toStringAsFixed(0)} raised',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.onSurface,
                        )),
                      Text('${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryContainer,
                          fontWeight: FontWeight.w600,
                        )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor:  AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

