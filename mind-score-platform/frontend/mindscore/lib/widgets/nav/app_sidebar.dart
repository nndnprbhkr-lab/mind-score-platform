import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'nav_destinations.dart';

class AppSidebar extends ConsumerWidget {
  final String currentRoute;

  const AppSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Responsive.isDesktop(context);
    final width = isDesktop ? 240.0 : 180.0;
    final auth = ref.watch(authProvider);

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.primaryMid,
        border: Border(right: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      color: Colors.white, size: 20),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 10),
                  Text(
                    'MindScore',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 8),

          // Nav items
          ...appNavDestinations.map((d) {
            final isSelected = currentRoute.startsWith(d.route);
            return _SidebarItem(
              destination: d,
              isSelected: isSelected,
              showLabel: true,
              onTap: () => context.go(d.route),
            );
          }),

          const Spacer(),

          if (isDesktop) ...[
            const Divider(),
            _UserCard(auth: auth, ref: ref),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final NavDestination destination;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.destination,
    required this.isSelected,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? AppColors.accent.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isSelected ? destination.activeIcon : destination.icon,
                  size: 20,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 12),
                  Text(
                    destination.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
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

class _UserCard extends StatelessWidget {
  final AuthState auth;
  final WidgetRef ref;

  const _UserCard({required this.auth, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.accent.withOpacity(0.18),
            child: Text(
              (auth.email ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  auth.isAdmin ? 'Admin' : 'User',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded,
                size: 18, color: AppColors.textSecondary),
            tooltip: 'Sign out',
          ),
        ],
      ),
    );
  }
}
