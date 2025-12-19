import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/models/item.dart';
import 'package:shopping_list_app/utils/responsive.dart';
import 'package:shopping_list_app/utils/app_constants.dart';

class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2)} ₴';
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<AppStore>(context);
    final items = store.items;
    final now = DateTime.now();
    final responsive = Responsive.of(context);

    final totalItems = items.length;
    final purchasedItemsCount = items
        .where((i) => i.status == ItemStatus.purchased)
        .length;

    final totalPrice = items.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );
    final purchasedPrice = items
        .where((i) => i.status == ItemStatus.purchased)
        .fold<double>(0, (sum, item) => sum + (item.price ?? 0));
    final pendingPrice = totalPrice - purchasedPrice;

    final purchasedItems = items
        .where(
          (item) =>
              item.status == ItemStatus.purchased && item.purchasedAt != null,
        )
        .toList();

    final thisMonthItems = purchasedItems.where((item) {
      final purchaseDate = item.purchasedAt!;
      return purchaseDate.month == now.month && purchaseDate.year == now.year;
    }).toList();
    final thisMonthSpent = thisMonthItems.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );

    final crossAxisCount = responsive.getGridColumns(4);
    final spacing = responsive.spacing;
    final childAspectRatio = responsive.isMobile ? 2.5 : 3.0;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: [
        _StatCard(
          icon: Icons.shopping_bag,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primaryBg,
          value: totalItems.toString(),
          label: 'Всього товарів',
        ),
        _StatCard(
          icon: Icons.trending_up,
          iconColor: AppColors.success,
          iconBgColor: AppColors.successBg,
          value: purchasedItemsCount.toString(),
          label: 'Куплено товарів',
        ),
        _StatCard(
          icon: Icons.attach_money,
          iconColor: AppColors.warning,
          iconBgColor: AppColors.warningBg,
          value: _formatPrice(pendingPrice),
          label: 'Необхідно для покупок',
        ),
        _StatCard(
          icon: Icons.calendar_today,
          iconColor: AppColors.secondary,
          iconBgColor: AppColors.secondaryBg,
          value: _formatPrice(thisMonthSpent),
          label: 'Витрачено за цей місяць',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(
          color: isDark ? AppColors.darkBorderMedium : AppColors.borderLight,
          width: AppSizes.borderWidthMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLG),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingSM),
                  decoration: BoxDecoration(
                    color: isDark
                        ? iconBgColor.withValues(alpha: 0.2)
                        : iconBgColor,
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusSmall,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: AppSizes.iconSizeLarge,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXS),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textSecondary,
                          fontSize: AppSizes.inputFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
