import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class CreateListModal extends StatefulWidget {
  final VoidCallback onClose;

  const CreateListModal({super.key, required this.onClose});

  @override
  State<CreateListModal> createState() => _CreateListModalState();
}

class _CreateListModalState extends State<CreateListModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#3b82f6';
  DateTime? _dueDate;

  final List<String> _colors = [
    '#3b82f6',
    '#10b981',
    '#f59e0b',
    '#ef4444',
    '#8b5cf6',
    '#06b6d4',
    '#84cc16',
    '#f97316',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дата закінчення є обов\'язковою')),
      );
      return;
    }

    final store = Provider.of<AppStore>(context, listen: false);
    final userId = store.session.userId;
    if (userId == null) return;

    final listId = await store.addList(
      ownerId: userId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      color: _selectedColor,
      dueDate: _dueDate,
    );

    // Логування події створення списку
    FirebaseAnalytics.instance.logEvent(
      name: 'list_created',
      parameters: {
        'list_id': listId,
        'list_name': _nameController.text.trim(),
        'has_description': _descriptionController.text.trim().isNotEmpty
            ? 1
            : 0,
        'color': _selectedColor,
      },
    );

    store.setCurrentList(listId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Список "${_nameController.text.trim()}" успішно створено',
        ),
      ),
    );

    widget.onClose();
    context.go('/list/$listId');
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: AppColors.modalOverlay,
      child: Center(
        child: Card(
          color: AppColorScheme.getBgPrimary(context),
          margin: const EdgeInsets.all(AppSizes.paddingXXL),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingXXL),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Створити новий список',
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
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingXXL),
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
                              color: AppColorScheme.getTextSecondary(context),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введіть назву списку';
                            }
                            return null;
                          },
                          autofocus: true,
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
                              color: AppColorScheme.getTextSecondary(context),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppSizes.spacingLG),
                        InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Дата закінчення *',
                              labelStyle: TextStyle(
                                color: AppColorScheme.getTextSecondary(context),
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: AppColorScheme.getTextTertiary(context),
                              ),
                            ),
                            child: Text(
                              _dueDate != null
                                  ? '${_dueDate!.day}.${_dueDate!.month}.${_dueDate!.year}'
                                  : 'Оберіть дату',
                              style: TextStyle(
                                color: _dueDate != null
                                    ? AppColorScheme.getTextPrimary(context)
                                    : AppColorScheme.getTextTertiary(context),
                                fontSize: AppSizes.inputFontSize,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingLG),
                        Text(
                          'Колір теми',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColorScheme.getTextPrimary(context),
                              ),
                        ),
                        const SizedBox(height: AppSizes.paddingSM),
                        Wrap(
                          spacing: AppSizes.paddingSM,
                          children: _colors.map((color) {
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColor = color),
                              child: Container(
                                width: AppSizes.iconSizeLarge + 8,
                                height: AppSizes.iconSizeLarge + 8,
                                decoration: BoxDecoration(
                                  color: _parseColor(color),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedColor == color
                                        ? (isDark ? Colors.white : Colors.black)
                                        : Colors.transparent,
                                    width: AppSizes.borderWidthMedium,
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
                                  'Створити',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.blue;
    }
  }
}
