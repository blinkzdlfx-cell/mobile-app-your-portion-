import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/supabase_service.dart';

List<Color> _avatarGradient(String id) {
  final gradients = [
    [const Color(0xFF1B4332), const Color(0xFF2D6A4F)],
    [const Color(0xFF3A4F6B), const Color(0xFF5B7BA0)],
    [const Color(0xFF6B4F3A), const Color(0xFF8B6F4A)],
    [const Color(0xFF3A5B4A), const Color(0xFF5A7B6A)],
    [const Color(0xFF5B3A5B), const Color(0xFF7B5A7B)],
    [const Color(0xFF3A5A5A), const Color(0xFF5A7A7A)],
    [const Color(0xFF6B6B3A), const Color(0xFF8B8B5A)],
    [const Color(0xFF7B4A2A), const Color(0xFF9B6A4A)],
  ];
  return gradients[id.hashCode.abs() % gradients.length];
}

String _initials(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return parts[0][0].toUpperCase();
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
  List<Color> _avatarGradient = [AppTheme.primaryContainer, AppTheme.primaryContainer];
  bool _isSellerVerified = false;
  bool _isTrustedMember = false;
  bool _isAdmin = false;
  bool _hasPendingVerification = false;
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
    final pendingRequest = await _supabaseService.getPendingRequest('seller');

    if (mounted) {
      setState(() {
        _fullName = name;
        _email = email;
        _role = profile?.role ?? role;
        _isSellerVerified = profile?.isSellerVerified ?? false;
        _isTrustedMember = profile?.isTrustedMember ?? false;
        _isAdmin = role == 'admin' || (profile?.role == 'admin');
        _hasPendingVerification = pendingRequest != null;
        _avatarInitials = _initials(name);
        _avatarGradient = _avatarGradient(user.id);
      });
    }
  }

  void _showVerificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  size: 32,
                  color: AppTheme.primaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Seller Verification',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a government-issued ID (NIN, voter card, passport, or proof of address) for admin review.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.pushNamed(context, '/document-upload');
                  },
                  child: const Text('Upload Document'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.onSurfaceVariant,
                    side: const BorderSide(color: AppTheme.outlineVariant),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.surfaceVariant.withValues(alpha: 0.5)),
                        boxShadow: [AppTheme.ambientShadow],
                      ),
                      child: Column(
                        children: [
                          // Gradient header area
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              gradient: LinearGradient(
                                colors: _avatarGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.surface.withValues(alpha: 0.5), width: 3),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _avatarInitials,
                                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        color: AppTheme.surface,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _fullName.isNotEmpty ? _fullName : 'Friend',
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: AppTheme.surface,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _email,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.surface.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          // Badges section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                            child: Row(
                              children: [
                                _ProfileBadge(
                                  icon: _isAdmin ? Icons.admin_panel_settings : Icons.person_outline,
                                  label: _isAdmin ? 'Admin' : (_role == 'seller' ? 'Seller' : 'Buyer'),
                                ),
                                const SizedBox(width: 8),
                                if (_isTrustedMember)
                                  Row(
                                    children: [
                                      _ProfileBadge(
                                        icon: Icons.verified,
                                        label: 'Trusted Member',
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                if (_isSellerVerified)
                                  _ProfileBadge(
                                    icon: Icons.verified,
                                    label: 'Verified Seller',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Verification CTA for unverified sellers
                    if (_role == 'seller' && !_isSellerVerified) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryContainer.withValues(alpha: 0.08),
                              AppTheme.primaryFixedDim.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _hasPendingVerification
                                        ? Icons.hourglass_top
                                        : Icons.verified_user_outlined,
                                    color: AppTheme.primaryContainer,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _hasPendingVerification
                                            ? 'Verification Pending'
                                            : 'Complete Seller Verification',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _hasPendingVerification
                                            ? 'Your documents are under admin review.'
                                            : 'Upload your ID to start listing properties.',
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (!_hasPendingVerification) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _showVerificationSheet(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryContainer,
                                    foregroundColor: AppTheme.onPrimary,
                                    minimumSize: const Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Verify Now'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // My Activity
                    Text(
                      'My Activity',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_role != 'buyer')
                      _ActivityCard(icon: Icons.home_outlined, title: 'My Properties', onTap: () => Navigator.pushNamed(context, '/my-properties')),
                    if (_role != 'buyer') const SizedBox(height: 8),
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
                          if (_role == 'seller' && !_isSellerVerified)
                            _AccountTile(
                              icon: Icons.badge_outlined,
                              title: 'Seller Verification',
                              trailing: _hasPendingVerification ? _PendingChip() : null,
                              onTap: _hasPendingVerification ? null : () => _showVerificationSheet(context),
                            ),
                          if (_role == 'seller' && !_isSellerVerified) _Divider(),
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
  final IconData icon;
  final String label;

  const _ProfileBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.w500,
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

class _PendingChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_top, size: 12, color: AppTheme.primaryContainer),
          const SizedBox(width: 4),
          Text(
            'Pending',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.primaryContainer,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _AccountTile({required this.icon, required this.title, this.onTap, this.trailing});

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
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
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