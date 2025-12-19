import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/models/item.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AddItemModal extends StatefulWidget {
  final String listId;
  final VoidCallback onClose;

  const AddItemModal({super.key, required this.listId, required this.onClose});

  @override
  State<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  Unit _selectedUnit = Unit.pcs;
  String? _selectedCategoryId;

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
    final itemName = _nameController.text.trim();
    final quantity = double.tryParse(_quantityController.text) ?? 1;
    final price = _priceController.text.isNotEmpty
        ? double.tryParse(_priceController.text)
        : null;

    final itemId = await store.addItem(
      listId: widget.listId,
      name: itemName,
      quantity: quantity,
      unit: _selectedUnit,
      price: price,
      categoryId: _selectedCategoryId,
    );

    // Логування події створення айтема
    FirebaseAnalytics.instance.logEvent(
      name: 'item_created',
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'list_id': widget.listId,
        'quantity': quantity,
        'unit': _selectedUnit.name,
        'has_price': (price != null) ? 1 : 0,
        'has_category': (_selectedCategoryId != null) ? 1 : 0,
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Товар "$itemName" додано до списку')),
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
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Додати товар',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(24),
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
                              return 'Введіть назву товару';
                            }
                            return null;
                          },
                          autofocus: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Кількість',
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
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Без категорії'),
                            ),
                            ...categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.nameUk),
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
                                child: const Text('Додати'),
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
}
