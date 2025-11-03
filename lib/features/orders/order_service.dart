import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/api_service.dart';
import '../cart/cart_service.dart';
import '../auth/auth_service.dart';
import 'order_model.dart';
import 'order_detail_model.dart';

class OrderService extends ChangeNotifier {
  final ApiService _api;
  final AuthService? _auth;

  List<Order> _orderHistory = [];
  bool _isLoadingHistory = false;

  OrderDetail? _currentOrderDetail;
  bool _isLoadingDetail = false;

  List<Order> _assignableOrders = [];
  bool _isLoadingAssignable = false;

  bool _isActionLoading = false;
  String? _error;

  List<Order> get orderHistory => _orderHistory;
  OrderDetail? get currentOrderDetail => _currentOrderDetail;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;
  List<Order> get assignableOrders => _assignableOrders;
  bool get isLoadingAssignable => _isLoadingAssignable;

  // El constructor estaba al revés según tu main.dart, lo corregí para que coincida.
  OrderService(AuthService? auth, ApiService api)
      : _auth = auth,
        _api = api;

  Future<String?> createOrderFromCart(CartService cartService) async {
    if (cartService.items.isEmpty) return null;

    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderItems = cartService.items
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
              })
          .toList();

      final response = await _api.dio.post(
        '/orders',
        data: {'items': orderItems},
      );

      final String newOrderId = response.data['_id'];
      await fetchOrderHistory();
      return newOrderId;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al crear el pedido.';
      return null;
    } catch (e) {
      _error = 'Ocurrió un error inesperado al crear el pedido.';
      return null;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderHistory() async {
    _isLoadingHistory = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint(
          "[OrderService] Fetching order history from '/orders/mis-pedidos'...");
      final response = await _api.dio.get('/orders/mis-pedidos');

      // ✅ DIAGNÓSTICO AÑADIDO: Muestra el JSON crudo que llega del backend.
      debugPrint("[OrderService] API Response data: ${response.data}");

      final data = response.data as List;
      _orderHistory = data.map((json) => Order.fromJson(json)).toList();

      debugPrint(
          "[OrderService] Successfully parsed ${_orderHistory.length} orders.");
    } on DioException catch (e) {
      _error =
          e.response?.data['message'] ?? 'Error de API al cargar historial.';
      _orderHistory = [];

      // ✅ DIAGNÓSTICO AÑADIDO: Muestra el error de red específico.
      debugPrint("--- DIO EXCEPTION in fetchOrderHistory ---");
      debugPrint("URL: ${e.requestOptions.uri}");
      debugPrint("Response: ${e.response?.data}");
      debugPrint("------------------------------------------");
    } catch (e, stacktrace) {
      _error = 'Error inesperado al procesar el historial.';
      _orderHistory = [];

      // ✅ DIAGNÓSTICO AÑADIDO: Muestra el error de conversión de datos.
      // ESTE ES PROBABLEMENTE EL ERROR QUE ESTÁS TENIENDO.
      debugPrint("--- PARSING ERROR in fetchOrderHistory ---");
      debugPrint("Error Type: ${e.runtimeType}");
      debugPrint("Error Message: $e");
      debugPrint("Stacktrace: $stacktrace");
      debugPrint("------------------------------------------");
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetail(String orderId) async {
    _isLoadingDetail = true;
    _currentOrderDetail = null;
    _error = null;
    notifyListeners();

    if (_auth?.currentUser == null) {
      _error = "No autenticado.";
      _isLoadingDetail = false;
      notifyListeners();
      return;
    }

    final role = _auth!.currentUser!.rol;
    String endpoint;

    if (role == 'CLIENTE') {
      endpoint = '/orders/mi-pedido/$orderId';
    } else if (role == 'VENDEDOR') {
      endpoint = '/orders/mi-entrega/$orderId';
    } else {
      _error = "Permisos inválidos.";
      _isLoadingDetail = false;
      notifyListeners();
      return;
    }

    try {
      debugPrint('[OrderService] Obteniendo detalle desde: $endpoint');
      final response = await _api.dio.get(endpoint);
      _currentOrderDetail = OrderDetail.fromJson(response.data);
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al cargar detalles.';
    } catch (e) {
      _error = 'Error inesperado al cargar detalles: $e';
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.dio.patch('/orders/mi-pedido/$orderId/cancel');
      await fetchOrderHistory();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al cancelar.';
      return false;
    } catch (e) {
      _error = 'Error inesperado al cancelar.';
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAssignableOrders() async {
    _isLoadingAssignable = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.dio.get('/orders/assignable');
      final data = response.data as List;
      _assignableOrders = data.map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      _error =
          e.response?.data['message'] ?? 'Error al cargar pedidos asignables.';
      _assignableOrders = [];
    } catch (e) {
      _error = 'Ocurrió un error inesperado.';
      _assignableOrders = [];
    } finally {
      _isLoadingAssignable = false;
      notifyListeners();
    }
  }

  Future<bool> assignOrderToVendedor(String orderId, String vendedorId) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.dio.patch(
        '/orders/$orderId/assign',
        data: {'vendedorId': vendedorId},
      );
      await fetchAssignableOrders();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al asignar el pedido.';
      return false;
    } catch (e) {
      _error = 'Ocurrió un error inesperado al asignar.';
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
