import 'package:equatable/equatable.dart';

/// User model for authentication and user management
class User extends Equatable {
  final int? id;
  final String username;
  final String name;
  final String email;
  final String? password;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    required this.username,
    required this.name,
    required this.email,
    this.password,
    this.role = 'sales',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Create user from JSON/Map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      role: json['role'] as String? ?? 'sales',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Convert user to JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create copy with updated fields
  User copyWith({
    int? id,
    String? username,
    String? name,
    String? email,
    String? password,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if user is admin
  bool get isAdmin => role == 'admin';

  // Check if user is sales
  bool get isSales => role == 'sales';

  // Check if user is manager
  bool get isManager => role == 'manager';

  // Get display name
  String get displayName => name.isNotEmpty ? name : username;

  // Get role display name
  String get roleDisplayName {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'manager':
        return 'Manager';
      case 'sales':
        return 'Sales';
      default:
        return 'User';
    }
  }

  @override
  List<Object?> get props => [
    id,
    username,
    name,
    email,
    password,
    role,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name, email: $email, role: $role, isActive: $isActive)';
  }
}
