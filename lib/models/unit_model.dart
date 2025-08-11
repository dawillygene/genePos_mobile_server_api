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
}
