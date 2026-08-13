import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/property.dart';
import '../../models/property_review.dart';
import '../../services/supabase_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({super.key});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late Property _property;
  late PageController _pageController;
  int _currentImageIndex = 0;
  final _supabaseService = SupabaseService();
  List<PropertyReview> _reviews = [];
  bool _reviewsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _property = ModalRoute.of(context)!.settings.arguments as Property;
    _pageController = PageController();
    if (!_reviewsLoaded) {
      _reviewsLoaded = true;
      _loadReviews();
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _supabaseService.getReviews(_property.id);
      if (mounted) setState(() => _reviews = reviews);
    } catch (_) {
      // Reviews are optional — fail silently.
    }
  }

  Future<void> _openReviewSheet() async {
    PropertyReview? myReview;
    try {
      myReview = await _supabaseService.getMyReview(_property.id);
    } catch (_) {}

    if (!mounted) return;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ReviewSheet(propertyId: _property.id, myReview: myReview),
    );
    if (result == 'deleted' || result == 'saved') {
      _loadReviews();
    }
  }

  double get _averageRating =>
      _reviews.isEmpty ? 0 : _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = _property.images.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _property.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image gallery
            if (hasImages)
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentImageIndex = i),
                      children: _property.images.map((url) => CachedNetworkImage(
                        imageUrl: url,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        placeholder: (context, progress) => Container(
                          color: AppTheme.surfaceVariant,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, error, stackTrace) => Container(
                          color: AppTheme.surfaceVariant,
                          child:  Center(
                            child: Icon(Icons.broken_image_outlined, size: 48, color: AppTheme.outlineVariant),
                          ),
                        ),
                      )).toList(),
                    ),
                    if (_property.images.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _property.images.length,
                            (i) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == _currentImageIndex
                                    ? AppTheme.primary
                                    : AppTheme.surface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Container(
                height: 200,
                color: AppTheme.surfaceVariant,
                child:  Center(
                  child: Icon(Icons.image_outlined, size: 64, color: AppTheme.outlineVariant),
                ),
              ),

            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _property.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _property.formattedPrice,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                       Icon(Icons.location_on, size: 18, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        _property.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _property.category,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _property.status.toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: _property.status == 'approved'
                                ? Colors.green
                                : AppTheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_property.description != null && _property.description!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _property.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (_property.bedrooms != null || _property.bathrooms != null || _property.sizeSqm != null)
                    _buildSpecs(context),
                  const SizedBox(height: 24),
                  Text(
                    'Contact Seller',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactInfo(context),
                  const SizedBox(height: 32),
                  _buildReviewsSection(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_reviews.isNotEmpty) ...[
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < _averageRating.round() ? Icons.star : Icons.star_border,
                  size: 16,
                  color: const Color(0xFFFFB800),
                )),
              ),
              const SizedBox(width: 6),
              Text(
                '${_averageRating.toStringAsFixed(1)} (${_reviews.length})',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (_reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Text(
              'No reviews yet. Be the first to review this property.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ..._reviews.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                r.reviewerName ?? 'Anonymous',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (r.reviewerVerified) ...[
                              const SizedBox(width: 4),
                               Icon(Icons.verified, size: 14, color: AppTheme.primaryContainer),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < r.rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: const Color(0xFFFFB800),
                        )),
                      ),
                    ],
                  ),
                  if (r.comment != null && r.comment!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      r.comment!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openReviewSheet,
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Write a Review'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryContainer,
              side:  BorderSide(color: AppTheme.primaryContainer),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (_property.sizeSqm != null)
              _SpecChip(icon: Icons.square_foot, label: '${_property.sizeSqm!.round()} m²'),
            if (_property.bedrooms != null)
              _SpecChip(icon: Icons.bed, label: '${_property.bedrooms} Beds'),
            if (_property.bathrooms != null)
              _SpecChip(icon: Icons.bathtub_outlined, label: '${_property.bathrooms} Baths'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        children: [
          if (_property.contactWhatsapp != null)
            _ContactRow(
              icon: Icons.chat,
              label: 'WhatsApp',
              value: _property.contactWhatsapp!,
            ),
          if (_property.contactPhone != null) ...[
            if (_property.contactWhatsapp != null) const SizedBox(height: 12),
            _ContactRow(
              icon: Icons.phone,
              label: 'Phone',
              value: _property.contactPhone!,
            ),
          ],
          if (_property.contactEmail != null) ...[
            if (_property.contactPhone != null || _property.contactWhatsapp != null)
              const SizedBox(height: 12),
            _ContactRow(
              icon: Icons.email,
              label: 'Email',
              value: _property.contactEmail!,
            ),
          ],
          if (_property.contactWhatsapp == null && _property.contactPhone == null && _property.contactEmail == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No contact information provided',
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

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  final String propertyId;
  final PropertyReview? myReview;

  const _ReviewSheet({required this.propertyId, this.myReview});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  final _supabaseService = SupabaseService();
  final _commentController = TextEditingController();
  late int _rating;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.myReview?.rating ?? 5;
    _commentController.text = widget.myReview?.comment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final comment = _commentController.text.trim();
      if (widget.myReview != null) {
        await _supabaseService.updateReview(widget.myReview!.id, _rating, comment.isEmpty ? null : comment);
      } else {
        await _supabaseService.addReview(widget.propertyId, _rating, comment.isEmpty ? null : comment);
      }
      if (mounted) Navigator.of(context).pop('saved');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save review: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _submitting = true);
    try {
      await _supabaseService.deleteReview(widget.myReview!.id);
      if (mounted) Navigator.of(context).pop('deleted');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete review: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              widget.myReview != null ? 'Edit Your Review' : 'Write a Review',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = star),
                  icon: Icon(
                    star <= _rating ? Icons.star : Icons.star_border,
                    size: 36,
                    color: const Color(0xFFFFB800),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              'Rate this property',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceVariant),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Share your experience...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ?  SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.onPrimary))
                    : const Text('Submit Review'),
              ),
            ),
            if (widget.myReview != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _submitting ? null : _delete,
                  icon:  Icon(Icons.delete_outline, color: AppTheme.error),
                  label:  Text('Delete my review', style: TextStyle(color: AppTheme.error)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
