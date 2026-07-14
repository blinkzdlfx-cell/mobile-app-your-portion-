import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmptyStateScreen extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyStateScreen({
    super.key,
    this.title = 'Nothing Here Yet',
    this.message = "There's nothing to display at the moment. Check back later or explore other sections of the app.",
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLowest,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: AppTheme.surfaceVariant),
                  ),
                  child: Icon(
                    icon,
                    size: 80,
                    color: AppTheme.outlineVariant,
                  ),
                ),
                const SizedBox(height: 24),
                // Text
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 280,
                    child: ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryContainer,
                        foregroundColor: AppTheme.onPrimary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        shadowColor: AppTheme.primaryContainer.withValues(alpha: 0.15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (actionLabel == 'Go Home')
                            const Icon(Icons.home, size: 20, color: AppTheme.onPrimary),
                          if (actionLabel == 'Go Home') const SizedBox(width: 8),
                          Text(actionLabel!),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
