enum ItemStatus { purchased, pending }

enum Unit { pcs, kg, l, g, ml }

extension UnitExtension on Unit {
  String get label {
    switch (this) {
      case Unit.pcs:
        return 'шт.';
      case Unit.kg:
        return 'кг';
      case Unit.l:
        return 'л';
      case Unit.g:
        return 'г';
      case Unit.ml:
        return 'мл';
    }
  }
}

class Item {
  final String id;
  final String listId;
  final String name;
  final double quantity;
  final Unit unit;
  final double? price;
  final String? categoryId;
  final ItemStatus status;
  final DateTime createdAt;
  final DateTime? purchasedAt;

  Item({
    required this.id,
    required this.listId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.price,
    this.categoryId,
    required this.status,
    required this.createdAt,
    this.purchasedAt,
  });

  Item copyWith({
    String? id,
    String? listId,
    String? name,
    double? quantity,
    Unit? unit,
    double? price,
    String? categoryId,
    ItemStatus? status,
    DateTime? createdAt,
    DateTime? purchasedAt,
  }) {
    return Item(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'name': name,
      'quantity': quantity,
      'unit': unit.name,
      'price': price,
      'categoryId': categoryId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'purchasedAt': purchasedAt?.toIso8601String(),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      listId: json['listId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: Unit.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => Unit.pcs,
      ),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      categoryId: json['categoryId'] as String?,
      status: ItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ItemStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.parse(json['purchasedAt'] as String)
          : null,
    );
  }
}

