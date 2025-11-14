import 'dart:convert';
import 'package:smartassistant_vendedor/services/api_service.dart';

class PasswordRecoveryService {
  final ApiService _api = ApiService();

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _api.postNoAuth(
        'auth/forgot-password',
        json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al solicitar recuperación');
      }
    } catch (e) {
      throw Exception('No se pudo solicitar recuperación: $e');
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _api.postNoAuth(
        'auth/reset-password',
        json.encode({
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al restablecer contraseña');
      }
    } catch (e) {
      throw Exception('No se pudo restablecer contraseña: $e');
    }
  }
}
