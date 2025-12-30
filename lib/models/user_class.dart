class User {
  final String userId;
  final String userName;
  final String passwordHash;
  // final DateTime createdAt;

  const User({
    required this.userId,
    required this.userName,
    required this.passwordHash,
    // required this.createdAt
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      userName: json['userName'],
      passwordHash: json['passwordHash'],
      // createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return  {
      'userId': userId,
      'userName': userName,
      'passwordHash': passwordHash,
      // 'createdAt': createdAt
    };
  }
}