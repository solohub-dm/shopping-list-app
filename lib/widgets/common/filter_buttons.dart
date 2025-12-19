import 'package:flutter/material.dart';
import 'package:shopping_list_app/utils/app_constants.dart';

class FilterOption {
  final String value;
  final String label;

  const FilterOption({
    required this.value,
    required this.label,
  });
}

class FilterButtons extends StatelessWidget {
  final String selectedValue;
  final List<FilterOption> options;
  final ValueChanged<String> onChanged;
  final IconData? icon;

  const FilterButtons({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: AppSizes.iconSizeSmall,
            color: AppColorScheme.getTextTertiary(context),
          ),
          const SizedBox(width: AppSizes.paddingSM),
        ],
        Container(
          height: AppSizes.dropdownHeight,
          decoration: BoxDecoration(
            color: AppColorScheme.getBgTertiary(context),
            borderRadius: BorderRadius.circular(AppSizes.dropdownBorderRadius),
          ),
          padding: const EdgeInsets.all(AppSizes.paddingXS),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return _FilterButton(
                label: option.label,
                isSelected: selectedValue == option.value,
                onTap: () => onChanged(option.value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingXS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColorScheme.getBgPrimary(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.dropdownFontSize,
            color: isSelected
                ? AppColorScheme.getTextPrimary(context)
                : AppColorScheme.getTextSecondary(context),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

