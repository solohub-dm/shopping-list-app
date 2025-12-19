import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/models/shopping_list.dart';
import 'package:shopping_list_app/utils/app_constants.dart';
import 'package:shopping_list_app/widgets/modals/delete_confirm_modal.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class EditListModal extends StatefulWidget {
  final ShoppingList list;
  final VoidCallback onClose;

  const EditListModal({super.key, required this.list, required this.onClose});

  @override
  State<EditListModal> createState() => _EditListModalState();
}

class _EditListModalState extends State<EditListModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedColor;
  bool _showDeleteConfirm = false;

  final List<String> _colors = [
    '#3b82f6', // blue
    '#10b981', // emerald
    '#f59e0b', // amber
    '#ef4444', // red
    '#8b5cf6', // violet
    '#06b6d4', // cyan
    '#84cc16', // lime
    '#f97316', // orange
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.list.name);
    _descriptionController = TextEditingController(
      text: widget.list.description ?? '',
    );
    _selectedColor = widget.list.color ?? _colors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final store = Provider.of<AppStore>(context, listen: false);
    final updatedList = widget.list.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      color: _selectedColor,
    );

    await store.updateList(updatedList);

    // Логування події редагування списку
    FirebaseAnalytics.instance.logEvent(
      name: 'list_updated',
      parameters: {
        'list_id': widget.list.id,
        'list_name': updatedList.name,
        'has_description': (updatedList.description != null) ? 1 : 0,
        'color': updatedList.color ?? '',
        'name_changed': (widget.list.name != updatedList.name) ? 1 : 0,
        'description_changed':
            (widget.list.description != updatedList.description) ? 1 : 0,
        'color_changed': (widget.list.color != updatedList.color) ? 1 : 0,
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Список оновлено')));

    widget.onClose();
  }

  Future<void> _handleDelete() async {
    final store = Provider.of<AppStore>(context, listen: false);
    final listId = widget.list.id;
    final listName = widget.list.name;

    await store.removeList(listId);

    // Логування події видалення списку
    FirebaseAnalytics.instance.logEvent(
      name: 'list_deleted',
      parameters: {'list_id': listId, 'list_name': listName},
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Список "$listName" видалено')));

    widget.onClose();
    context.go('/');
  }

  void _showDeleteDialog() {
    setState(() => _showDeleteConfirm = true);
  }

  void _hideDeleteDialog() {
    setState(() => _showDeleteConfirm = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Material(
          color: AppColors.modalOverlay,
          child: Center(
            child: Dialog(
              backgroundColor: AppColorScheme.getBgPrimary(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.borderRadiusMedium,
                ),
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
                          Text(
                            'Редагувати список',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColorScheme.getTextPrimary(context),
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                style: TextStyle(
                                  color: AppColorScheme.getTextPrimary(context),
                                  fontSize: AppSizes.inputFontSize,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Назва списку *',
                                  labelStyle: TextStyle(
                                    color: AppColorScheme.getTextSecondary(
                                      context,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Введіть назву';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.spacingLG),
                              TextFormField(
                                controller: _descriptionController,
                                style: TextStyle(
                                  color: AppColorScheme.getTextPrimary(context),
                                  fontSize: AppSizes.inputFontSize,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Опис (необов\'язково)',
                                  labelStyle: TextStyle(
                                    color: AppColorScheme.getTextSecondary(
                                      context,
                                    ),
                                  ),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: AppSizes.spacingLG),
                              Row(
                                children: [
                                  Icon(
                                    Icons.palette,
                                    size: AppSizes.iconSizeSmall,
                                    color: AppColorScheme.getTextTertiary(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.paddingSM),
                                  Text(
                                    'Колір теми',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColorScheme.getTextPrimary(
                                            context,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.paddingSM),
                              Wrap(
                                spacing: AppSizes.paddingSM,
                                children: _colors.map((color) {
                                  final isSelected = _selectedColor == color;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedColor = color),
                                    child: Container(
                                      width: AppSizes.iconSizeLarge + 8,
                                      height: AppSizes.iconSizeLarge + 8,
                                      decoration: BoxDecoration(
                                        color: _colorFromHex(color),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? (isDark
                                                    ? Colors.white
                                                    : Colors.black)
                                              : AppColorScheme.getBorderMedium(
                                                  context,
                                                ),
                                          width: isSelected
                                              ? AppSizes.borderWidthMedium
                                              : AppSizes.borderWidthThin,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: AppSizes.paddingXXL),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: widget.onClose,
                                      style: OutlinedButton.styleFrom(
                                        padding: AppSizes.buttonPadding,
                                        minimumSize: const Size(
                                          0,
                                          AppSizes.buttonHeight,
                                        ),
                                        side: BorderSide(
                                          color: AppColorScheme.getBorderMedium(
                                            context,
                                          ),
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
                                          color: AppColorScheme.getTextPrimary(
                                            context,
                                          ),
                                          fontSize: AppSizes.buttonFontSize,
                                          fontWeight: AppSizes.buttonFontWeight,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.spacingLG),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        padding: AppSizes.buttonPadding,
                                        minimumSize: const Size(
                                          0,
                                          AppSizes.buttonHeight,
                                        ),
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.buttonBorderRadius,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Зберегти зміни',
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
                              const SizedBox(height: AppSizes.spacingLG),
                              Divider(
                                color: AppColorScheme.getBorderLight(context),
                                height: 1,
                                thickness: 1,
                              ),
                              const SizedBox(height: AppSizes.paddingSM),
                              OutlinedButton.icon(
                                onPressed: _showDeleteDialog,
                                icon: Icon(
                                  Icons.delete,
                                  color: AppColors.error,
                                  size: AppSizes.iconSizeSmall,
                                ),
                                label: Text(
                                  'Видалити список',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: AppSizes.buttonFontSize,
                                    fontWeight: AppSizes.buttonFontWeight,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.error),
                                  padding: AppSizes.buttonPadding,
                                  minimumSize: const Size(
                                    0,
                                    AppSizes.buttonHeight,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.buttonBorderRadius,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_showDeleteConfirm)
          DeleteConfirmModal(
            title: 'Підтвердження видалення',
            message:
                'Ви впевнені, що хочете видалити список "${widget.list.name}"? Цю дію неможливо скасувати.',
            onConfirm: () {
              _hideDeleteDialog();
              _handleDelete();
            },
            onCancel: _hideDeleteDialog,
          ),
      ],
    );
  }

  Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
