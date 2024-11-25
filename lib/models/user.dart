// lib/models/post_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String isRoot;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isRoot,
  });

  // Fungsi untuk memetakan JSON ke objek User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '', // Default to an empty string if null
      name: json['name'] ?? 'No Name', // Default name if null
      email: json['email'] ?? 'No Email',
      role: json['role'] ?? 'No role',
      isRoot: json['is_root']?.toString() ?? '',
    );
  }
}
