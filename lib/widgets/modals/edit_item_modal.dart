import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/models/item.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class EditItemModal extends StatefulWidget {
  final Item item;
  final VoidCallback onClose;

  const EditItemModal({super.key, required this.item, required this.onClose});

  @override
  State<EditItemModal> createState() => _EditItemModalState();
}

class _EditItemModalState extends State<EditItemModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late Unit _selectedUnit;
  String? _selectedCategoryId;
  bool _showDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(text: widget.item.quantity.toString());
    _priceController = TextEditingController(text: widget.item.price?.toString() ?? '');
    _selectedUnit = widget.item.unit;
    _selectedCategoryId = widget.item.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final store = Provider.of<AppStore>(context, listen: false);
    final updatedItem = widget.item.copyWith(
      name: _nameController.text.trim(),
      quantity: double.tryParse(_quantityController.text) ?? 1,
      unit: _selectedUnit,
      price: _priceController.text.isNotEmpty
          ? double.tryParse(_priceController.text)
          : null,
      categoryId: _selectedCategoryId,
    );
    
    await store.updateItem(updatedItem);

    // Логування події редагування айтема
    FirebaseAnalytics.instance.logEvent(
      name: 'item_updated',
      parameters: {
        'item_id': widget.item.id,
        'item_name': updatedItem.name,
        'list_id': widget.item.listId,
        'quantity': updatedItem.quantity,
        'unit': updatedItem.unit.name,
        'has_price': (updatedItem.price != null) ? 1 : 0,
        'has_category': (updatedItem.categoryId != null) ? 1 : 0,
        'name_changed': (widget.item.name != updatedItem.name) ? 1 : 0,
        'quantity_changed': (widget.item.quantity != updatedItem.quantity) ? 1 : 0,
        'price_changed': (widget.item.price != updatedItem.price) ? 1 : 0,
        'category_changed': (widget.item.categoryId != updatedItem.categoryId) ? 1 : 0,
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Товар "${updatedItem.name}" оновлено')),
    );

    widget.onClose();
  }

  Future<void> _handleDelete() async {
    final store = Provider.of<AppStore>(context, listen: false);
    await store.removeItem(widget.item.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Товар "${widget.item.name}" видалено')),
    );

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<AppStore>(context);
    final categories = store.categories;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Dialog(
          backgroundColor: Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Редагувати товар',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Назва товару *',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введіть назву';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Кількість *',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введіть кількість';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Неправильне число';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<Unit>(
                              initialValue: _selectedUnit,
                              decoration: const InputDecoration(
                                labelText: 'Одиниця',
                              ),
                              items: Unit.values.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit.label),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedUnit = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Ціна (необов\'язково)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Категорія',
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Без категорії'),
                          ),
                          ...categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.nameUk),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategoryId = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onClose,
                              child: const Text('Скасувати'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              child: const Text('Зберегти'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_showDeleteConfirm)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Ви впевнені, що хочете видалити цей товар?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => setState(() => _showDeleteConfirm = false),
                                      child: const Text('Скасувати'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _handleDelete,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Видалити'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _showDeleteConfirm = true),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Видалити товар',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
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
    );
  }
}

