import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/api_service.dart';
import '../auth/auth_service.dart';
import 'client_user_model.dart';
import '../orders/order_model.dart';

class ClientService extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;

  ClientService(this._authService, this._apiService);

  bool _isLoading = false;
  String? _error;

  List<ValidatedUser> _clients = [];
  List<Order> _assignedOrders = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ValidatedUser> get clients => _clients;
  List<Order> get assignedOrders => _assignedOrders;

  Future<void> fetchData() async {
    if (_authService.currentUser == null) {
      _error = "No se ha iniciado sesión.";
      notifyListeners();
      return;
    }

    final role = _authService.currentUser!.rol;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (role == 'ADMIN') {
        await fetchAllClients();
      } else if (role == 'VENDEDOR') {
        await fetchAssignedOrders();
      }
    } on DioException catch (e) {
      _error =
          e.response?.data['message'] ?? 'Error de conexión con el servidor.';
    } catch (e) {
      _error = 'Error inesperado al cargar los datos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllClients() async {
    try {
      final response = await _apiService.dio.get('/user/clients');
      final List<dynamic> data = response.data;
      _clients = data.map((json) => ValidatedUser.fromJson(json)).toList();
      _assignedOrders = [];
    } on DioException catch (e) {
      _error =
          e.response?.data['message'] ?? 'Error de API al cargar clientes.';
      _clients = [];
    } catch (e) {
      _error = 'Error inesperado al procesar los clientes.';
      _clients = [];
    }
  }

  Future<void> fetchAssignedOrders() async {
    try {
      final response = await _apiService.dio.get('/orders/mis-entregas');
      final List<dynamic> data = response.data;
      _assignedOrders = data.map((json) => Order.fromJson(json)).toList();
      _clients = [];
    } on DioException catch (e) {
      _error =
          e.response?.data['message'] ?? 'Error de API al cargar entregas.';
      _assignedOrders = [];
    } catch (e) {
      _error = 'Error inesperado al procesar las entregas.';
      _assignedOrders = [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.dio.patch(
        '/orders/$orderId/status',
        data: {'status': newStatus},
      );

      await fetchAssignedOrders();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al actualizar el estado.';
      return false;
    } catch (e) {
      _error = 'Error inesperado al actualizar.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
