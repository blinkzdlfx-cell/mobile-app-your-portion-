import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
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
  bool _canSell = false;
  bool _isLoadingRole = true;
  bool _isLoadingProperties = false;
  bool _isLoadingSaved = false;

  double _minPrice = 0;
  double _maxPrice = 500000;
  String _selectedLocation = 'All Locations';
  String _selectedType = 'All Types';
  String _selectedSeller = 'All Sellers';
  String _selectedPurpose = 'All Purposes';
  double _minSize = 0;
  double _maxSize = 100;
  final _locationController = TextEditingController();

  List<Property> _allProperties = [];
  Set<String> _savedPropertyIds = {};

  List<Property> get _filteredProperties {
    var results = _allProperties;
    if (_activeFilter != 'All Listings') {
      results = results.where((p) => p.category == _activeFilter).toList();
    }
    final loc = _selectedLocation.trim().toLowerCase();
    if (loc.isNotEmpty) {
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
  void dispose() {
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
      _loadRole();
      _loadProperties();
      _loadSavedPropertyIds();
    }
  }

  Future<void> _loadRole() async {
    final canSell = await _supabaseService.canSell();
    if (mounted) setState(() { _canSell = canSell; _isLoadingRole = false; });
  }

  Future<void> _loadProperties() async {
    if (mounted) setState(() { _isLoadingProperties = true; });
    try {
      final properties = await _supabaseService.getProperties();
      if (mounted) setState(() { _allProperties = properties; });
    } catch (e) {
      print('Error loading properties: $e');
    } finally {
      if (mounted) setState(() { _isLoadingProperties = false; });
    }
  }

  Future<void> _loadSavedPropertyIds() async {
    if (mounted) setState(() { _isLoadingSaved = true; });
    try {
      final savedIds = await _supabaseService.getSavedPropertyIds();
      if (mounted) setState(() { _savedPropertyIds = savedIds.toSet(); });
    } catch (e) {
      print('Error loading saved property ids: $e');
    } finally {
      if (mounted) setState(() { _isLoadingSaved = false; });
    }
  }

  @override
  void dispose() {
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
      _loadRole();
    }
  }

  Future<void> _loadRole() async {
    final canSell = await _supabaseService.canSell();
    if (mounted) setState(() { _canSell = canSell; _isLoadingRole = false; });
  }

  void _showVerificationNeeded() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _SellerVerificationNeededSheet(),
    );
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
                    prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
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
                        icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
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
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                        onPressed: () => Navigator.pushNamed(context, '/notifications'),
                      ),
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Loading indicator
                      if (_isLoadingProperties || _isLoadingSaved)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(color: AppTheme.primary),
                          ),
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
                            prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.tune, color: AppTheme.outline),
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
                      // Property cards
                      ..._filteredProperties.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PropertyCard(
                          property: p,
                          isSaved: _savedPropertyIds.contains(p.id),
                          onSaveToggle: () => _toggleSave(p.id),
                        ),
                      )),
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isLoadingRole
          ? null
          : (_canSell
              ? FloatingActionButton(
                  onPressed: () => Navigator.pushNamed(context, '/create-property'),
                  backgroundColor: AppTheme.primaryContainer,
                  child: const Icon(Icons.add, color: AppTheme.onPrimary, size: 28),
                )
              : FloatingActionButton.extended(
                  onPressed: () => Navigator.pushNamed(context, '/seller-verification'),
                  backgroundColor: AppTheme.surfaceContainerHigh,
                  icon: const Icon(Icons.lock_outline, color: AppTheme.onSurfaceVariant, size: 20),
                  label: Text(
                    'Become a Seller',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                )),
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

class _SellerVerificationNeededSheet extends StatelessWidget {
  const _SellerVerificationNeededSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text('You need to be verified as a seller to list properties. Contact an admin or apply in your profile settings.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
            textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { Navigator.pushNamed(context, '/profile'); },
              child: const Text('Go to Profile'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Property property;
  final bool isSaved;
  final VoidCallback? onSaveToggle;

  const _PropertyCard({
    required this.property,
    this.isSaved = false,
    this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: [AppTheme.ambientShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.image_outlined, size: 48, color: AppTheme.outlineVariant),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      property.category,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onSaveToggle,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isSaved ? Colors.red : AppTheme.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Info
          Text(
            property.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppTheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                property.location,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.formattedPrice,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Verified Seller',
                        style: TextStyle(color: AppTheme.onSurface),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 14, color: Colors.orange, fill: 1),
                      const SizedBox(width: 2),
                      const Text('4.8'),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showPropertyDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceContainer,
                  foregroundColor: AppTheme.primary,
                  minimumSize: const Size(100, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('View Details', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPropertyDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Property Details', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 16),
            Text('Title: ${property.title}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Category: ${property.category}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Price: ${property.formattedPrice}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Location: ${property.location}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
