import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/api_service.dart';
import '../auth/auth_service.dart';

class SettingsService extends ChangeNotifier {
  final ApiService _api;
  final AuthService _auth;

  bool _isLoading = false;
  String? _qrDataUrl;
  String? _error;

  bool get isLoading => _isLoading;
  String? get qrDataUrl => _qrDataUrl;
  String? get error => _error;

  SettingsService(this._auth, this._api);

  Future<void> generateTwoFactorQrCode() async {
    _isLoading = true;
    _error = null;
    _qrDataUrl = null;
    notifyListeners();

    try {
      final response = await _api.dio.post('/auth/2fa/generate');

      debugPrint(
          "[SettingsService] Respuesta CRUDA del backend: ${response.data}");

      _qrDataUrl = response.data['qrDataUrl'];

      if (_qrDataUrl == null || _qrDataUrl!.isEmpty) {
        throw 'El servidor no devolvió datos para el código QR.';
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al generar el código QR.';
    } catch (e) {
      _error = 'Ocurrió un error inesperado al generar el código.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> turnOnTwoFactor(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.dio.post(
        '/auth/2fa/turn-on',
        data: {'code': code},
      );
      await _auth.getProfile(_api);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Código 2FA inválido.';
      return false;
    } catch (e) {
      _error = 'Ocurrió un error inesperado al activar 2FA.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
