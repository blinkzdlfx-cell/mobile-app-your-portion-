import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/supabase_service.dart';

Color _colorForUser(String id) {
  final colors = [
    const Color(0xFF1B4332),
    const Color(0xFF4A6572),
    const Color(0xFF7B4F4A),
    const Color(0xFF3A6B4A),
    const Color(0xFF6B4A6B),
    const Color(0xFF3A6B6B),
    const Color(0xFF6B6B3A),
    const Color(0xFF8B5E3C),
    const Color(0xFF5B4A7B),
    const Color(0xFF4A7B5B),
  ];
  return colors[id.hashCode.abs() % colors.length];
}

String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  if (parts.length == 1 && parts[0].isNotEmpty) {
    return parts[0][0].toUpperCase();
  }
  return '?';
}

String _firstName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return 'Friend';
  return trimmed.split(RegExp(r'\s+')).first;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabaseService = SupabaseService();
  String _fullName = '';
  String _email = '';
  String _role = 'buyer';
  String _avatarInitials = '?';
  Color _avatarColor = AppTheme.primaryContainer;
  bool _isSellerVerified = false;
  bool _isTrustedMember = false;
  bool _isAdmin = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final meta = user.userMetadata;
    final name = (meta?['full_name'] as String?) ?? '';
    final email = user.email ?? '';
    final role = (meta?['role'] as String?) ?? 'buyer';

    final profile = await _supabaseService.getCurrentProfile();

    if (mounted) {
      setState(() {
        _fullName = name;
        _email = email;
        _role = profile?.role ?? role;
        _isSellerVerified = profile?.isSellerVerified ?? false;
        _isTrustedMember = profile?.isTrustedMember ?? false;
        _isAdmin = role == 'admin' || (profile?.role == 'admin');
        _avatarInitials = _initials(name);
        _avatarColor = _colorForUser(user.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, color: AppTheme.primary),
                  const Spacer(),
                  Text(
                    'My Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    icon: const Icon(Icons.settings_outlined, color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  children: [
                    // Profile card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.surfaceVariant.withValues(alpha: 0.5)),
                        boxShadow: [AppTheme.ambientShadow],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: _avatarColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.surface, width: 4),
                            ),
                            child: Center(
                              child: Text(
                                _avatarInitials,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppTheme.onPrimary,
                                  fontSize: 32,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _fullName.isNotEmpty ? _fullName : _firstName(_fullName),
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppTheme.onSurface,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ProfileBadge(
                                icon: Icons.verified,
                                label: 'Trusted Member',
                                bgColor: AppTheme.surfaceContainer,
                                textColor: AppTheme.primary,
                              ),
                              _ProfileBadge(
                                icon: _isAdmin ? Icons.admin_panel_settings : null,
                                label: _isAdmin ? 'Admin' : (_role == 'both'
                                    ? 'Buyer & Seller'
                                    : _role == 'seller'
                                        ? 'Seller'
                                        : 'Buyer'),
                                bgColor: AppTheme.surfaceContainerLow,
                                textColor: AppTheme.onSurfaceVariant,
                              ),
                              _ProfileBadge(
                                icon: Icons.verified,
                                label: 'Verified Seller',
                                bgColor: AppTheme.surfaceContainer,
                                textColor: AppTheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // My Activity
                    Text(
                      'My Activity',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ActivityCard(icon: Icons.home_outlined, title: 'My Properties', onTap: () => Navigator.pushNamed(context, '/my-properties')),
                    const SizedBox(height: 8),
                    _ActivityCard(icon: Icons.favorite_outline, title: 'Saved Properties', onTap: () => Navigator.pushNamed(context, '/saved-properties')),
                    const SizedBox(height: 8),
                    _ActivityCard(icon: Icons.church_outlined, title: 'My Kingdom Projects', onTap: () => Navigator.pushNamed(context, '/kingdom-projects', arguments: {'myProjects': true})),
                    const SizedBox(height: 8),
                    _ActivityCard(icon: Icons.menu_book_outlined, title: 'Bookmarked Portions', onTap: () => Navigator.pushNamed(context, '/bookmarked-portions')),
                    const SizedBox(height: 24),
                    // Account section
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.surfaceVariant.withValues(alpha: 0.3)),
                        boxShadow: [BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.02), blurRadius: 30)],
                      ),
                      child: Column(
                        children: [
                          if (_isAdmin) ...[
                            _AccountTile(icon: Icons.admin_panel_settings, title: 'Admin Dashboard', onTap: () => Navigator.pushNamed(context, '/admin')),
                            _Divider(),
                          ],
                          _AccountTile(icon: Icons.person_outline, title: 'Edit Profile', onTap: () => Navigator.pushNamed(context, '/edit-profile').then((_) => _loadProfile())),
                          _Divider(),
                          _AccountTile(icon: Icons.notifications_outlined, title: 'Notifications', onTap: () => Navigator.pushNamed(context, '/notifications')),
                          _Divider(),
                          _AccountTile(icon: Icons.verified_user_outlined, title: 'Trusted Member Status', onTap: () => Navigator.pushNamed(context, '/become-trusted-member')),
                          _Divider(),
                          _AccountTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () => Navigator.pushNamed(context, '/help-support')),
                          _Divider(),
                          _AccountTile(icon: Icons.mail_outline, title: 'Contact Us', onTap: () => Navigator.pushNamed(context, '/help-support')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          minimumSize: const Size(double.infinity, 56),
                          side: const BorderSide(color: AppTheme.error, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/marketplace');
        },
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _ProfileBadge({this.icon, required this.label, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ActivityCard({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.surfaceVariant.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.02), blurRadius: 30)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.primaryContainer),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _AccountTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurface,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.logout, color: AppTheme.error, size: 32),
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/welcome');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.error,
            foregroundColor: AppTheme.onError,
          ),
          child: const Text('Log Out'),
        ),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: AppTheme.surfaceVariant.withValues(alpha: 0.3), indent: 56);
  }
}