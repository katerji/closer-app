import 'dart:convert';
import 'package:http/http.dart' as http;

class Request {
  static const String _baseApiUrl = 'https://70d4-31-215-92-21.in.ngrok.io/';
  static const String _apiUrl = '${_baseApiUrl}api/';
  static String? jwtToken;
  static void setJwtToken(String newJwtToken) => jwtToken = newJwtToken;

  static void removeJwtToken() => jwtToken = null;

  static Future get({required String endpoint}) async {
    String url = _apiUrl + endpoint;
    final response = await http.get(Uri.parse(url), headers: _getHeaders());
    print(endpoint);
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = "Something went wrong";
      dynamic body = jsonDecode(response.body);
      if (body is Map) {
        message = jsonDecode(response.body)['error'];
      }
      return RequestException(code: response.statusCode, errorMessage: message);
    }
  }

  static Future post({required String endpoint, Map<String, dynamic>? body}) async {
    String url = _apiUrl + endpoint;
    String? encodedBody;
    if (body != null) {
      encodedBody = jsonEncode(body);
    }
    final response = await http.post(
      Uri.parse(url),
      body: encodedBody,
      headers: _getHeaders(),
    );
    print(response.body);
    body = jsonDecode(response.body);
    print(body);
    if (response.statusCode == 200) {
      return body;
    } else {
      String message = body?['error'] ?? "Something went wrong";
      return RequestException(code: response.statusCode, errorMessage: message);
    }
  }
  static Future delete({required String endpoint, Map<String, dynamic>? body}) async {
    String url = _apiUrl + endpoint;
    String? encodedBody;
    if (body != null) {
      encodedBody = jsonEncode(body);
    }
    final response = await http.delete(
      Uri.parse(url),
      body: encodedBody,
      headers: _getHeaders(),
    );
    print(response.body);
    body = jsonDecode(response.body);
    print(body);
    if (response.statusCode == 200) {
      return body;
    } else {
      String message = body?['error'] ?? "Something went wrong";
      return RequestException(code: response.statusCode, errorMessage: message);
    }
  }

  static Map<String, String> _getHeaders() {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (jwtToken != null) {
      headers['authorization'] = 'bearer $jwtToken';
    }
    return headers;
  }
}

class RequestException {
  final int code;
  final String errorMessage;

  const RequestException({
    required this.code,
    required this.errorMessage,
  });
}
