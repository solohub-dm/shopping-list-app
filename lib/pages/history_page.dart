import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/models/item.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/shopping_list.dart';
import 'package:shopping_list_app/widgets/common/app_header.dart';
import 'package:shopping_list_app/widgets/common/search_field.dart';
import 'package:shopping_list_app/utils/app_constants.dart';
import 'package:shopping_list_app/utils/color_utils.dart';
import 'package:shopping_list_app/utils/responsive.dart';
import 'package:intl/intl.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _searchTerm = '';
  String _dateFilter = 'all';
  String _listFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<AppStore>(context);
    final responsive = Responsive.of(context);
    final purchasedItems = store.items
        .where(
          (item) =>
              item.status == ItemStatus.purchased && item.purchasedAt != null,
        )
        .toList();

    var filteredItems = purchasedItems;

    if (_searchTerm.isNotEmpty) {
      final searchLower = _searchTerm.toLowerCase();
      filteredItems = filteredItems
          .where((item) => item.name.toLowerCase().contains(searchLower))
          .toList();
    }

    if (_listFilter != 'all') {
      filteredItems = filteredItems
          .where((item) => item.listId == _listFilter)
          .toList();
    }

    final now = DateTime.now();
    if (_dateFilter == 'this-month') {
      final thisMonth = DateTime(now.year, now.month, 1);
      filteredItems = filteredItems
          .where(
            (item) => item.purchasedAt!.isAfter(
              thisMonth.subtract(const Duration(days: 1)),
            ),
          )
          .toList();
    } else if (_dateFilter == 'last-month') {
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      final thisMonth = DateTime(now.year, now.month, 1);
      filteredItems = filteredItems.where((item) {
        final purchaseDate = item.purchasedAt!;
        return purchaseDate.isAfter(
              lastMonth.subtract(const Duration(days: 1)),
            ) &&
            purchaseDate.isBefore(thisMonth);
      }).toList();
    }

    final Map<String, Map<String, List<Item>>> groupedHistory = {};
    for (final item in filteredItems) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.purchasedAt!);
      if (!groupedHistory.containsKey(dateKey)) {
        groupedHistory[dateKey] = {};
      }
      if (!groupedHistory[dateKey]!.containsKey(item.listId)) {
        groupedHistory[dateKey]![item.listId] = [];
      }
      groupedHistory[dateKey]![item.listId]!.add(item);
    }

    final sortedDates = groupedHistory.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final allPurchasedItems = store.items
        .where(
          (item) =>
              item.status == ItemStatus.purchased && item.purchasedAt != null,
        )
        .toList();
    final totalSpent = allPurchasedItems.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );
    final thisMonthItems = allPurchasedItems.where((item) {
      final purchaseDate = item.purchasedAt!;
      return purchaseDate.month == now.month && purchaseDate.year == now.year;
    }).toList();
    final thisMonthSpent = thisMonthItems.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );
    final avgPurchase = allPurchasedItems.isNotEmpty
        ? totalSpent / allPurchasedItems.length
        : 0.0;

    final categoryTotals = <String, double>{};
    for (final item in allPurchasedItems) {
      final categoryId = item.categoryId ?? 'other';
      categoryTotals[categoryId] =
          (categoryTotals[categoryId] ?? 0) + (item.price ?? 0);
    }

    final categoryStats = categoryTotals.entries.map((entry) {
      final category = store.categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => store.categories.firstWhere((c) => c.id == 'other'),
      );
      return _CategoryStat(category: category, total: entry.value);
    }).toList()..sort((a, b) => b.total.compareTo(a.total));

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: responsive.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Історія покупок',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Переглядайте свою історію покупок та статистику витрат',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: responsive.spacing),
                  _StatsSection(
                    totalSpent: totalSpent,
                    totalPurchases: allPurchasedItems.length,
                    thisMonthSpent: thisMonthSpent,
                    avgPurchase: avgPurchase,
                  ),
                  SizedBox(height: responsive.spacing),
                  if (categoryStats.isNotEmpty) ...[
                    _CategoryBreakdown(categoryStats: categoryStats),
                    SizedBox(height: responsive.spacing),
                  ],
                  _HistoryToolbar(
                    searchTerm: _searchTerm,
                    dateFilter: _dateFilter,
                    listFilter: _listFilter,
                    lists: store.lists,
                    onSearchChanged: (value) =>
                        setState(() => _searchTerm = value),
                    onDateFilterChanged: (value) =>
                        setState(() => _dateFilter = value),
                    onListFilterChanged: (value) =>
                        setState(() => _listFilter = value),
                    resultsCount: _searchTerm.isNotEmpty
                        ? filteredItems.length
                        : null,
                  ),
                  SizedBox(height: responsive.spacing),
                  // Purchase history
                  Text(
                    'Історія покупок',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (sortedDates.isEmpty)
                    _EmptyHistory()
                  else
                    ...sortedDates.map((date) {
                      final dateItems = groupedHistory[date]!;
                      final dayTotal = dateItems.values
                          .expand((items) => items)
                          .fold<double>(
                            0,
                            (sum, item) => sum + (item.price ?? 0),
                          );
                      final dateObj = DateTime.parse(date);

                      return _HistoryDateCard(
                        date: dateObj,
                        dayTotal: dayTotal,
                        dateItems: dateItems,
                        store: store,
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final double totalSpent;
  final int totalPurchases;
  final double thisMonthSpent;
  final double avgPurchase;

  const _StatsSection({
    required this.totalSpent,
    required this.totalPurchases,
    required this.thisMonthSpent,
    required this.avgPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final crossAxisCount = responsive.getGridColumns(4);
    final spacing = responsive.spacing;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: responsive.isMobile ? 1.8 : 2.2,
      children: [
        _StatCard(
          icon: Icons.trending_up,
          iconColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFDBEAFE),
          value: '${totalSpent.toStringAsFixed(2)} ₴',
          label: 'Всього витрачено',
        ),
        _StatCard(
          icon: Icons.shopping_bag,
          iconColor: const Color(0xFF16A34A),
          iconBgColor: const Color(0xFFD1FAE5),
          value: totalPurchases.toString(),
          label: 'Всього покупок',
        ),
        _StatCard(
          icon: Icons.calendar_today,
          iconColor: const Color(0xFF9333EA),
          iconBgColor: const Color(0xFFE9D5FF),
          value: '${thisMonthSpent.toStringAsFixed(2)} ₴',
          label: 'Витрачено за цей місяць',
        ),
        _StatCard(
          icon: Icons.attach_money,
          iconColor: const Color(0xFFEA580C),
          iconBgColor: const Color(0xFFFED7AA),
          value: '${avgPurchase.toStringAsFixed(2)} ₴',
          label: 'Середня ціна покупки',
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
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? iconBgColor.withValues(alpha: 0.2)
                    : iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStat {
  final Category category;
  final double total;

  _CategoryStat({required this.category, required this.total});
}

class _CategoryBreakdown extends StatelessWidget {
  final List<_CategoryStat> categoryStats;

  const _CategoryBreakdown({required this.categoryStats});

  Color _parseColor(String colorClass) {
    if (colorClass.contains('green')) return const Color(0xFF22C55E);
    if (colorClass.contains('blue')) return const Color(0xFF3B82F6);
    if (colorClass.contains('gray')) return const Color(0xFF6B7280);
    return const Color(0xFF6B7280);
  }

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
      padding: const EdgeInsets.all(AppSizes.paddingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Витрати за категоріями',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...categoryStats.map((stat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _parseColor(stat.category.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        stat.category.nameUk,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${stat.total.toStringAsFixed(2)} ₴',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HistoryToolbar extends StatelessWidget {
  final String searchTerm;
  final String dateFilter;
  final String listFilter;
  final List lists;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onDateFilterChanged;
  final ValueChanged<String> onListFilterChanged;
  final int? resultsCount;

  const _HistoryToolbar({
    required this.searchTerm,
    required this.dateFilter,
    required this.listFilter,
    required this.lists,
    required this.onSearchChanged,
    required this.onDateFilterChanged,
    required this.onListFilterChanged,
    this.resultsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = Responsive.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(
        responsive.isMobile ? AppSizes.paddingMD : AppSizes.spacingLG,
      ),
      child: Column(
        children: [
          responsive.isMobile
              ? Column(
                  children: [
                    SearchField(
                      hintText: 'Знайти товар...',
                      onChanged: onSearchChanged,
                      value: searchTerm,
                    ),
                    SizedBox(height: responsive.spacing),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: AppSizes.iconSizeSmall,
                          color: AppColorScheme.getTextTertiary(context),
                        ),
                        const SizedBox(width: AppSizes.paddingSM),
                        Expanded(
                          child: Container(
                            height: AppSizes.dropdownHeight,
                            padding: AppSizes.dropdownPadding,
                            decoration: BoxDecoration(
                              color: AppColorScheme.getBgPrimary(context),
                              borderRadius: BorderRadius.circular(
                                AppSizes.dropdownBorderRadius,
                              ),
                              border: Border.all(
                                color: AppColorScheme.getBorderMedium(context),
                                width: AppSizes.borderWidthThin,
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: dateFilter,
                              underline: const SizedBox(),
                              isDense: true,
                              isExpanded: true,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: AppSizes.dropdownIconSize,
                                color: AppColorScheme.getTextTertiary(context),
                              ),
                              style: TextStyle(
                                fontSize: AppSizes.dropdownFontSize,
                                color: AppColorScheme.getTextPrimary(context),
                              ),
                              dropdownColor: AppColorScheme.getBgPrimary(
                                context,
                              ),
                              onChanged: (value) => onDateFilterChanged(value!),
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('За весь час'),
                                ),
                                DropdownMenuItem(
                                  value: 'this-month',
                                  child: Text('Цей місяць'),
                                ),
                                DropdownMenuItem(
                                  value: 'last-month',
                                  child: Text('Минулий місяць'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.spacing),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: AppSizes.iconSizeSmall,
                          color: AppColorScheme.getTextTertiary(context),
                        ),
                        const SizedBox(width: AppSizes.paddingSM),
                        Expanded(
                          child: Container(
                            height: AppSizes.dropdownHeight,
                            padding: AppSizes.dropdownPadding,
                            decoration: BoxDecoration(
                              color: AppColorScheme.getBgPrimary(context),
                              borderRadius: BorderRadius.circular(
                                AppSizes.dropdownBorderRadius,
                              ),
                              border: Border.all(
                                color: AppColorScheme.getBorderMedium(context),
                                width: AppSizes.borderWidthThin,
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: listFilter,
                              underline: const SizedBox(),
                              isDense: true,
                              isExpanded: true,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: AppSizes.dropdownIconSize,
                                color: AppColorScheme.getTextTertiary(context),
                              ),
                              style: TextStyle(
                                fontSize: AppSizes.dropdownFontSize,
                                color: AppColorScheme.getTextPrimary(context),
                              ),
                              dropdownColor: AppColorScheme.getBgPrimary(
                                context,
                              ),
                              onChanged: (value) => onListFilterChanged(value!),
                              items: [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text(
                                    'Всі списки',
                                    style: TextStyle(
                                      fontSize: AppSizes.dropdownFontSize,
                                      color: AppColorScheme.getTextPrimary(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                                ...lists.map(
                                  (list) => DropdownMenuItem(
                                    value: list.id,
                                    child: Text(
                                      list.name,
                                      style: TextStyle(
                                        fontSize: AppSizes.dropdownFontSize,
                                        color: AppColorScheme.getTextPrimary(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        hintText: 'Знайти товар...',
                        onChanged: onSearchChanged,
                        value: searchTerm,
                      ),
                    ),
                    SizedBox(width: responsive.spacing),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: AppSizes.iconSizeSmall,
                          color: AppColorScheme.getTextTertiary(context),
                        ),
                        const SizedBox(width: AppSizes.paddingSM),
                        Container(
                          height: AppSizes.dropdownHeight,
                          padding: AppSizes.dropdownPadding,
                          decoration: BoxDecoration(
                            color: AppColorScheme.getBgPrimary(context),
                            borderRadius: BorderRadius.circular(
                              AppSizes.dropdownBorderRadius,
                            ),
                            border: Border.all(
                              color: AppColorScheme.getBorderMedium(context),
                              width: AppSizes.borderWidthThin,
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: dateFilter,
                            underline: const SizedBox(),
                            isDense: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              size: AppSizes.dropdownIconSize,
                              color: AppColorScheme.getTextTertiary(context),
                            ),
                            style: TextStyle(
                              fontSize: AppSizes.dropdownFontSize,
                              color: AppColorScheme.getTextPrimary(context),
                            ),
                            dropdownColor: AppColorScheme.getBgPrimary(context),
                            onChanged: (value) => onDateFilterChanged(value!),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('За весь час'),
                              ),
                              DropdownMenuItem(
                                value: 'this-month',
                                child: Text('Цей місяць'),
                              ),
                              DropdownMenuItem(
                                value: 'last-month',
                                child: Text('Минулий місяць'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: responsive.spacing),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: AppSizes.iconSizeSmall,
                          color: AppColorScheme.getTextTertiary(context),
                        ),
                        const SizedBox(width: AppSizes.paddingSM),
                        Container(
                          height: AppSizes.dropdownHeight,
                          padding: AppSizes.dropdownPadding,
                          decoration: BoxDecoration(
                            color: AppColorScheme.getBgPrimary(context),
                            borderRadius: BorderRadius.circular(
                              AppSizes.dropdownBorderRadius,
                            ),
                            border: Border.all(
                              color: AppColorScheme.getBorderMedium(context),
                              width: AppSizes.borderWidthThin,
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: listFilter,
                            underline: const SizedBox(),
                            isDense: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              size: AppSizes.dropdownIconSize,
                              color: AppColorScheme.getTextTertiary(context),
                            ),
                            style: TextStyle(
                              fontSize: AppSizes.dropdownFontSize,
                              color: AppColorScheme.getTextPrimary(context),
                            ),
                            dropdownColor: AppColorScheme.getBgPrimary(context),
                            onChanged: (value) => onListFilterChanged(value!),
                            items: [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text(
                                  'Всі списки',
                                  style: TextStyle(
                                    fontSize: AppSizes.dropdownFontSize,
                                    color: AppColorScheme.getTextPrimary(
                                      context,
                                    ),
                                  ),
                                ),
                              ),
                              ...lists.map(
                                (list) => DropdownMenuItem(
                                  value: list.id,
                                  child: Text(
                                    list.name,
                                    style: TextStyle(
                                      fontSize: AppSizes.dropdownFontSize,
                                      color: AppColorScheme.getTextPrimary(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          if (resultsCount != null) ...[
            SizedBox(height: responsive.isMobile ? responsive.spacing : 12),
            Text(
              'Знайдено $resultsCount товарів',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryDateCard extends StatelessWidget {
  final DateTime date;
  final double dayTotal;
  final Map<String, List<Item>> dateItems;
  final AppStore store;

  const _HistoryDateCard({
    required this.date,
    required this.dayTotal,
    required this.dateItems,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingXXL),
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
      padding: const EdgeInsets.all(AppSizes.paddingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                          : const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('d MMMM yyyy', 'uk_UA').format(date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${dayTotal.toStringAsFixed(2)} ₴',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Всього за день',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...dateItems.entries.map((entry) {
            final listId = entry.key;
            final items = entry.value;
            final listTotal = items.fold<double>(
              0,
              (sum, item) => sum + (item.price ?? 0),
            );
            final list = store.lists.firstWhere(
              (l) => l.id == listId,
              orElse: () => store.lists.first,
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: const Color(0xFF93C5FD), width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        list.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${listTotal.toStringAsFixed(2)} ₴',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...items.map((item) {
                    final category = item.categoryId != null
                        ? store.categories.firstWhere(
                            (c) => c.id == item.categoryId,
                            orElse: () => store.categories.firstWhere(
                              (c) => c.id == 'other',
                            ),
                          )
                        : store.categories.firstWhere((c) => c.id == 'other');

                    return _HistoryItemCard(
                      item: item,
                      category: category,
                      originalListId: listId,
                      store: store,
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HistoryItemCard extends StatefulWidget {
  final Item item;
  final Category category;
  final String originalListId;
  final AppStore store;

  const _HistoryItemCard({
    required this.item,
    required this.category,
    required this.originalListId,
    required this.store,
  });

  @override
  State<_HistoryItemCard> createState() => _HistoryItemCardState();
}

class _HistoryItemCardState extends State<_HistoryItemCard> {
  List<String> _selectedLists = [];

  Color _parseColor(String colorClass) {
    if (colorClass.contains('green')) return const Color(0xFF22C55E);
    if (colorClass.contains('blue')) return const Color(0xFF3B82F6);
    if (colorClass.contains('gray')) return const Color(0xFF6B7280);
    return const Color(0xFF6B7280);
  }

  void _repeatInOriginalList() {
    if (!mounted) return;

    try {
      final store = widget.store;
      ShoppingList? originalList;
      try {
        originalList = store.lists.firstWhere(
          (l) => l.id == widget.originalListId,
        );
      } catch (e) {
        if (store.lists.isNotEmpty) {
          originalList = store.lists.first;
        }
      }

      if (originalList == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Список не знайдено'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final storeWithoutListen = Provider.of<AppStore>(context, listen: false);
      final itemId = storeWithoutListen.addItem(
        listId: widget.originalListId,
        name: widget.item.name,
        quantity: widget.item.quantity,
        unit: widget.item.unit,
        price: widget.item.price,
        categoryId: widget.item.categoryId,
      );

      // Логування події відновлення айтема з історії
      FirebaseAnalytics.instance.logEvent(
        name: 'item_restored_from_history',
        parameters: {
          'item_id': itemId,
          'item_name': widget.item.name,
          'list_id': widget.originalListId,
          'quantity': widget.item.quantity,
          'unit': widget.item.unit.name,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Товар "${widget.item.name}" додано до списку "${originalList.name}"',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _openListSelectorModal() {
    showDialog(
      context: context,
      builder: (context) => _ListSelectorModal(
        item: widget.item,
        lists: widget.store.lists,
        selectedLists: [],
        onListSelection: (listId) {
          setState(() {
            if (_selectedLists.contains(listId)) {
              _selectedLists.remove(listId);
            } else {
              _selectedLists.add(listId);
            }
          });
        },
        onConfirm: () {
          if (_selectedLists.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Оберіть хоча б один список'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          _confirmAddToLists();
          Navigator.of(context).pop();
        },
        onCancel: () {
          setState(() {
            _selectedLists = [];
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _confirmAddToLists() async {
    if (!mounted) return;

    if (_selectedLists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Оберіть хоча б один список'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final store = Provider.of<AppStore>(context, listen: false);
    final restoredItemIds = <String>[];
    
    for (final listId in _selectedLists) {
      final itemId = await store.addItem(
        listId: listId,
        name: widget.item.name,
        quantity: widget.item.quantity,
        unit: widget.item.unit,
        price: widget.item.price,
        categoryId: widget.item.categoryId,
      );
      restoredItemIds.add(itemId);
    }

    // Логування події відновлення айтема з історії
    FirebaseAnalytics.instance.logEvent(
      name: 'item_restored_from_history',
      parameters: {
        'item_name': widget.item.name,
        'lists_count': _selectedLists.length,
        'quantity': widget.item.quantity,
        'unit': widget.item.unit.name,
      },
    );

    final listNames = _selectedLists
        .map((id) => store.lists.firstWhere((l) => l.id == id).name)
        .join(', ');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Товар "${widget.item.name}" додано до ${_selectedLists.length} списків: $listNames',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _selectedLists = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
      padding: const EdgeInsets.all(AppSizes.spacingMD),
      decoration: BoxDecoration(
        color: AppColorScheme.getBgTertiary(context),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColorScheme.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Text(
                      '${widget.item.quantity} ${widget.item.unit.label}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColorScheme.getTextSecondary(context),
                        fontSize: AppSizes.inputFontSize,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingSM,
                          vertical: AppSizes.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: _parseColor(widget.category.color),
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadiusMedium,
                          ),
                        ),
                        child: Text(
                          widget.category.nameUk,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.inputFontSize,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingSM),
                      Text(
                        '${(widget.item.price ?? 0).toStringAsFixed(2)} ₴',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColorScheme.getTextPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _repeatInOriginalList();
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.repeat,
                        size: 16,
                        color: AppColorScheme.getTextTertiary(context),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _openListSelectorModal();
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: AppColorScheme.getTextTertiary(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListSelectorModal extends StatefulWidget {
  final Item item;
  final List<ShoppingList> lists;
  final List<String> selectedLists;
  final ValueChanged<String> onListSelection;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ListSelectorModal({
    required this.item,
    required this.lists,
    required this.selectedLists,
    required this.onListSelection,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_ListSelectorModal> createState() => _ListSelectorModalState();
}

class _ListSelectorModalState extends State<_ListSelectorModal> {
  late List<String> _selectedLists;

  @override
  void initState() {
    super.initState();
    _selectedLists = List.from(widget.selectedLists);
  }

  void _handleListSelection(String listId) {
    setState(() {
      if (_selectedLists.contains(listId)) {
        _selectedLists.remove(listId);
      } else {
        _selectedLists.add(listId);
      }
    });
    widget.onListSelection(listId);
  }

  void _handleConfirm() {
    if (_selectedLists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Оберіть хоча б один список'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.modalOverlay,
      child: Center(
        child: Dialog(
          backgroundColor: AppColorScheme.getBgPrimary(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingXXL),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Додати товар до списків',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColorScheme.getTextPrimary(context),
                              ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppColorScheme.getTextTertiary(context),
                        ),
                        onPressed: widget.onCancel,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AppColorScheme.getBorderLight(context),
                  height: 1,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingXXL),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.spacingMD),
                    decoration: BoxDecoration(
                      color: AppColorScheme.getBgTertiary(context),
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusSmall,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColorScheme.getTextPrimary(context),
                                ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingSM),
                        Text(
                          '${widget.item.quantity} ${widget.item.unit.label}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColorScheme.getTextSecondary(context),
                              ),
                        ),
                        const SizedBox(width: AppSizes.paddingSM),
                        Text(
                          '${(widget.item.price ?? 0).toStringAsFixed(2)} ₴',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColorScheme.getTextPrimary(context),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Lists
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingXXL,
                    ),
                    child: Column(
                      children: widget.lists.map((list) {
                        final isSelected = _selectedLists.contains(list.id);
                        return InkWell(
                          onTap: () => _handleListSelection(list.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.paddingSM,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) =>
                                      _handleListSelection(list.id),
                                  activeColor: AppColors.primary,
                                ),
                                const SizedBox(width: AppSizes.paddingSM),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: list.color != null
                                        ? ColorUtils.parseColor(list.color!)
                                        : AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.paddingSM),
                                Expanded(
                                  child: Text(
                                    list.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: AppColorScheme.getTextPrimary(
                                            context,
                                          ),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingXXL),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            padding: AppSizes.buttonPadding,
                            minimumSize: const Size(0, AppSizes.buttonHeight),
                            side: BorderSide(
                              color: AppColorScheme.getBorderMedium(context),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.buttonBorderRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            'Скасувати',
                            style: TextStyle(
                              color: AppColorScheme.getTextPrimary(context),
                              fontSize: AppSizes.buttonFontSize,
                              fontWeight: AppSizes.buttonFontWeight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingSM),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedLists.isEmpty
                              ? null
                              : _handleConfirm,
                          style: ElevatedButton.styleFrom(
                            padding: AppSizes.buttonPadding,
                            minimumSize: const Size(0, AppSizes.buttonHeight),
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.gray400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.buttonBorderRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            'Додати (${_selectedLists.length})',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppSizes.buttonFontSize,
                              fontWeight: AppSizes.buttonFontWeight,
                            ),
                          ),
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

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Немає історії покупок',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Ваша історія покупок з\'явиться тут після перших покупок',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
