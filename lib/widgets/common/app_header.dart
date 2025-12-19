import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/widgets/common/logo.dart';
import 'package:shopping_list_app/utils/app_constants.dart';
import 'package:shopping_list_app/utils/responsive.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<AppStore>(context);
    final currentPath = GoRouterState.of(context).matchedLocation;
    final responsive = Responsive.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      height: responsive.isMobile
          ? AppSizes.headerHeight + statusBarHeight
          : AppSizes.headerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorderMedium
                : AppColors.primaryLight,
            width: AppSizes.borderWidthMedium,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: responsive.isMobile ? statusBarHeight : 0,
          left: responsive.isMobile
              ? AppSizes.paddingMD
              : AppSizes.paddingXXL,
          right: responsive.isMobile
              ? AppSizes.paddingMD
              : AppSizes.paddingXXL,
          bottom: 0,
        ),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.go('/'),
                child: Row(
                  children: [
                    const Logo.medium(),
                    if (!responsive.isMobile) ...[
                      const SizedBox(width: AppSizes.spacingMD),
                      Text(
                        'Менеджер покупок',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (responsive.isMobile)
              _MobileMenu(
                currentPath: currentPath,
                store: store,
              )
            else
              Row(
                children: [
                  _NavButton(
                    label: 'Головний',
                    path: '/',
                    currentPath: currentPath,
                    onTap: () => context.go('/'),
                  ),
                  const SizedBox(width: AppSizes.spacingSM),
                  _NavButton(
                    label: 'Історія',
                    path: '/history',
                    currentPath: currentPath,
                    onTap: () => context.go('/history'),
                  ),
                  const SizedBox(width: AppSizes.spacingSM),
                  _NavButton(
                    label: 'Налаштування',
                    path: '/settings',
                    currentPath: currentPath,
                    onTap: () => context.go('/settings'),
                  ),
                  const SizedBox(width: AppSizes.spacingSM),
                  TextButton(
                    onPressed: () {
                      store.logout();
                      context.go('/login');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.errorLight
                              : AppColors.error,
                    ),
                    child: const Text('Вийти'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final String path;
  final String currentPath;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.path,
    required this.currentPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentPath == path;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: isActive
            ? (isDark
                ? AppColors.primaryDark.withValues(alpha: 0.2)
                : AppColors.primaryBg)
            : null,
        foregroundColor: isActive
            ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
            : AppColorScheme.getTextSecondary(context),
      ),
      child: Text(label),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  final String currentPath;
  final AppStore store;

  const _MobileMenu({
    required this.currentPath,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      iconSize: AppSizes.iconSizeLarge,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: '/',
          child: _MenuItem(
            icon: Icons.home,
            label: 'Головний',
            isActive: currentPath == '/',
          ),
        ),
        PopupMenuItem<String>(
          value: '/history',
          child: _MenuItem(
            icon: Icons.history,
            label: 'Історія',
            isActive: currentPath == '/history',
          ),
        ),
        PopupMenuItem<String>(
          value: '/settings',
          child: _MenuItem(
            icon: Icons.settings,
            label: 'Налаштування',
            isActive: currentPath == '/settings',
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: _MenuItem(
            icon: Icons.logout,
            label: 'Вийти',
            isActive: false,
            isDestructive: true,
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          store.logout();
          context.go('/login');
        } else {
          context.go(value);
        }
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive
        ? (isDark ? AppColors.errorLight : AppColors.error)
        : (isActive
            ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
            : AppColorScheme.getTextPrimary(context));

    return Row(
      children: [
        Icon(
          icon,
          size: AppSizes.iconSizeMedium,
          color: color,
        ),
        const SizedBox(width: AppSizes.spacingMD),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

