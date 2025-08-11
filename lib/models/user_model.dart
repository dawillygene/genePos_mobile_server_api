class User {
  final int? id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final String password;
  final String? rememberToken;
  final String username;
  final String? profileImage;
  final String? googleId;
  final bool isGoogleRegistered;
  final bool isSuspended;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.password,
    this.rememberToken,
    required this.username,
    this.profileImage,
    this.googleId,
    this.isGoogleRegistered = false,
    this.isSuspended = false,
    this.createdAt,
    this.updatedAt,
  });

  // Equivalent to Laravel's $fillable - fields that can be mass assigned
  static const List<String> fillable = [
    'name',
    'email',
    'password',
    'username',
    'google_id',
    'profile_image',
    'is_google_registered',
    'is_suspended',
  ];

  // Equivalent to Laravel's $hidden - fields that should be hidden in serialization
  static const List<String> hidden = ['password', 'remember_token'];

  // Factory constructor from Map (equivalent to Laravel's model creation)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      emailVerifiedAt: map['email_verified_at'] != null
          ? DateTime.parse(map['email_verified_at'])
          : null,
      password: map['password'] ?? '',
      rememberToken: map['remember_token'],
      username: map['username'] ?? '',
      profileImage: map['profile_image'],
      googleId: map['google_id'],
      isGoogleRegistered: map['is_google_registered'] == 1,
      isSuspended: map['is_suspended'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'password': password,
      'remember_token': rememberToken,
      'username': username,
      'profile_image': profileImage,
      'google_id': googleId,
      'is_google_registered': isGoogleRegistered ? 1 : 0,
      'is_suspended': isSuspended ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Convert to Map for JSON serialization (equivalent to Laravel's toArray/toJson)
  Map<String, dynamic> toJson({bool includeHidden = false}) {
    final Map<String, dynamic> json = {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'username': username,
      'profile_image': profileImage,
      'google_id': googleId,
      'is_google_registered': isGoogleRegistered,
      'is_suspended': isSuspended,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'pro_pic': proPic, // Equivalent to Laravel's appended attribute
    };

    // Include hidden fields only if explicitly requested
    if (includeHidden) {
      json['password'] = password;
      json['remember_token'] = rememberToken;
    }

    return json;
  }

  // Equivalent to Laravel's getProPicAttribute() accessor
  String get proPic {
    return imageRecover(profileImage);
  }

  // Helper method to check if user has profile image
  bool get hasProfileImage {
    return profileImage != null && profileImage!.isNotEmpty;
  }

  // Helper method to check if user is verified
  bool get isEmailVerified {
    return emailVerifiedAt != null;
  }

  // Helper method to get display name
  String get displayName {
    return name.isNotEmpty ? name : username;
  }

  // Copy with method for creating modified instances
  User copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? emailVerifiedAt,
    String? password,
    String? rememberToken,
    String? username,
    String? profileImage,
    String? googleId,
    bool? isGoogleRegistered,
    bool? isSuspended,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      password: password ?? this.password,
      rememberToken: rememberToken ?? this.rememberToken,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      googleId: googleId ?? this.googleId,
      isGoogleRegistered: isGoogleRegistered ?? this.isGoogleRegistered,
      isSuspended: isSuspended ?? this.isSuspended,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode;
  }
}

// Helper function equivalent to Laravel's imageRecover helper
String imageRecover(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return 'assets/images/default_avatar.png'; // Default avatar path
  }

  // If it's already a complete URL, return as is
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath;
  }

  // If it's a local asset, return the asset path
  if (imagePath.startsWith('assets/')) {
    return imagePath;
  }

  // Otherwise, construct the full URL (adjust base URL as needed)
  const String baseUrl = 'https://your-api-domain.com/storage/';
  return baseUrl + imagePath;
}
