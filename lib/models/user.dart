import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

enum UserRole { 
  @JsonValue('owner')
  owner, 
  @JsonValue('sales_person')
  salesPerson 
}

@JsonSerializable()
class User extends Equatable {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  @JsonKey(name: 'google_id')
  final String? googleId;
  @JsonKey(name: 'shop_id')
  final int? shopId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.isActive = true,
    this.profileImageUrl,
    this.googleId,
    this.shopId,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    bool? isActive,
    String? profileImageUrl,
    String? googleId,
    int? shopId,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      googleId: googleId ?? this.googleId,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    role,
    isActive,
    profileImageUrl,
    googleId,
    shopId,
    createdAt,
    lastLoginAt,
  ];
}
