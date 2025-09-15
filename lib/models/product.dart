impor@JsonSerializable()
class Product extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double price;
  @JsonKey(name: 'cost_price')
  final double costPrice;
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  final String? barcode;
  final String sku;
  final String category;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'shop_id')
  final int? shopId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    this.barcode,
    required this.sku,:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'product.g.dart';

@JsonSerializable()
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final String? barcode;
  final String? sku;
  final String category;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    this.barcode,
    this.sku,
    required this.category,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? costPrice,
    int? stockQuantity,
    String? barcode,
    String? sku,
    String? category,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    costPrice,
    stockQuantity,
    barcode,
    sku,
    category,
    imageUrl,
    isActive,
    createdAt,
    updatedAt,
  ];
}
