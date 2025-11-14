import 'package:http/http.dart' as http;
import 'package:smartassistant_vendedor/constants.dart';

class ApiService {
  final String _baseUrl = API_BASE_URL;

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint, String token) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    print('🔗 GET: $url');
    return await http.get(url, headers: _getHeaders(token));
  }

  Future<http.Response> post(String endpoint, String token,
      {String? body}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    print('🔗 POST: $url');
    return await http.post(url, headers: _getHeaders(token), body: body);
  }

  Future<http.Response> patch(String endpoint, String token,
      {String? body}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    print('🔗 PATCH: $url');
    return await http.patch(url, headers: _getHeaders(token), body: body);
  }

  Future<http.Response> postNoAuth(String endpoint, String body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    print('🔗 POST (No Auth): $url');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
  }

  Future<http.Response> delete(String endpoint, String token) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    print('🔗 DELETE: $url');
    return await http.delete(url, headers: _getHeaders(token));
  }
}
