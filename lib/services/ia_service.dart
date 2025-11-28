import 'package:dio/dio.dart';
import '../models/ia_response.dart';

class IaService {
  final Dio _dio;
  final String _baseUrl;

  IaService(this._dio, this._baseUrl);

  Future<IaResponse> sendQuery(String prompt) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/iamodel/query',
        data: {'prompt': prompt},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      return IaResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('La IA está tardando demasiado. Intenta de nuevo.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('No tienes permisos para usar el asistente IA.');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
