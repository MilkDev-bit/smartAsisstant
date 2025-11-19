import 'dart:convert';
import 'package:smartassistant_vendedor/services/api_service.dart';

class TwoFactorService {
  final ApiService _api = ApiService();

  Future<String> generate2FA(String token) async {
    try {
      final response = await _api.post('auth/2fa/generate', token, body: '{}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['message'] ?? 'Código enviado a tu correo electrónico';
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al generar código 2FA');
      }
    } catch (e) {
      throw Exception('Error al generar código 2FA: $e');
    }
  }

  Future<void> verify2FASetup(String token, String code) async {
    try {
      final response = await _api.post(
        'auth/2fa/turn-on',
        token,
        body: json.encode({'code': code}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Código inválido');
      }
    } catch (e) {
      throw Exception('Error al verificar código 2FA: $e');
    }
  }

  Future<void> disable2FA(String token) async {
    try {
      final response = await _api.post('auth/2fa/turn-off', token, body: '{}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al desactivar 2FA');
      }
    } catch (e) {
      throw Exception('Error al desactivar 2FA: $e');
    }
  }
}
