import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping_list_app/utils/app_constants.dart';

class ShareListModal extends StatefulWidget {
  final String listId;
  final String listName;
  final VoidCallback onClose;

  const ShareListModal({
    super.key,
    required this.listId,
    required this.listName,
    required this.onClose,
  });

  @override
  State<ShareListModal> createState() => _ShareListModalState();
}

class _ShareListModalState extends State<ShareListModal> {
  final _emailController = TextEditingController();
  bool _copied = false;

  String get _shareUrl => 'https://shopping-list.app/list/${widget.listId}';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleInvite() {
    if (_emailController.text.trim().isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Запрошення надіслано на ${_emailController.text}'),
      ),
    );

    _emailController.clear();
  }

  Future<void> _handleCopyLink() async {
    await Clipboard.setData( ClipboardData(text: _shareUrl));
    setState(() => _copied = true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Посилання скопійовано в буфер обміну')),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
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
                          'Поділитися списком',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AppColorScheme.getBorderLight(context),
                  height: 1,
                  thickness: 1,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingXXL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Список: ${widget.listName}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColorScheme.getTextPrimary(context),
                              ),
                        ),
                        const SizedBox(height: AppSizes.paddingXXL),
                        Text(
                          'Запросити за email',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColorScheme.getTextPrimary(context),
                              ),
                        ),
                        const SizedBox(height: AppSizes.spacingMD),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                style: TextStyle(
                                  color: AppColorScheme.getTextPrimary(context),
                                  fontSize: AppSizes.inputFontSize,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'email@example.com',
                                  hintStyle: TextStyle(
                                    color: AppColorScheme.getTextTertiary(context),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppColorScheme.getTextTertiary(context),
                                    size: AppSizes.inputIconSize,
                                  ),
                                  filled: true,
                                  fillColor: AppColorScheme.getBgPrimary(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
                                    borderSide: BorderSide(
                                      color: AppColorScheme.getBorderMedium(context),
                                      width: AppSizes.borderWidthThin,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
                                    borderSide: BorderSide(
                                      color: AppColorScheme.getBorderMedium(context),
                                      width: AppSizes.borderWidthThin,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: AppSizes.borderWidthMedium,
                                    ),
                                  ),
                                  contentPadding: AppSizes.inputPadding,
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingSM),
                            ElevatedButton.icon(
                              onPressed: _handleInvite,
                              icon: const Icon(
                                Icons.person_add,
                                size: AppSizes.iconSizeSmall,
                              ),
                              label: const Text('Запросити'),
                              style: ElevatedButton.styleFrom(
                                padding: AppSizes.buttonPadding,
                                minimumSize: const Size(0, AppSizes.buttonHeight),
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingXXL),
                        Divider(
                          color: AppColorScheme.getBorderLight(context),
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: AppSizes.paddingXXL),
                        Text(
                          'Посилання для спільного доступу',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColorScheme.getTextPrimary(context),
                              ),
                        ),
                        const SizedBox(height: AppSizes.spacingMD),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.spacingMD,
                            vertical: AppSizes.paddingSM,
                          ),
                          decoration: BoxDecoration(
                            color: AppColorScheme.getBgTertiary(context),
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                            border: Border.all(
                              color: AppColorScheme.getBorderMedium(context),
                              width: AppSizes.borderWidthThin,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _shareUrl,
                                  style: TextStyle(
                                    fontSize: AppSizes.inputFontSize,
                                    color: AppColorScheme.getTextPrimary(context),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSizes.paddingSM),
                              IconButton(
                                icon: Icon(
                                  _copied ? Icons.check : Icons.copy,
                                  size: AppSizes.iconSizeSmall,
                                  color: AppColorScheme.getTextSecondary(context),
                                ),
                                onPressed: _handleCopyLink,
                                tooltip: 'Копіювати посилання',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXXL),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: widget.onClose,
                            style: OutlinedButton.styleFrom(
                              padding: AppSizes.buttonPadding,
                              minimumSize: const Size(0, AppSizes.buttonHeight),
                              side: BorderSide(
                                color: AppColorScheme.getBorderMedium(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
                              ),
                            ),
                            child: Text(
                              'Закрити',
                              style: TextStyle(
                                color: AppColorScheme.getTextPrimary(context),
                                fontSize: AppSizes.buttonFontSize,
                                fontWeight: AppSizes.buttonFontWeight,
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
          ),
        ),
      ),
    );
  }
}

