class User {
  final int? id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String password;
  final String? rememberToken;
  final String username;
  final String? profileImage;
  final String? googleId;
  final bool isGoogleRegistered;
  final bool isSuspended;
  final String? createdAt;
  final String? updatedAt;

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'password': password,
      'remember_token': rememberToken,
      'username': username,
      'profile_image': profileImage,
      'google_id': googleId,
      'is_google_registered': isGoogleRegistered ? 1 : 0,
      'is_suspended': isSuspended ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
