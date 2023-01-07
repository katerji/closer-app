import '../../models/user.dart';

class LoginResponse {
  final String jwtToken;
  final User user;
  final String? error;

  const LoginResponse({
    required this.jwtToken,
    required this.user,
    this.error,
  });
}
