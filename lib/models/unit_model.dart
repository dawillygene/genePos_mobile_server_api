class Unit {
  final int? id;
  final String title;
  final String shortName;
  final String? createdAt;
  final String? updatedAt;

  Unit({
    this.id,
    required this.title,
    required this.shortName,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'short_name': shortName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'],
      title: map['title'],
      shortName: map['short_name'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Unit copyWith({
    int? id,
    String? title,
    String? shortName,
    String? createdAt,
    String? updatedAt,
  }) {
    return Unit(
      id: id ?? this.id,
      title: title ?? this.title,
      shortName: shortName ?? this.shortName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
