import 'dart:convert';

import 'package:y/utility/constants.dart';

import '../models/chat.dart';
import '../models/user.dart';
import '../utility/endpoints.dart';
import '../utility/request.dart';

class AuthService {
  static final AuthService _authService = AuthService._internal();

  factory AuthService() {
    return _authService;
  }

  AuthService._internal();

  Future<LoginResponse> login(String phone, String password) async {
    Map<String, String> body = {"phone": phone, "password": password};
    dynamic response = await Request.postToApi(Endpoints.login, body);
    if (response is RequestException) {
      return LoginResponse(error: response.message);
    } else {
      return LoginResponse(
          jwtToken: response['access_token'],
          user: User.fromJson(response['user']));
    }
  }

  Future<RegisterResponse> register(
      {required String phoneNumber,
      required String password,
      required String confirmPassword,
      required String name}) async {
    Map<String, String> body = {
      "phone": phoneNumber,
      "password": password,
      "password_confirmation": confirmPassword,
      "name": name
    };
    dynamic response = await Request.postToApi(Endpoints.register, body);
    if (response is RequestException) {
      return RegisterResponse(error: response.toString());
    }
    return const RegisterResponse();
  }
}

class LoginResponse {
  final String? jwtToken;
  final User? user;
  final String? error;

  const LoginResponse({this.jwtToken, this.user, this.error});
}

class RegisterResponse {
  final String? error;

  const RegisterResponse({this.error});
}
