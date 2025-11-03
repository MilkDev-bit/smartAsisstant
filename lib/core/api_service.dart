import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../features/auth/auth_service.dart';

class ApiService extends ChangeNotifier {
  final Dio dio = Dio();

  AuthService? _authService;

  ApiService(this._authService) {
    dio.options.baseUrl =
        'https://faultier-dannielle-condensable.ngrok-free.dev';

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint(
              '[ApiService Interceptor] Buscando token desde AuthService...');

          final token = _authService?.token;

          if (token != null && token.isNotEmpty) {
            debugPrint(
                '[ApiService Interceptor] Token encontrado. Añadiendo header...');
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint(
                '[ApiService Interceptor] Header Authorization: ${options.headers['Authorization']}');
          } else {
            debugPrint(
                '[ApiService Interceptor] No se encontró token en AuthService.');
          }
          debugPrint(
              '[ApiService Interceptor] Continuando petición a: ${options.path}');
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          debugPrint(
              '[ApiService Interceptor] Error en petición a ${e.requestOptions.path}: ${e.response?.statusCode} - ${e.message}');

          if (e.response?.statusCode == 401) {
            debugPrint(
                '[ApiService Interceptor] Token inválido o expirado. Deslogueando...');
            _authService?.logout();
          }

          return handler.next(e);
        },
      ),
    );
  }

  void updateAuth(AuthService auth) {
    _authService = auth;
    debugPrint(
        "ApiService fue actualizado con el nuevo estado de AuthService.");
  }
}
