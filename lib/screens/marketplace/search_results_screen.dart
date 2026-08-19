import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../models/property.dart';
import '../../models/kingdom_project.dart';
import '../../models/daily_portion.dart';
import '../../services/supabase_service.dart';
import '../../widgets/skeleton/skeleton_layouts.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _supabaseService = SupabaseService();
  final _searchController = TextEditingController();
  Timer? _debounce;

  String _activeFilter = 'All';
  String _query = '';
  bool _searching = false;
  bool _searchedOnce = false;

  List<Property> _properties = [];
  List<KingdomProject> _projects = [];
  List<DailyPortion> _portions = [];
  List<String> _recentSearches = [];

  static const _recentKey = 'recent_searches';

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _query = _searchController.text.trim();
    _loadRecent();
    if (_query.isNotEmpty) {
      _runSearch();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(_recentKey) ?? [];
    if (mounted) setState(() => _recentSearches = recent);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.isEmpty) {
      setState(() {
        _query = '';
        _searchedOnce = false;
        _properties = [];
        _projects = [];
        _portions = [];
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _query = q;
      _runSearch();
    });
  }

  void _runSearch() {
    final q = _query.trim();
    if (q.isEmpty) return;
    setState(() => _searching = true);
    _saveRecent(q);
    Future.wait([
      _supabaseService.searchProperties(q),
      _supabaseService.searchProjects(q),
      _supabaseService.searchPortions(q),
    ]).then((results) {
      if (!mounted) return;
      setState(() {
        _properties = results[0] as List<Property>;
        _projects = results[1] as List<KingdomProject>;
        _portions = results[2] as List<DailyPortion>;
        _searching = false;
        _searchedOnce = true;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _searching = false);
    });
  }

  Future<void> _saveRecent(String q) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(_recentKey) ?? [];
    recent.remove(q);
    recent.insert(0, q);
    if (recent.length > 5) recent.removeRange(5, recent.length);
    await prefs.setStringList(_recentKey, recent);
    if (mounted) setState(() => _recentSearches = recent);
  }

  void _selectRecent(String q) {
    _searchController.text = q;
    _searchController.selection = TextSelection.collapsed(offset: q.length);
    _query = q;
    _runSearch();
  }

  bool get _showAll => _activeFilter == 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon:  Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: _onChanged,
                        onSubmitted: (_) => _runSearch(),
                        textInputAction: TextInputAction.search,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Search everything...',
                          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          prefixIcon:  Icon(Icons.search, color: AppTheme.onSurfaceVariant),
                          suffixIcon: IconButton(
                            icon:  Icon(Icons.close, color: AppTheme.onSurfaceVariant),
                            onPressed: () {
                              _searchController.clear();
                              _onChanged('');
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(label: 'All', isActive: _activeFilter == 'All', onTap: () => setState(() => _activeFilter = 'All')),
                    _FilterChip(label: 'Daily Portions', isActive: _activeFilter == 'Daily Portions', onTap: () => setState(() => _activeFilter = 'Daily Portions')),
                    _FilterChip(label: 'Properties', isActive: _activeFilter == 'Properties', onTap: () => setState(() => _activeFilter = 'Properties')),
                    _FilterChip(label: 'Kingdom Projects', isActive: _activeFilter == 'Kingdom Projects', onTap: () => setState(() => _activeFilter = 'Kingdom Projects')),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_query.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Searches',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onBackground),
            ),
            const SizedBox(height: 16),
            if (_recentSearches.isEmpty)
              Text(
                'Search for sermons, properties, projects and more.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches.map((q) => InkWell(
                  onTap: () => _selectRecent(q),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Icon(Icons.history, size: 16, color: AppTheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(q, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                )).toList(),
              ),
          ],
        ),
      );
    }

    if (_searching) {
      return const SkeletonSearchResults();
    }

    if (!_searchedOnce || (_properties.isEmpty && _projects.isEmpty && _portions.isEmpty)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(Icons.search_off, size: 64, color: AppTheme.outlineVariant),
              const SizedBox(height: 16),
              Text(
                'No results for "$_query"',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try different keywords like "farm", "land", or "prayer".',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showAll || _activeFilter == 'Daily Portions')
            _Section(
              title: 'Daily Portions (${_portions.length})',
              children: _portions.map((p) => _SearchResultCard(
                icon: Icons.menu_book_rounded,
                badge: 'Daily Portion',
                title: p.title,
                subtitle: p.content,
                onTap: () => Navigator.pushNamed(context, '/daily-portion', arguments: p.id),
              )).toList(),
            ),
          if (_showAll || _activeFilter == 'Properties')
            _Section(
              title: 'Properties (${_properties.length})',
              children: _properties.map((p) => _SearchResultCard(
                icon: Icons.home_rounded,
                badge: 'Property Â· ${p.category}',
                title: p.title,
                subtitle: '${p.formattedPrice} Â· ${p.location}',
                onTap: () => Navigator.pushNamed(context, '/property-detail', arguments: p),
              )).toList(),
            ),
          if (_showAll || _activeFilter == 'Kingdom Projects')
            _Section(
              title: 'Kingdom Projects (${_projects.length})',
              children: _projects.map((p) => _SearchResultCard(
                icon: Icons.church_outlined,
                badge: 'Kingdom Project',
                title: p.title,
                subtitle: p.description ?? '',
                onTap: () => Navigator.pushNamed(context, '/kingdom-projects'),
              )).toList(),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onBackground),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _FilterChip({required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryContainer : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppTheme.surfaceVariant),
        ),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isActive ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant,
        )),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SearchResultCard({
    required this.icon,
    required this.badge,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.surfaceVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryContainer, fill: 1),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(20)),
                    child: Text(badge, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 4),
                  Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.onBackground)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
             Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

