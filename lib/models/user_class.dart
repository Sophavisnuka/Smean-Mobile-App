class User {
  final String userId;
  final String userName;
  final String password;
  final DateTime createdAt;

  const User({
    required this.userId,
    required this.userName,
    required this.password,
    required this.createdAt
  });
}