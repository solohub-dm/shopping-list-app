import 'package:flutter/material.dart';
import 'package:shopping_list_app/utils/app_constants.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final String? label;
  final String? hint;

  const GradientButton({
    super.key,
    this.onPressed,
    required this.child,
    this.icon,
    this.label,
    this.hint,
  });

  const GradientButton.icon({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
    this.hint,
  }) : child = const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    final buttonChild = icon != null && label != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSizes.iconSizeSmall),
              const SizedBox(width: AppSizes.paddingSM),
              Text(label!),
              if (hint != null) ...[
                const SizedBox(width: AppSizes.paddingXS),
                Text(
                  hint!,
                  style: TextStyle(
                    fontSize: AppSizes.inputFontSize,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ],
          )
        : child;

    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? const LinearGradient(
                colors: [
                  AppColors.primary, // blue-600
                  Color(0xFF4F46E5), // indigo-600
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: onPressed == null ? AppColors.gray400 : null,
        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
          child: Container(
            height: AppSizes.buttonHeight,
            padding: AppSizes.buttonPadding,
            alignment: Alignment.center,
            child: DefaultTextStyle(
              style: TextStyle(
                color: Colors.white,
                fontWeight: AppSizes.buttonFontWeight,
                fontSize: AppSizes.buttonFontSize,
              ),
              child: buttonChild,
            ),
          ),
        ),
      ),
    );
  }
}

