class AppUser {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final String? imagePath;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "passwordHash": passwordHash,
    "createdAt": createdAt.toIso8601String(),
    "imagePath": imagePath
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    passwordHash: json["passwordHash"],
    createdAt: DateTime.parse(json["createdAt"]),
    imagePath: json["imagePath"]
  );

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
    String? imagePath,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
