import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:y/network/api_request_loader.dart';
import 'package:y/network/responses/generic_response.dart';
import 'package:y/services/auth_service.dart';
import 'package:y/utility/constants.dart';
import 'package:y/network/request.dart';

import '../models/user.dart';
import '../network/responses/login_response.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  static bool _isAuthing = true;
  static bool _didAutoLogin = false;
  int appKey = DateTime.now().millisecondsSinceEpoch;
  bool isAuthing() => _isAuthing;
  bool didAutoLogin() => _didAutoLogin;

  String? _loginError;
  String? _registrationError;

  ApiRequestLoader loginRequestLoader = ApiRequestLoader();
  ApiRequestLoader registerRequestLoader = ApiRequestLoader();


  Future<void> login(String phoneNumber, String password) async {
    loginRequestLoader.setLoading(true);
    AuthService authService = AuthService();
    LoginResponse response = await authService.login(phoneNumber, password);
    loginRequestLoader.setLoading(false);
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
    registerRequestLoader.setLoading(true);
    AuthService authService = AuthService();
    GenericResponse registerResponse = await authService.register(
        phoneNumber: phoneNumber,
        name: name,
        password: password,
        confirmPassword: confirmPassword);
    registerRequestLoader.setLoading(false);
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
    _deleteCacheDir();
    _deleteAppDir();
    appKey = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }


  bool isLoggedIn() => _currentUser != null;
  int get loggedInUserId => _currentUser!.userId;
  User get loggedInUser => _currentUser!;
  String? getLoginError() => _loginError;

  String? getRegistrationError() => _registrationError;

  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if(appDir.existsSync()){
      appDir.deleteSync(recursive: true);
    }
  }
}
