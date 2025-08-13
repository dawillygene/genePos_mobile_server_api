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

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(
      id: map['id'],
      image: map['image'],
      name: map['name'],
      description: map['description'],
      status: map['status'] == 1,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Brand copyWith({
    int? id,
    String? image,
    String? name,
    String? description,
    bool? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Brand(
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
