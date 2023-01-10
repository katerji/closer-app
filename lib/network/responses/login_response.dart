import '../../models/chat.dart';
import '../../models/user.dart';

class LoginResponse {
  final String? jwtToken;
  final User? user;
  final List<Chat>? chats;
  final List<User>? contacts;
  final String? error;

  const LoginResponse({
    this.jwtToken,
    this.user,
    this.chats,
    this.contacts,
    this.error,
  });
}
