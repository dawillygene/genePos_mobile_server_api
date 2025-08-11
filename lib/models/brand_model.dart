class Brand {
  final int? id;
  final String? image;
  final String name;
  final String? description;
  final bool status;
  final String? createdAt;
  final String? updatedAt;

  Brand({
    this.id,
    this.image,
    required this.name,
    this.description,
    this.status = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'description': description,
      'status': status ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
