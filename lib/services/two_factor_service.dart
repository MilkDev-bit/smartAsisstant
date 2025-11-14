import 'dart:convert';
import 'package:smartassistant_vendedor/services/api_service.dart';

class TwoFactorService {
  final ApiService _api = ApiService();

  Future<bool> enable2FA(String token) async {
    try {
      final response = await _api.post(
        'auth/2fa/generate',
        token,
        body: null,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al activar 2FA');
      }
    } catch (e) {
      throw Exception('No se pudo activar 2FA: $e');
    }
  }

  Future<bool> disable2FA(String token) async {
    try {
      final response = await _api.post(
        'auth/2fa/turn-off',
        token,
        body: null,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al desactivar 2FA');
      }
    } catch (e) {
      throw Exception('No se pudo desactivar 2FA: $e');
    }
  }

  Future<bool> verify2FASetup(String token, String code) async {
    try {
      final response = await _api.post(
        'auth/2fa/turn-on',
        token,
        body: json.encode({'code': code}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Código 2FA inválido');
      }
    } catch (e) {
      throw Exception('Error verificando 2FA: $e');
    }
  }
}
