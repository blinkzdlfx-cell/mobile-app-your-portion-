import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/property_card.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/skeleton/skeleton_layouts.dart';
import '../../services/supabase_service.dart';
import '../../models/property.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _supabaseService = SupabaseService();
  String _activeFilter = 'All Listings';
  bool _initialized = false;
  bool _isLoadingProperties = false;
  bool _isLoadingSaved = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 0;
  static const int _pageSize = 20;
  final _scrollController = ScrollController();

  double _minPrice = 0;
  double _maxPrice = 500000;
  String _selectedLocation = 'All Locations';
  String _selectedType = 'All Types';
  String _selectedSeller = 'All Sellers';
  String _selectedPurpose = 'All Purposes';
  double _minSize = 0;
  double _maxSize = 100;
  String _sortBy = 'newest';
  final _locationController = TextEditingController();

  List<Property> _allProperties = [];
  Set<String> _savedPropertyIds = {};

  List<Property> get _filteredProperties {
    var results = _allProperties;
    if (_activeFilter != 'All Listings') {
      results = results.where((p) => p.category == _activeFilter).toList();
    }
    final loc = _selectedLocation.trim().toLowerCase();
    if (loc.isNotEmpty && loc != 'all locations') {
      results = results.where((p) => p.location.toLowerCase().contains(loc)).toList();
    }
    if (_selectedType != 'All Types') {
      results = results.where((p) => p.category == _selectedType).toList();
    }
    if (_selectedSeller != 'All Sellers') {
      results = results.where((p) {
        final sellerId = p.sellerId;
        if (sellerId == 'seller1') return true;
        if (sellerId == 'seller2' && _selectedSeller == 'Trusted Member') return true;
        if (sellerId == 'seller3' && _selectedSeller == 'Individual') return true;
        return false;
      }).toList();
    }
    return results;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreProperties();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        _activeFilter = args;
      }
      _loadProperties();
      _loadSavedPropertyIds();
    }
  }

  Future<void> _loadProperties() async {
    if (mounted) setState(() { _isLoadingProperties = true; });
    try {
      _page = 0;
      _hasMore = true;
      final properties = await _supabaseService.getProperties(page: 0, pageSize: _pageSize, sortBy: _sortBy);
      if (mounted) setState(() { _allProperties = properties; });
    } catch (_) {
    } finally {
      if (mounted) setState(() { _isLoadingProperties = false; });
    }
  }

  Future<void> _loadMoreProperties() async {
    if (_isLoadingMore || !_hasMore || _isLoadingProperties || !mounted) return;
    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      final more = await _supabaseService.getProperties(page: nextPage, pageSize: _pageSize, sortBy: _sortBy);
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _allProperties = [..._allProperties, ...more];
        if (more.length < _pageSize) _hasMore = false;
      });
    } catch (_) {
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> _loadSavedPropertyIds() async {
    if (mounted) setState(() { _isLoadingSaved = true; });
    try {
      final savedIds = await _supabaseService.getSavedPropertyIds();
      if (mounted) setState(() { _savedPropertyIds = savedIds.toSet(); });
    } catch (_) {
    } finally {
      if (mounted) setState(() { _isLoadingSaved = false; });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filters', style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Property Type
                Text('Property Type', style: Theme.of(ctx).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: ['All Types', 'Farm Land', 'Land', 'Houses', 'Apartments', 'Rooms']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setSheetState(() => _selectedType = v ?? 'All Types'),
                ),
                const SizedBox(height: 16),
                // Location
                Text('Location', style: Theme.of(ctx).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    hintStyle: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: AppTheme.outline),
                    prefixIcon:  Icon(Icons.search, color: AppTheme.outline),
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (v) => setSheetState(() => _selectedLocation = v),
                ),
                const SizedBox(height: 16),
                // Seller Type
                Text('Seller', style: Theme.of(ctx).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSeller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: ['All Sellers', 'Individual', 'Trusted Member', 'Church / Organization']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setSheetState(() => _selectedSeller = v ?? 'All Sellers'),
                ),
                const SizedBox(height: 16),
                // Purpose
                Text('Purpose', style: Theme.of(ctx).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPurpose,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: ['All Purposes', 'Personal Use', 'Investment', 'Kingdom Project']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setSheetState(() => _selectedPurpose = v ?? 'All Purposes'),
                ),
                const SizedBox(height: 16),
                // Price Range
                Text('Price Range', style: Theme.of(ctx).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
                const SizedBox(height: 8),
                RangeSlider(
                  values: RangeValues(_minPrice, _maxPrice),
                  min: 0,
                  max: 500000,
                  divisions: 50,
                  labels: RangeLabels('\$${_minPrice.toInt()}', '\$${_maxPrice.toInt()}'),
                  activeColor: AppTheme.primaryContainer,
                  onChanged: (v) => setSheetState(() { _minPrice = v.start; _maxPrice = v.end; }),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('\$${_minPrice.toInt()}', style: Theme.of(ctx).textTheme.labelMedium),
                  Text('\$${_maxPrice.toInt()}', style: Theme.of(ctx).textTheme.labelMedium),
                ]),
                const SizedBox(height: 16),
                // Size Range
                Text('Land Size (acres)', style: Theme.of(ctx).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
                const SizedBox(height: 8),
                RangeSlider(
                  values: RangeValues(_minSize, _maxSize),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  labels: RangeLabels('${_minSize.toInt()} acres', '${_maxSize.toInt()} acres'),
                  activeColor: AppTheme.primaryContainer,
                  onChanged: (v) => setSheetState(() { _minSize = v.start; _maxSize = v.end; }),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${_minSize.toInt()} acres', style: Theme.of(ctx).textTheme.labelMedium),
                  Text('${_maxSize.toInt()} acres', style: Theme.of(ctx).textTheme.labelMedium),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon:  Icon(Icons.arrow_back, color: AppTheme.primary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'Your Portion',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                        ),
                      ),
                       NotificationBell(iconColor: AppTheme.primary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 48),
                      Text(
                        'Marketplace',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Loading skeleton
                      if (_isLoadingProperties || _isLoadingSaved)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const SkeletonPropertyList(itemCount: 2),
                        ),
                      // Search
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Search land, houses, apartments...',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.outline),
                            prefixIcon:  Icon(Icons.search, color: AppTheme.outline),
                            suffixIcon: IconButton(
                              icon:  Icon(Icons.tune, color: AppTheme.outline),
                              onPressed: _showFilterSheet,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedLocation = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filter chips
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(label: 'All Listings', isActive: _activeFilter == 'All Listings', onTap: () => setState(() => _activeFilter = 'All Listings')),
                            _FilterChip(label: 'Farm Land', isActive: _activeFilter == 'Farm Land', onTap: () => setState(() => _activeFilter = 'Farm Land')),
                            _FilterChip(label: 'Land', isActive: _activeFilter == 'Land', onTap: () => setState(() => _activeFilter = 'Land')),
                            _FilterChip(label: 'Houses', isActive: _activeFilter == 'Houses', onTap: () => setState(() => _activeFilter = 'Houses')),
                            _FilterChip(label: 'Apartments', isActive: _activeFilter == 'Apartments', onTap: () => setState(() => _activeFilter = 'Apartments')),
                            _FilterChip(label: 'Rooms', isActive: _activeFilter == 'Rooms', onTap: () => setState(() => _activeFilter = 'Rooms')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sort row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _showSortSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.outlineVariant),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                   Icon(Icons.swap_vert, size: 16, color: AppTheme.primaryContainer),
                                  const SizedBox(width: 6),
                                  Text(
                                    _sortLabel,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Property cards
                      ..._filteredProperties.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PropertyCard(
                          property: p,
                          isSaved: _savedPropertyIds.contains(p.id),
                          onSaveToggle: () => _toggleSave(p.id),
                          onTap: () => Navigator.pushNamed(context, '/property-detail', arguments: p),
                        ),
                      )),
                      if (_isLoadingMore)
                         Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-property'),
        backgroundColor: AppTheme.primaryContainer,
        child:  Icon(Icons.add, color: AppTheme.onPrimary, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 2) Navigator.pushNamed(context, '/kingdom-projects');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  String get _sortLabel {
    switch (_sortBy) {
      case 'price_asc':
        return 'Price: Low to High';
      case 'price_desc':
        return 'Price: High to Low';
      default:
        return 'Newest First';
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Sort By',
                style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: _sortBy,
              onChanged: (v) => _applySort(v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'newest',
                    activeColor: AppTheme.primaryContainer,
                    title: const Text('Newest First'),
                  ),
                  RadioListTile<String>(
                    value: 'price_asc',
                    activeColor: AppTheme.primaryContainer,
                    title: const Text('Price: Low to High'),
                  ),
                  RadioListTile<String>(
                    value: 'price_desc',
                    activeColor: AppTheme.primaryContainer,
                    title: const Text('Price: High to Low'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _applySort(String? value) {
    if (value == null) return;
    Navigator.of(context).pop();
    setState(() => _sortBy = value);
    _loadProperties();
  }

  Future<void> _toggleSave(String propertyId) async {
    if (_savedPropertyIds.contains(propertyId)) {
      await _supabaseService.unsaveProperty(propertyId);
      if (mounted) setState(() { _savedPropertyIds.remove(propertyId); });
    } else {
      await _supabaseService.saveProperty(propertyId);
      if (mounted) setState(() { _savedPropertyIds.add(propertyId); });
    }
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
          color: isActive ? AppTheme.primaryContainer : AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppTheme.outlineVariant),
          boxShadow: isActive ? [AppTheme.ambientShadow] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isActive ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}


