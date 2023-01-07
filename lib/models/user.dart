class User {
  final int userId;
  final String phoneNumber;
  final String name;

  const User({
    required this.userId,
    required this.phoneNumber,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'],
      phoneNumber: json['phone'],
      name: json['name'],
    );
  }

  factory User.empty() {
    return const User(
      userId: 0,
      phoneNumber: "",
      name: ""
    );
  }
}