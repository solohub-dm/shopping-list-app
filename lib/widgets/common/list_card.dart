import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/shopping_list.dart';
import 'package:shopping_list_app/utils/list_stats_calculator.dart';
import 'package:shopping_list_app/utils/color_utils.dart';
import 'package:shopping_list_app/utils/app_constants.dart';
import 'package:intl/intl.dart';

class ListCard extends StatefulWidget {
  final ListWithStats listData;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const ListCard({
    super.key,
    required this.listData,
    required this.onTap,
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
  });

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final list = widget.listData.list;
    final stats = widget.listData.stats;
    final now = DateTime.now();
    final isOverdue =
        !stats.isCompleted &&
        list.dueDate != null &&
        list.dueDate!.isBefore(now);

    final isCompleted = stats.isCompleted;
    final cardColor = isOverdue && !isCompleted
        ? (Theme.of(context).brightness == Brightness.dark
              ? Colors.red[900]!.withValues(alpha: 0.1)
              : Colors.red[50])
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        constraints: const BoxConstraints(),
        decoration: BoxDecoration(
          color: cardColor ?? AppColorScheme.getBgPrimary(context),
          borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius), // rounded-xl
          border: Border.all(
            color: isOverdue && !isCompleted
                ? (isDark ? AppColors.errorDark : AppColors.errorLight)
                : AppColorScheme.getBorderLight(context),
            width: AppSizes.cardBorderWidth, // border-2
          ),
          boxShadow: _isHovered && !isCompleted && !isOverdue
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Opacity(
              opacity: isCompleted ? 0.6 : (isOverdue ? 0.75 : 1.0),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingXXL), // p-6 = 24px
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ListCardHeader(
                            list: list,
                            isCompleted: isCompleted,
                          ),
                          const SizedBox(height: AppSizes.spacingMD), // mb-3 = 12px
                          _ListCardDates(list: list, isOverdue: isOverdue),
                          const SizedBox(height: AppSizes.spacingMD), // mb-3 = 12px
                          _ListCardProgress(stats: stats),
                          if (stats.totalPrice > 0) ...[
                            const SizedBox(height: AppSizes.spacingMD), // mb-3 = 12px
                            Divider(
                              color: AppColorScheme.getBorderLight(context),
                              height: 1,
                              thickness: 1,
                            ),
                            const SizedBox(height: AppSizes.spacingMD), // mb-3 = 12px
                            _ListCardFinancial(stats: stats),
                          ],
                        ],
                      ),
                    ),
                    Positioned(
                      top: AppSizes.spacingMD,
                      right: AppSizes.spacingMD,
                      child: AnimatedOpacity(
                        opacity: _isHovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: _ActionButtons(
                          onEdit: widget.onEdit,
                          onShare: widget.onShare,
                          onDelete: widget.onDelete,
                          isCompleted: isCompleted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListCardHeader extends StatelessWidget {
  final ShoppingList list;
  final bool isCompleted;

  const _ListCardHeader({
    required this.list,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                          style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColorScheme.getTextPrimary(context),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.successDark.withValues(alpha: 0.2)
                            : AppColors.successBg,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: AppSizes.iconSizeSmall,
                            color: isDark
                                ? AppColors.successLight
                                : AppColors.success,
                          ),
                          const SizedBox(width: AppSizes.paddingXS),
                          Text(
                            'Завершено',
                            style: TextStyle(
                              fontSize: AppSizes.inputFontSize,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.successLight
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (list.description != null) ...[
                const SizedBox(height: AppSizes.paddingSM),
                Text(
                  list.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColorScheme.getTextSecondary(context),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSizes.spacingMD),
        if (list.color != null)
          Container(
            width: AppSizes.iconSizeLarge,
            height: AppSizes.iconSizeLarge,
            decoration: BoxDecoration(
              color: ColorUtils.parseColor(list.color!),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final bool isCompleted;

  const _ActionButtons({
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorScheme.getBgPrimary(context),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
        border: Border.all(
          color: AppColorScheme.getBorderMedium(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.paddingXS),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: Icons.share,
            onTap: onShare,
            hoverColor: Colors.green,
          ),
          const SizedBox(width: 4),
          _ActionButton(
            icon: Icons.edit,
            onTap: onEdit,
            hoverColor: Colors.blue,
          ),
          const SizedBox(width: 4),
          _ActionButton(
            icon: Icons.delete,
            onTap: onDelete,
            hoverColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color hoverColor;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.hoverColor,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  Color _getHoverColor(Color baseColor) {
    if (baseColor == Colors.green) return AppColors.success;
    if (baseColor == Colors.blue) return AppColors.primary;
    if (baseColor == Colors.red) return AppColors.error;
    return baseColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (isDark
                      ? widget.hoverColor.withValues(alpha: 0.2)
                      : widget.hoverColor.withValues(alpha: 0.1))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: AppSizes.iconSizeSmall,
              color: _isHovered
                  ? _getHoverColor(widget.hoverColor)
                  : AppColorScheme.getTextTertiary(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListCardDates extends StatelessWidget {
  final ShoppingList list;
  final bool isOverdue;

  const _ListCardDates({
    required this.list,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Створено: ${DateFormat('dd.MM.yyyy').format(list.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColorScheme.getTextSecondary(context),
            fontSize: AppSizes.inputFontSize,
          ),
        ),
        if (list.dueDate != null) ...[
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            'До: ${DateFormat('dd.MM.yyyy').format(list.dueDate!)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isOverdue
                      ? (isDark
                            ? AppColors.errorLight
                            : AppColors.error)
                      : AppColorScheme.getTextSecondary(context),
                  fontWeight: isOverdue
                      ? FontWeight.w500
                      : FontWeight.normal,
                  fontSize: AppSizes.inputFontSize,
                ),
          ),
        ],
      ],
    );
  }
}

class _ListCardProgress extends StatelessWidget {
  final ListStats stats;

  const _ListCardProgress({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: AppSizes.iconSizeSmall,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSizes.paddingXS),
                Text(
                  '${stats.purchasedItems} куплено',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontSize: AppSizes.inputFontSize,
                      ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  size: AppSizes.iconSizeSmall,
                  color: AppColorScheme.getTextSecondary(context),
                ),
                const SizedBox(width: AppSizes.paddingXS),
                Text(
                  '${stats.pendingItems} залишилось',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColorScheme.getTextSecondary(context),
                        fontSize: AppSizes.inputFontSize,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingSM),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.paddingXS),
          child: LinearProgressIndicator(
            value: stats.totalItems > 0
                ? stats.purchasedItems / stats.totalItems
                : 0,
            minHeight: AppSizes.paddingSM,
            backgroundColor: AppColorScheme.getBgTertiary(context),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.successLight, // green-500
            ),
          ),
        ),
      ],
    );
  }
}

class _ListCardFinancial extends StatelessWidget {
  final ListStats stats;

  const _ListCardFinancial({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (stats.purchasedPrice > 0)
          Text(
            'Витрачено: ${stats.purchasedPrice.toStringAsFixed(2)} ₴',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                  fontSize: AppSizes.inputFontSize,
                ),
          ),
        Text(
          'Залишилось: ${(stats.totalPrice - stats.purchasedPrice).toStringAsFixed(2)} ₴',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColorScheme.getTextSecondary(context),
                fontSize: AppSizes.inputFontSize,
              ),
        ),
      ],
    );
  }
}

