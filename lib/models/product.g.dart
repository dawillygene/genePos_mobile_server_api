// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      costPrice: (json['cost_price'] as num).toDouble(),
      stockQuantity: (json['stock_quantity'] as num).toInt(),
      barcode: json['barcode'] as String?,
      sku: json['sku'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      shopId: (json['shop_id'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'cost_price': instance.costPrice,
      'stock_quantity': instance.stockQuantity,
      'barcode': instance.barcode,
      'sku': instance.sku,
      'category': instance.category,
      'image_url': instance.imageUrl,
      'is_active': instance.isActive,
      'shop_id': instance.shopId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
