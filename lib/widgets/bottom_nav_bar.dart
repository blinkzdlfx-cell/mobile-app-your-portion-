import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.92),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(child: _NavItem(
              icon: Icons.auto_stories_outlined,
              activeIcon: Icons.auto_stories,
              label: 'Daily',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            )),
            Expanded(child: _NavItem(
              icon: Icons.storefront_outlined,
              activeIcon: Icons.storefront,
              label: 'Market',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            )),
            Expanded(child: _NavItem(
              icon: Icons.diversity_1_outlined,
              activeIcon: Icons.diversity_1,
              label: 'Kingdom',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            )),
            Expanded(child: _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            )),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.onPrimary : AppTheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppTheme.onPrimary : AppTheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
