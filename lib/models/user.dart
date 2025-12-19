enum UserSegment {
  personal,
  corporate,
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String? avatar;
  final UserSegment segment;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.avatar,
    required this.segment,
    required this.createdAt,
    this.lastLoginAt,
  });

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? avatar,
    UserSegment? segment,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      segment: segment ?? this.segment,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'avatar': avatar,
      'segment': segment.name,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      avatar: json['avatar'] as String?,
      segment: UserSegment.values.firstWhere(
        (e) => e.name == json['segment'],
        orElse: () => UserSegment.personal,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }
}

