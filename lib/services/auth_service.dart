import 'package:y/models/chat.dart';
import 'package:y/network/responses/generic_response.dart';
import 'package:y/utility/constants.dart';

import '../models/user.dart';
import '../network/endpoints.dart';
import '../network/request.dart';
import '../network/responses/login_response.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AuthService {
  static final AuthService _authService = AuthService._internal();

  factory AuthService() {
    return _authService;
  }

  AuthService._internal();

  Future<LoginResponse> login(String phone, String password) async {
    Map<String, String> body = {"phone": phone, "password": password};
    dynamic response =
        await Request.post(endpoint: Endpoints.login, body: body);
    if (response is RequestException) {
      return LoginResponse(
        error: response.errorMessage,
      );
    } else {
      return LoginResponse(
        jwtToken: response['access_token'],
        user: User.fromJson(
          response['user'],
        ),
        chats: response['chats'].map<Chat>(
          (dynamic json) => Chat.fromJson(json),
        ).toList(),
        contacts: response['contacts'].map<User>(
          (dynamic json) => User.fromJson(json),
        ).toList(),
      );
    }
  }

  Future<GenericResponse> register({
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    Map<String, String> body = {
      "phone": phoneNumber,
      "password": password,
      "password_confirmation": confirmPassword,
      "name": name
    };
    dynamic response =
        await Request.post(endpoint: Endpoints.register, body: body);
    if (response is RequestException) {
      return GenericResponse(success: false, error: response.toString());
    }
    return GenericResponse(success: true);
  }
}
