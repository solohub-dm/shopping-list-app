import 'package:flutter/material.dart';
import 'package:shopping_list_app/utils/app_constants.dart';

class SortOption {
  final String value;
  final String label;

  const SortOption({
    required this.value,
    required this.label,
  });
}

class SortDropdown extends StatelessWidget {
  final String value;
  final List<SortOption> options;
  final ValueChanged<String>? onChanged;
  final IconData? icon;

  const SortDropdown({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
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
          padding: AppSizes.dropdownPadding,
          decoration: BoxDecoration(
            color: AppColorScheme.getBgPrimary(context),
            borderRadius: BorderRadius.circular(AppSizes.dropdownBorderRadius),
            border: Border.all(
              color: AppColorScheme.getBorderMedium(context),
              width: AppSizes.borderWidthThin,
            ),
          ),
          child: DropdownButton<String>(
            value: value,
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
            items: options.map((option) {
              return DropdownMenuItem(
                value: option.value,
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: AppSizes.dropdownFontSize,
                    color: AppColorScheme.getTextPrimary(context),
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged?.call(newValue);
              }
            },
          ),
        ),
      ],
    );
  }
}

