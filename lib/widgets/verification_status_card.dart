import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class VerificationStatusCard extends StatelessWidget {
  final String requestType;
  final Map<String, dynamic>? request;
  final VoidCallback? onReapply;

  const VerificationStatusCard({
    super.key,
    required this.requestType,
    required this.request,
    this.onReapply,
  });

  @override
  Widget build(BuildContext context) {
    final status = SupabaseService.verificationStatus(request);
    final reason = SupabaseService.verificationReason(request);
    final isSeller = requestType == 'seller';

    final (icon, title, message, bg, fg) = switch (status) {
      'pending' => (
        Icons.hourglass_top,
        'Request Pending',
        'Your ${isSeller ? 'seller' : 'trusted member'} verification request is being reviewed by an admin. You\'ll be notified once it\'s approved.',
        AppTheme.primaryContainer.withValues(alpha: 0.15),
        AppTheme.primaryContainer,
      ),
      'approved' => (
        Icons.verified,
        'Verified',
        'Your ${isSeller ? 'seller' : 'trusted member'} verification is active.',
        AppTheme.primaryFixed,
        AppTheme.onPrimaryFixed,
      ),
      'rejected' => (
        Icons.cancel_outlined,
        'Verification Rejected',
        'Your verification request was rejected. You can review the reason below and re-apply.',
        AppTheme.errorContainer,
        AppTheme.onErrorContainer,
      ),
      'terminated' => (
        Icons.gpp_bad_outlined,
        'Verification Terminated',
        'Your ${isSeller ? 'seller' : 'trusted member'} verification was terminated by an admin. You can review the reason below and re-apply.',
        AppTheme.errorContainer,
        AppTheme.onErrorContainer,
      ),
      _ => (
        Icons.shield_outlined,
        'Not Verified',
        'Complete verification to unlock ${isSeller ? 'selling' : 'trusted member'} features.',
        AppTheme.surfaceContainerLow,
        AppTheme.onSurfaceVariant,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bg),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: fg),
          const SizedBox(height: 16),
          Text(title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.onBackground,
            )),
          const SizedBox(height: 8),
          Text(message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center),
          if ((status == 'rejected' || status == 'terminated') && reason != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppTheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Text('Reason from admin',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(reason,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onErrorContainer,
                      height: 1.5,
                    )),
                ],
              ),
            ),
            if (onReapply != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onReapply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    foregroundColor: AppTheme.onPrimary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Re-apply for Verification'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
