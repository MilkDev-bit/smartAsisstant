import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:smartassistant_vendedor/models/user.dart';
import 'package:smartassistant_vendedor/services/notification_service.dart'
    as notification_service;
import 'package:smartassistant_vendedor/services/api_service.dart';
import 'package:smartassistant_vendedor/services/two_factor_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
  twoFactorRequired
}

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _api = ApiService();
  final TwoFactorService _twoFactorService = TwoFactorService();

  StreamSubscription? _uriLinkSubscription;

  String? _token;
  ValidatedUser? _user;
  AuthStatus _authStatus = AuthStatus.uninitialized;
  String? _userIdFor2FA;

  String? get token => _token;
  ValidatedUser? get user => _user;
  AuthStatus get authStatus => _authStatus;
  String? get userIdFor2FA => _userIdFor2FA;
  bool get isAuthenticated => _authStatus == AuthStatus.authenticated;

  AuthProvider() {
    _tryLoadToken();
    _initUniLinks();
  }

  void _initUniLinks() {
    _uriLinkSubscription = uriLinkStream.listen((Uri? uri) {
      _handleIncomingLink(uri);
    }, onError: (err) {
      print('Error en uni_links: $err');
    });
  }

  void _handleIncomingLink(Uri? uri) async {
    if (uri == null) return;

    print('URI recibida: $uri');
    print('Scheme: ${uri.scheme}');
    print('Host: ${uri.host}');
    print('Path: ${uri.path}');
    print('Query params: ${uri.queryParameters}');

    if (uri.scheme == 'smartassistant' && uri.host == 'login-success') {
      await _processDeepLink(uri);
      return;
    }

    if (uri.scheme == 'smartassistant' && uri.host == 'login') {
      await _processDeepLink(uri);
      return;
    }

    print('URI no manejada: $uri');
  }

  Future<void> _processDeepLink(Uri uri) async {
    print('Procesando deep link: $uri');

    if (uri.queryParameters.containsKey('token')) {
      final token = uri.queryParameters['token']!;
      print('Token recibido: $token');
      await _saveSession(token);
      return;
    }

    if (uri.queryParameters.containsKey('userId')) {
      final userId = uri.queryParameters['userId']!;
      _userIdFor2FA = userId;
      _authStatus = AuthStatus.twoFactorRequired;
      notifyListeners();
      print('2FA requerido para usuario: $userId');
      return;
    }

    print('Deep link sin parámetros reconocidos');
  }

  Future<void> _tryLoadToken() async {
    try {
      _token = await _storage.read(key: 'jwt_token');
      if (_token != null) {
        await _getProfile();
      } else {
        _authStatus = AuthStatus.unauthenticated;
      }
    } catch (e) {
      print('Error cargando token: $e');
      _authStatus = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _getProfile() async {
    try {
      final response = await _api.get('auth/profile', _token!);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _user = ValidatedUser.fromJson(data);

        if (_user!.rol != 'VENDEDOR') {
          await logout();
          throw Exception(
              'Esta aplicación es solo para vendedores. Tu rol es ${_user!.rol}');
        }

        _authStatus = AuthStatus.authenticated;
        await _initNotifications();

        print('Usuario autenticado: ${_user!.nombre}');
        print('Foto de perfil: ${_user!.fotoPerfil}');
        print('Teléfono: ${_user!.telefono}');
        print('Activo: ${_user!.activo}');
        print('2FA Enabled: ${_user!.twoFactorEnabled}');
      } else {
        throw Exception('Error al cargar perfil: ${response.statusCode}');
      }
    } catch (e) {
      print('Error obteniendo perfil: $e');
      await logout();
      rethrow;
    }
    notifyListeners();
  }

  Future<void> _initNotifications() async {
    try {
      final notificationService = notification_service.NotificationService();
      final playerId = await notificationService.initOneSignal();

      if (playerId != null && _token != null && _user != null) {
        await _api.patch('user/my-player-id', _token!,
            body: json.encode({'playerId': playerId}));
        print('Player ID de Vendedor guardado: $playerId');
      }
    } catch (e) {
      print('Error al inicializar notificaciones: $e');
    }
  }

  Future<void> login(String email, String password) async {
    _authStatus = AuthStatus.authenticating;
    notifyListeners();

    try {
      final response = await _api.postNoAuth(
        'auth/login',
        json.encode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data.containsKey('accessToken')) {
          await _saveSession(data['accessToken']);
        } else if (data.containsKey('userId')) {
          _userIdFor2FA = data['userId'];
          _authStatus = AuthStatus.twoFactorRequired;
          print('2FA requerido para usuario: $_userIdFor2FA');
        } else {
          throw Exception('Respuesta del servidor inesperada');
        }
      } else {
        throw Exception(data['message'] ?? 'Error en el inicio de sesión');
      }
    } catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    _authStatus = AuthStatus.authenticating;
    notifyListeners();

    try {
      const googleAuthUrl =
          "https://crm-back-final-production.up.railway.app/auth/google";

      if (await canLaunchUrl(Uri.parse(googleAuthUrl))) {
        await launchUrl(
          Uri.parse(googleAuthUrl),
          mode: LaunchMode.externalApplication,
        );

        print('Redirigiendo a Google OAuth...');
      } else {
        throw Exception("No se pudo abrir Google OAuth");
      }
    } catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  }) async {
    _authStatus = AuthStatus.authenticating;
    notifyListeners();

    try {
      final response = await _api.postNoAuth(
        'auth/register',
        json.encode({
          'nombre': nombre,
          'email': email,
          'password': password,
          'telefono': telefono,
        }),
      );

      if (response.statusCode == 201) {
        await login(email, password);
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al registrar usuario');
      }
    } catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> authenticate2FA(String userId, String code) async {
    _authStatus = AuthStatus.authenticating;
    notifyListeners();

    try {
      final response = await _api.postNoAuth(
        'auth/2fa/authenticate',
        json.encode({'userId': userId, 'code': code}),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200 && data.containsKey('accessToken')) {
        await _saveSession(data['accessToken']);
      } else {
        throw Exception(data['message'] ?? 'Código 2FA inválido');
      }
    } catch (e) {
      _authStatus = AuthStatus.twoFactorRequired;
      notifyListeners();
      rethrow;
    }
  }

  Future<String> toggle2FA(bool enable) async {
    if (_token == null) throw Exception('No autenticado');

    try {
      if (enable) {
        final message = await _twoFactorService.generate2FA(_token!);
        return message;
      } else {
        await _twoFactorService.disable2FA(_token!);
        if (_user != null) {
          _user = ValidatedUser(
            id: _user!.id,
            email: _user!.email,
            nombre: _user!.nombre,
            rol: _user!.rol,
            telefono: _user?.telefono,
            fotoPerfil: _user?.fotoPerfil,
            activo: _user?.activo ?? true,
            twoFactorEnabled: false,
          );
        }
        notifyListeners();
        return '2FA desactivado correctamente';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verify2FASetup(String code) async {
    if (_token == null) throw Exception('No autenticado');

    try {
      await _twoFactorService.verify2FASetup(_token!, code);
      if (_user != null) {
        _user = ValidatedUser(
          id: _user!.id,
          email: _user!.email,
          nombre: _user!.nombre,
          rol: _user!.rol,
          telefono: _user?.telefono,
          fotoPerfil: _user?.fotoPerfil,
          activo: _user?.activo ?? true,
          twoFactorEnabled: true,
        );
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveSession(String token) async {
    _token = token;
    await _storage.write(key: 'jwt_token', value: token);
    await _getProfile();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _userIdFor2FA = null;
    _authStatus = AuthStatus.unauthenticated;
    await _storage.delete(key: 'jwt_token');
    print('Sesión cerrada exitosamente');
    notifyListeners();
  }

  Future<void> clearAuthData() async {
    await _storage.deleteAll();
    _token = null;
    _user = null;
    _authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _uriLinkSubscription?.cancel();
    super.dispose();
  }
}
