/// ข้อมูลผู้ใช้ที่เก็บแบบ local (SharedPreferences) — ไม่มี backend จริง
class AppUser {
  final String email;
  final String passwordHash;
  final String name;
  final String? profileImagePath;

  const AppUser({
    required this.email,
    required this.passwordHash,
    required this.name,
    this.profileImagePath,
  });

  AppUser copyWith({
    String? name,
    String? passwordHash,
    String? profileImagePath,
  }) {
    return AppUser(
      email: email,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'passwordHash': passwordHash,
        'name': name,
        'profileImagePath': profileImagePath,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
        name: json['name'] as String,
        profileImagePath: json['profileImagePath'] as String?,
      );
}