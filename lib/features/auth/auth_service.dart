import '../clients/client_user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api_service.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _accessToken;
  ValidatedUser? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  ValidatedUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get token => _accessToken;

  AuthService() {
    debugPrint(
        "AuthService inicializado, esperando llamada de initializeAuth...");
  }

  Future<void> initializeAuthStatus(ApiService api) async {
    _accessToken = await _secureStorage.read(key: 'accessToken');
    if (_accessToken != null) {
      try {
        await getProfile(api);
        _isLoggedIn = true;
      } catch (e) {
        await logout();
      }
    } else {
      _isLoggedIn = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> register(ApiService api, String nombre,
      String email, String password, String? telefono) async {
    try {
      final response = await api.dio.post(
        '/auth/register',
        data: {
          'nombre': nombre,
          'email': email,
          'password': password,
          if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
        },
      );

      final data = response.data;
      if (data != null) {
        if (data['accessToken'] != null && data['user'] != null) {
          await _saveSession(data['accessToken'], data['user']);
        }
        return data;
      }
      return {};
    } on DioException catch (e) {
      final message = e.response?.data['message'];
      throw message is List ? message.join(', ') : message ?? 'Error de red';
    } catch (e) {
      throw 'Ocurrió un error inesperado durante el registro.';
    }
  }

  Future<void> getProfile(ApiService api) async {
    try {
      final response = await api.dio.get('/auth/profile');
      _currentUser = ValidatedUser.fromJson(response.data['user']);
      notifyListeners();
    } catch (e) {
      await logout();
      throw 'No se pudo verificar tu sesión.';
    }
  }

  Future<Map<String, dynamic>> login(
      ApiService api, String email, String password) async {
    try {
      final response = await api.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data['accessToken'] != null) {
        await _saveSession(data['accessToken'], data['user']);
      }
      return data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Error de red';
    }
  }

  Future<void> authenticate2FA(
      ApiService api, String userId, String code) async {
    try {
      final response = await api.dio.post(
        '/auth/2fa/authenticate',
        data: {
          'userId': userId,
          'code': code,
        },
      );

      final data = response.data;
      if (data['accessToken'] != null && data['user'] != null) {
        await _saveSession(data['accessToken'], data['user']);
      } else {
        throw 'Respuesta inesperada del servidor durante la autenticación 2FA.';
      }
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Código 2FA inválido o expirado.';
    } catch (e) {
      throw 'Ocurrió un error inesperado durante la verificación.';
    }
  }

  Future<void> _saveSession(String token, Map<String, dynamic> userData) async {
    _accessToken = token;
    _currentUser = ValidatedUser.fromJson(userData);
    await _secureStorage.write(key: 'accessToken', value: _accessToken);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    _currentUser = null;
    await _secureStorage.delete(key: 'accessToken');
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle(ApiService api) async {
    final googleAuthUrl = '${api.dio.options.baseUrl}/auth/google';
    final Uri uri = Uri.parse(googleAuthUrl);

    debugPrint('[AuthService.signInWithGoogle] URL construida: $uri');

    bool canLaunch;
    try {
      canLaunch = await canLaunchUrl(uri);
      debugPrint(
          '[AuthService.signInWithGoogle] Resultado de canLaunchUrl: $canLaunch');
    } catch (e) {
      debugPrint(
          '[AuthService.signInWithGoogle] EXCEPCIÓN en canLaunchUrl: $e');
      throw 'Error al verificar si se puede abrir la URL.';
    }

    if (canLaunch) {
      try {
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        debugPrint(
            '[AuthService.signInWithGoogle] Resultado de launchUrl: $launched');
        if (!launched) {
          throw 'launchUrl devolvió false.';
        }
      } catch (e) {
        debugPrint('[AuthService.signInWithGoogle] EXCEPCIÓN en launchUrl: $e');
        throw 'No se pudo iniciar el navegador para la autenticación.';
      }
    } else {
      debugPrint('[AuthService.signInWithGoogle] canLaunchUrl fue false.');
      throw 'El sistema reportó que no puede abrir la URL: $uri';
    }
  }

  Future<void> handleTokenFromDeepLink(ApiService api, String token) async {
    debugPrint(
        '[AuthService.handleDeepLink] Recibido token: [${token.substring(0, 10)}...]');
    _isLoading = true;
    notifyListeners();

    try {
      _accessToken = token;
      await _secureStorage.write(key: 'accessToken', value: _accessToken);
      _isLoggedIn = true;
      debugPrint(
          '[AuthService.handleDeepLink] Token guardado, _isLoggedIn = true.');

      debugPrint('[AuthService.handleDeepLink] Intentando obtener perfil...');
      await getProfile(api);
      debugPrint(
          '[AuthService.handleDeepLink] Perfil obtenido con éxito. Usuario: ${_currentUser?.email}');
    } catch (e) {
      debugPrint(
          '[AuthService.handleDeepLink] ERROR al obtener perfil con token del link: $e');
      await logout();
      debugPrint('[AuthService.handleDeepLink] Logout forzado debido a error.');
    } finally {
      _isLoading = false;
      debugPrint('[AuthService.handleDeepLink] Notificando listeners...');
      notifyListeners();
    }
  }
}
