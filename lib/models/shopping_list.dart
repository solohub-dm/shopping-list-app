class ShoppingList {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? color;
  final List<String> participants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final bool archived;

  ShoppingList({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.color,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.archived = false,
  });

  ShoppingList copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? color,
    List<String>? participants,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    bool? archived,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      archived: archived ?? this.archived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'color': color,
      'participants': participants,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'archived': archived,
    };
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      participants: List<String>.from(json['participants'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      archived: json['archived'] as bool? ?? false,
    );
  }
}

