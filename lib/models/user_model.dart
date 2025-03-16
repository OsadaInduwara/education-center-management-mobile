// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String age;
  final String photoUrl;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.age,
    required this.photoUrl,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile, // initially empty string if not provided
      'age': age,       // initially empty string if not provided
      'photoUrl': photoUrl, // might be empty if not provided
      'role': role,
      'createdAt': createdAt.toIso8601String(), // or use FieldValue.serverTimestamp() on server-side
    };
  }

  // Optionally, add a fromMap if you need to read data back.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      age: map['age'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      role: map['role'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
