import 'package:flutter/material.dart';
import 'package:shopping_list_app/widgets/common/search_field.dart';
import 'package:shopping_list_app/widgets/common/sort_dropdown.dart';
import 'package:shopping_list_app/widgets/common/filter_buttons.dart';
import 'package:shopping_list_app/utils/app_constants.dart';
import 'package:shopping_list_app/utils/responsive.dart';

class DashboardToolbar extends StatelessWidget {
  final String searchTerm;
  final String sortBy;
  final String filterBy;
  final String viewMode;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onViewModeChanged;
  final int? resultsCount;

  const DashboardToolbar({
    super.key,
    required this.searchTerm,
    required this.sortBy,
    required this.filterBy,
    required this.viewMode,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onFilterChanged,
    required this.onViewModeChanged,
    this.resultsCount,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColorScheme.getBgPrimary(context),
        borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
        border: Border.all(
          color: AppColorScheme.getBorderLight(context),
          width: AppSizes.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(responsive.isMobile ? AppSizes.paddingMD : AppSizes.spacingLG),
      child: Column(
        children: [
          responsive.isMobile
              ? Column(
                  children: [
                    SearchField(
                      hintText: 'Знайти список...',
                      onChanged: onSearchChanged,
                      value: searchTerm,
                    ),
                    SizedBox(height: responsive.spacing),
                    if (viewMode == 'grid')
                      SortDropdown(
                        value: sortBy,
                        icon: Icons.swap_vert,
                        options: const [
                          SortOption(value: 'default', label: 'Спочатку новіші'),
                          SortOption(value: 'name-asc', label: 'За назвою (А-Я)'),
                          SortOption(value: 'name-desc', label: 'За назвою (Я-А)'),
                          SortOption(value: 'created-old', label: 'Спочатку старіші'),
                          SortOption(value: 'due-soon', label: 'Спочатку найближчі'),
                          SortOption(value: 'due-late', label: 'Спочатку найпізніші'),
                        ],
                        onChanged: onSortChanged,
                      ),
                    if (viewMode == 'grid') SizedBox(height: responsive.spacing),
                    FilterButtons(
                      selectedValue: filterBy,
                      icon: Icons.filter_list,
                      options: const [
                        FilterOption(value: 'all', label: 'Всі'),
                        FilterOption(value: 'active', label: 'Активні'),
                        FilterOption(value: 'completed', label: 'Завершені'),
                        FilterOption(value: 'overdue', label: 'Прострочені'),
                      ],
                      onChanged: onFilterChanged,
                    ),
                    SizedBox(height: responsive.spacing),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColorScheme.getBgTertiary(context),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                      ),
                      padding: const EdgeInsets.all(AppSizes.paddingXS),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ViewModeButton(
                            icon: Icons.grid_view,
                            isSelected: viewMode == 'grid',
                            onTap: () => onViewModeChanged('grid'),
                            tooltip: 'Сітка списків',
                          ),
                          _ViewModeButton(
                            icon: Icons.calendar_today,
                            isSelected: viewMode == 'calendar',
                            onTap: () => onViewModeChanged('calendar'),
                            tooltip: 'Календар',
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        hintText: 'Знайти список...',
                        onChanged: onSearchChanged,
                        value: searchTerm,
                      ),
                    ),
                    if (viewMode == 'grid') ...[
                      SizedBox(width: responsive.spacing),
                      SortDropdown(
                        value: sortBy,
                        icon: Icons.swap_vert,
                        options: const [
                          SortOption(value: 'default', label: 'Спочатку новіші'),
                          SortOption(value: 'name-asc', label: 'За назвою (А-Я)'),
                          SortOption(value: 'name-desc', label: 'За назвою (Я-А)'),
                          SortOption(value: 'created-old', label: 'Спочатку старіші'),
                          SortOption(value: 'due-soon', label: 'Спочатку найближчі'),
                          SortOption(value: 'due-late', label: 'Спочатку найпізніші'),
                        ],
                        onChanged: onSortChanged,
                      ),
                    ],
                    SizedBox(width: responsive.spacing),
                    FilterButtons(
                      selectedValue: filterBy,
                      icon: Icons.filter_list,
                      options: const [
                        FilterOption(value: 'all', label: 'Всі'),
                        FilterOption(value: 'active', label: 'Активні'),
                        FilterOption(value: 'completed', label: 'Завершені'),
                        FilterOption(value: 'overdue', label: 'Прострочені'),
                      ],
                      onChanged: onFilterChanged,
                    ),
                    SizedBox(width: responsive.spacing),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColorScheme.getBgTertiary(context),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                      ),
                      padding: const EdgeInsets.all(AppSizes.paddingXS),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ViewModeButton(
                            icon: Icons.grid_view,
                            isSelected: viewMode == 'grid',
                            onTap: () => onViewModeChanged('grid'),
                            tooltip: 'Сітка списків',
                          ),
                          _ViewModeButton(
                            icon: Icons.calendar_today,
                            isSelected: viewMode == 'calendar',
                            onTap: () => onViewModeChanged('calendar'),
                            tooltip: 'Календар',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          if (searchTerm.isNotEmpty && resultsCount != null)
            Padding(
              padding: EdgeInsets.only(top: responsive.isMobile ? responsive.spacing : 8),
              child: Text(
                'Знайдено $resultsCount списків',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  const _ViewModeButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColorScheme.getBgPrimary(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: AppSizes.iconSizeSmall,
              color: isSelected
                  ? AppColorScheme.getTextPrimary(context)
                  : AppColorScheme.getTextSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}

