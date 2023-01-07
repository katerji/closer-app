import 'package:flutter/widgets.dart';
import 'package:y/utility/endpoints.dart';
import 'package:y/utility/request.dart';

import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;

  Future<void> login(String phoneNumber, String password) async {
    Map<String, String> body = {"phone": phoneNumber, "password": password};
    dynamic response = await Request.postToApi(Endpoints.login, body);
    if (response is RequestException) {}
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

  void logout() {
    Request.removeJwtToken();
    _currentUser = null;
    notifyListeners();
  }

  bool isLoggedIn() => _currentUser != null;
}
