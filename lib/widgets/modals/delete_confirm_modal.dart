import 'package:flutter/material.dart';
import 'package:shopping_list_app/utils/app_constants.dart';

class DeleteConfirmModal extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DeleteConfirmModal({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.modalOverlay,
      child: Center(
        child: Dialog(
          backgroundColor: AppColorScheme.getBgPrimary(context),
          child: Container(
            constraints: const BoxConstraints(maxWidth: AppSizes.modalMaxWidth),
            padding: const EdgeInsets.all(AppSizes.paddingXXL),
            decoration: BoxDecoration(
              color: AppColorScheme.getBgPrimary(context),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.paddingLG),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColorScheme.getTextSecondary(context),
                  ),
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Скасувати'),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMD),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Видалити'),
                  ),
                ),
              ],
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

