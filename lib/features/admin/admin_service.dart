import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/api_service.dart';
import '../clients/client_user_model.dart';
import '../auth/auth_service.dart';

class AdminService extends ChangeNotifier {
  final ApiService _apiService;

  AdminService(this._apiService);

  List<ValidatedUser> _vendedores = [];
  bool _isLoadingVendedores = false;
  String? _error;

  List<ValidatedUser> get vendedores => _vendedores;
  bool get isLoadingVendedores => _isLoadingVendedores;
  String? get error => _error;

  List<ValidatedUser> _allUsers = [];
  bool _isLoadingUsers = false;

  List<ValidatedUser> get allUsers => _allUsers;
  bool get isLoadingUsers => _isLoadingUsers;

  Future<void> fetchVendedores() async {
    _isLoadingVendedores = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/user/vendedores');
      final List<dynamic> data = response.data;
      _vendedores = data.map((json) => ValidatedUser.fromJson(json)).toList();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al cargar vendedores.';
      _vendedores = [];
    } catch (e) {
      _error = 'Ocurrió un error inesperado.';
      _vendedores = [];
    } finally {
      _isLoadingVendedores = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllUsers() async {
    _isLoadingUsers = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/user/all');
      final List<dynamic> data = response.data;
      _allUsers = data.map((json) => ValidatedUser.fromJson(json)).toList();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al cargar usuarios.';
      _allUsers = [];
    } catch (e) {
      _error = 'Ocurrió un error inesperado.';
      _allUsers = [];
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserRole(
      String userId, String newRole, AuthService authService) async {
    _isLoadingUsers = true;
    _error = null;

    try {
      await _apiService.dio.patch(
        '/user/$userId/role',
        data: {'rol': newRole},
      );

      await fetchAllUsers();

      if (authService.currentUser?.id == userId) {
        await authService.getProfile(_apiService);
      }

      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al actualizar rol.';
      return false;
    } catch (e) {
      _error = 'Error inesperado al actualizar rol.';
      return false;
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }
}
