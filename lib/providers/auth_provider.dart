import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:y/utility/constants.dart';
import 'package:y/utility/endpoints.dart';
import 'package:y/utility/request.dart';

import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  static bool _isAuthing = true;
  static bool _didAutoLogin = false;
  bool isAuthing() => _isAuthing;
  bool didAutoLogin() => _didAutoLogin;
  Future<void> login(String phoneNumber, String password) async {
    Map<String, String> body = {"phone": phoneNumber, "password": password};
    dynamic response = await Request.postToApi(Endpoints.login, body);
    if (response is RequestException) {
      return;
    }
    Map<String, String> userLoginInfo = {
      "phone_number": phoneNumber,
      "password": password
    };
    FlutterSecureStorage storage = const FlutterSecureStorage();
    storage.write(
        key: Constants.secureStorageUserLoginInfoKey,
        value: jsonEncode(userLoginInfo));
    Request.setJwtToken(response['access_token']);
    _currentUser = User.fromJson(response['user']);
    notifyListeners();
  }

  Future<bool> register(String name, String phoneNumber, String password,
      String confirmPassword) async {
    Map<String, String> body = {
      "phone": phoneNumber,
      "password": password,
      "password_confirmation": password,
      "name": name
    };
    dynamic response = await Request.postToApi(Endpoints.register, body);
    if (response is RequestException) {}
    return true;
  }

  Future<void> autoLoginUser() async {
    _isAuthing = true;
    _didAutoLogin = true;
    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? userLoginInfoStr =
        await storage.read(key: Constants.secureStorageUserLoginInfoKey);
    if (userLoginInfoStr == null) {
      _isAuthing = false;
      notifyListeners();
      return;
    }
    Map<dynamic, dynamic> userLoginInfoMap = jsonDecode(userLoginInfoStr);
    await login(userLoginInfoMap['phone_number'], userLoginInfoMap['password']);
    _isAuthing = false;
    notifyListeners();
  }

  Future<void> logout() async {
    Request.removeJwtToken();
    _currentUser = null;
    FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(
        key: Constants.secureStorageUserLoginInfoKey, value: null);
    notifyListeners();
  }

  bool isLoggedIn() => _currentUser != null;
}
