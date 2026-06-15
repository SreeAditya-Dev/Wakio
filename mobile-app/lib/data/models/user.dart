class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime? createdAt;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
}
