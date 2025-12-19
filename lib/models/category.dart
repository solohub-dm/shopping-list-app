class Category {
  final String id;
  final String nameUk;
  final String nameEn;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.nameUk,
    required this.nameEn,
    required this.icon,
    required this.color,
  });

  Category copyWith({
    String? id,
    String? nameUk,
    String? nameEn,
    String? icon,
    String? color,
  }) {
    return Category(
      id: id ?? this.id,
      nameUk: nameUk ?? this.nameUk,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameUk': nameUk,
      'nameEn': nameEn,
      'icon': icon,
      'color': color,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      nameUk: json['nameUk'] as String,
      nameEn: json['nameEn'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }
}

