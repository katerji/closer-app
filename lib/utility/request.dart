import 'dart:convert';
import 'package:http/http.dart' as http;

class Request {
  static const String _baseApiUrl = 'http://katerji.online/';
  static const String _socketServerUrl = '$_baseApiUrl:81/socket';
  static const String _apiUrl = '${_baseApiUrl}api/';
  static String? _jwtToken;

  static void setJwtToken(String jwtToken) => _jwtToken = jwtToken;

  static void removeJwtToken() => _jwtToken = null;

  static Future getFromApi(String endpoint) async {
    String url = _apiUrl + endpoint;
    final response = await http.get(Uri.parse(url), headers: _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode != 500) {
      String message =
          jsonDecode(response.body)['message'] ?? "Something went wrong";
      return RequestException(code: response.statusCode, message: message);
    }
    throw Exception('Something went wrong');
  }

  static Future postToApi(String endpoint, Map<String, dynamic> body) async {
    String url = _apiUrl + endpoint;
    String encodedBody = jsonEncode(body);
    print(encodedBody);
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
    } else if (response.statusCode != 500) {
      String message =
          body['message'] ?? "Something went wrong";
      return RequestException(code: response.statusCode, message: message);
    }
    throw Exception('Something went wrong');
  }

  static Map<String, String> _getHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json'
    };
    if (_jwtToken == null) {
      headers['authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }
}

class RequestException {
  final int code;
  final String message;

  const RequestException({
    required this.code,
    required this.message,
  });
}
