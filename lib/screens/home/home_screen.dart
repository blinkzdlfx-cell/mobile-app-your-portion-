import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isSearchExpanded = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late final AnimationController _arrowAnim;
  late final Animation<double> _arrowOffset;

  @override
  void initState() {
    super.initState();
    _arrowAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _arrowOffset = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _arrowAnim, curve: Curves.easeInOut),
    );
  }

  String _firstName() {
    final fullName = Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] as String?;
    if (fullName == null || fullName.trim().isEmpty) return 'Friend';
    return fullName.trim().split(' ').first;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _arrowAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset('assets/images/logo.png', width: 24, height: 24, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondary,
                        ),
                      ),
                      Text(
                        _firstName(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                    icon: const Icon(Icons.notifications_outlined, color: AppTheme.onSurface),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surfaceContainer,
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _isSearchExpanded
                          ? TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: 'Search sermons, properties, projects or library...',
                                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.outlineVariant,
                                ),
                                prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close, color: AppTheme.outline),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _isSearchExpanded = false);
                                    _searchFocusNode.unfocus();
                                  },
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  Navigator.pushNamed(context, '/search-results');
                                }
                              },
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() => _isSearchExpanded = true);
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  _searchFocusNode.requestFocus();
                                });
                              },
                              child: const SizedBox(
                                height: 56,
                                child: Center(
                                  child: Icon(Icons.search, color: AppTheme.outline),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),
                    // Today's Portion card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                        boxShadow: [AppTheme.ambientShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: AppTheme.primaryContainer, fill: 1),
                              const SizedBox(width: 8),
                              Text(
                                "TODAY'S PORTION",
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.primaryContainer,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'The Wisdom of Stewardship',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppTheme.primary,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              Text(
                                'Pastor David Mitchell',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.secondary,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.menu_book, size: 16, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Proverbs 3:9-10',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Discover how ancient principles of managing resources apply to modern wealth, real estate, and community building.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/daily-portion'),
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text("Read Today's Portion"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryContainer,
                                foregroundColor: AppTheme.onPrimary,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Marketplace preview
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Marketplace',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.primary,
                                ),
                              ),
                              Text(
                                'Invest in kingdom-aligned properties.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/marketplace'),
                          child: Row(
                            children: [
                              Text(
                                'Browse',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.primaryContainer,
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _arrowOffset,
                                builder: (context, child) => Transform.translate(
                                  offset: Offset(_arrowOffset.value, 0),
                                  child: child,
                                ),
                                child: const Icon(Icons.arrow_forward, size: 16, color: AppTheme.primaryContainer),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Category grid
                    Row(
                      children: [
                        Expanded(child: _CategoryCard(
                          icon: Icons.agriculture_outlined,
                          label: 'Farm Land',
                          onTap: () => Navigator.pushNamed(context, '/marketplace', arguments: 'Farm Land'),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _CategoryCard(
                          icon: Icons.landscape_outlined,
                          label: 'Land',
                          onTap: () => Navigator.pushNamed(context, '/marketplace', arguments: 'Land'),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _CategoryCard(
                          icon: Icons.home_outlined,
                          label: 'Houses',
                          onTap: () => Navigator.pushNamed(context, '/marketplace', arguments: 'Houses'),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _CategoryCard(
                          icon: Icons.apartment_outlined,
                          label: 'Apt & Rooms',
                          onTap: () => Navigator.pushNamed(context, '/marketplace', arguments: 'Apt & Rooms'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Kingdom Projects
                    Text(
                      'Kingdom Projects',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                        boxShadow: [AppTheme.ambientShadow],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.construction_rounded,
                              size: 28,
                              color: AppTheme.primaryContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Coming Soon',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'re preparing a way for you to support faith-driven initiatives. Stay tuned!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
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
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/marketplace');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _CategoryCard({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryContainer),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        ),
      ),
    );
  }
}
