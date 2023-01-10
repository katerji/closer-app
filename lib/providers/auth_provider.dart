import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:y/network/api_request_loader.dart';
import 'package:y/network/responses/generic_response.dart';
import 'package:y/providers/chat_provider.dart';
import 'package:y/services/auth_service.dart';
import 'package:y/utility/constants.dart';
import 'package:y/network/request.dart';

import '../models/chat.dart';
import '../models/user.dart';
import '../network/responses/login_response.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  int appKey = DateTime.now().millisecondsSinceEpoch;

  bool get didAutoLogin => _didAutoLogin;

  String? _loginError;
  String? _registrationError;

  ApiRequestLoader loginRequestLoader = ApiRequestLoader();
  ApiRequestLoader registerRequestLoader = ApiRequestLoader();

  Future<void> login(String phoneNumber, String password, ChatProvider chatProvider) async {
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
      "password": password,
      "access_token": response.jwtToken,
      "user": response.user?.toMap()
    };
    FlutterSecureStorage storage = const FlutterSecureStorage();
    storage.write(
      key: Constants.secureStorageUserLoginInfoKey,
      value: jsonEncode(userLoginInfo),
    );
    Request.setJwtToken(response.jwtToken!);
    await chatProvider.setChatsFromLogin(response.chats!);
    print(response.jwtToken);
    _currentUser = response.user;
    await _setContactsInStorage(response.contacts!);
    notifyListeners();
  }

  Future<void> _setContactsInStorage(List<User> contacts) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    Map<String, dynamic> contactsList = {};
    if (contacts.isNotEmpty) {
      for (var contact in contacts) {
        contactsList[contact.userId.toString()] = contact.toMap();
      }
    }
    await storage.write(
      key: Constants.secureStorageContactsKey,
      value: jsonEncode(contactsList),
    );
  }

  Future<bool> register(String name, String phoneNumber, String password,
      String confirmPassword) async {
    registerRequestLoader.setLoading(true);
    AuthService authService = AuthService();
    GenericResponse registerResponse = await authService.register(
      phoneNumber: phoneNumber,
      name: name,
      password: password,
      confirmPassword: confirmPassword,
    );
    registerRequestLoader.setLoading(false);
    if (registerResponse.error != null) {
      _registrationError = registerResponse.error;
      notifyListeners();
      return false;
    }
    return true;
  }

  bool _didAutoLogin = false;

  Future<void> autoLoginUser() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? userLoginInfoStr =
        await storage.read(key: Constants.secureStorageUserLoginInfoKey);
    if (userLoginInfoStr == null) {
      _didAutoLogin = true;
      notifyListeners();
      return;
    }
    Map<dynamic, dynamic> userLoginInfoMap = jsonDecode(userLoginInfoStr);
    Request.setJwtToken(userLoginInfoMap['access_token']);
    print(userLoginInfoMap['access_token']);
    _currentUser = User.fromJson(userLoginInfoMap['user']);
    _didAutoLogin = true;
    notifyListeners();
  }

  Future<void> logout() async {
    Request.removeJwtToken();
    _currentUser = null;
    await _clearSecureStorage();
    _deleteCacheDir();
    _deleteAppDir();
    appKey = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  Future<void> _clearSecureStorage() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(
      key: Constants.secureStorageUserLoginInfoKey,
      value: null,
    );
    await storage.write(
      key: Constants.secureStorageContactsKey,
      value: null,
    );
  }

  bool isLoggedIn() => _currentUser != null;

  int get loggedInUserId => _currentUser!.userId;

  User? get loggedInUser => _currentUser;

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

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }
}
