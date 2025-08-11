class Currency {
  final int? id;
  final String name;
  final String code;
  final String symbol;
  final bool active;
  final String? createdAt;
  final String? updatedAt;

  Currency({
    this.id,
    required this.name,
    required this.code,
    required this.symbol,
    this.active = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'symbol': symbol,
      'active': active ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
