// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      isActive: json['is_active'] as bool? ?? true,
      profileImageUrl: json['profile_image_url'] as String?,
      googleId: json['google_id'] as String?,
      shopId: (json['shop_id'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] == null
          ? null
          : DateTime.parse(json['last_login_at'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'is_active': instance.isActive,
      'profile_image_url': instance.profileImageUrl,
      'google_id': instance.googleId,
      'shop_id': instance.shopId,
      'created_at': instance.createdAt.toIso8601String(),
      'last_login_at': instance.lastLoginAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.owner: 'owner',
  UserRole.salesPerson: 'sales_person',
};
