class User {
  final String username;
  final String password;
  final String fullName;
  final String role;

  User({
    required this.username,
    required this.password,
    required this.fullName,
    required this.role,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'fullName': fullName,
      'role': role,
    };
  }

  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'user',
    );
  }
}