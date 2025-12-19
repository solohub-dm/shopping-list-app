class Session {
  final String? userId;
  final String? token;
  final DateTime? lastLoginAt;

  Session({
    this.userId,
    this.token,
    this.lastLoginAt,
  });

  Session copyWith({
    String? userId,
    String? token,
    DateTime? lastLoginAt,
  }) {
    return Session(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  bool get isAuthenticated => userId != null;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'token': token,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      userId: json['userId'] as String?,
      token: json['token'] as String?,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }
}

