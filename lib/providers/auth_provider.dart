import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:y/network/responses/generic_response.dart';
import 'package:y/services/auth_service.dart';
import 'package:y/utility/constants.dart';
import 'package:y/network/endpoints.dart';
import 'package:y/network/request.dart';

import '../models/user.dart';
import '../network/responses/login_response.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  static bool _isAuthing = true;
  static bool _didAutoLogin = false;

  bool isAuthing() => _isAuthing;

  bool didAutoLogin() => _didAutoLogin;

  String? _loginError;
  String? _registrationError;

  Future<void> login(String phoneNumber, String password) async {
    AuthService authService = AuthService();
    LoginResponse response = await authService.login(phoneNumber, password);
    if (response.error != null) {
      _loginError = response.error;
      notifyListeners();
      return;
    }
    Map<String, dynamic> userLoginInfo = {
      "phone_number": phoneNumber,
      "password": password
    };
    FlutterSecureStorage storage = const FlutterSecureStorage();
    storage.write(
      key: Constants.secureStorageUserLoginInfoKey,
      value: jsonEncode(userLoginInfo),
    );
    Request.setJwtToken(response.jwtToken ?? "");
    print(response.jwtToken ?? "");
    _currentUser = response.user;
    notifyListeners();
  }

  Future<bool> register(String name, String phoneNumber, String password,
      String confirmPassword) async {
    AuthService authService = AuthService();
    GenericResponse registerResponse = await authService.register(
        phoneNumber: phoneNumber,
        name: name,
        password: password,
        confirmPassword: confirmPassword);
    if (registerResponse.error != null) {
      _registrationError = registerResponse.error;
      notifyListeners();
      return false;
    }
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
    if (userLoginInfoMap["phone_number"] != null && userLoginInfoMap["password"] != null) {
      await login(userLoginInfoMap['phone_number'], userLoginInfoMap['password']);
    }
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

  String? getLoginError() => _loginError;

  String? getRegistrationError() => _registrationError;
}
