import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:smartassistant_vendedor/models/compra.dart';
import 'package:smartassistant_vendedor/services/api_service.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';

class CompraProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final ApiService _api = ApiService();

  List<Compra> _comprasPendientes = [];
  List<Compra> _misCompras = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<Compra> get comprasPendientes => _comprasPendientes;
  List<Compra> get misCompras => _misCompras;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CompraProvider(this._authProvider);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  String? get _token => _authProvider.token;

  Future<void> fetchComprasPendientes() async {
    if (!_authProvider.isAuthenticated || _token == null) {
      _error = 'No autenticado';
      _notifyAfterBuild();
      return;
    }

    _isLoading = true;
    _error = null;
    _notifyAfterBuild();

    try {
      final response = await _api.get('compra/pendientes', _token!);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is List) {
          final List<Compra> temp = [];
          for (var item in decoded) {
            try {
              if (item is Map<String, dynamic> || item is String) {
                temp.add(Compra.fromJson(item));
              } else {
                if (item != null) {
                  temp.add(Compra.fromJson(item));
                }
              }
            } catch (e, st) {
              debugPrint('Error parsing compra item: $e\n$st\nitem: $item');
            }
          }
          _comprasPendientes = temp;
        } else {
          _error = 'Respuesta inesperada del servidor.';
          _comprasPendientes = [];
        }

        _error = null;
        debugPrint('${_comprasPendientes.length} compras pendientes cargadas');
      } else {
        _error = 'Error al cargar compras pendientes: ${response.statusCode}';
        _comprasPendientes = [];
      }
    } catch (e, st) {
      _error = 'Error de conexión: $e';
      _comprasPendientes = [];
      debugPrint('Error cargando compras pendientes: $e\n$st');
    } finally {
      _isLoading = false;
      _notifyAfterBuild();
    }
  }

  Future<void> fetchMisCompras() async {
    if (!_authProvider.isAuthenticated || _token == null) {
      _error = 'No autenticado';
      _notifyAfterBuild();
      return;
    }

    _isLoading = true;
    _error = null;
    _notifyAfterBuild();

    try {
      final response = await _api.get('compra/mis-compras', _token!);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) {
          final List<Compra> temp = [];
          for (var item in decoded) {
            try {
              temp.add(Compra.fromJson(item));
            } catch (e, st) {
              debugPrint('Error parsing misCompras item: $e\n$st\nitem: $item');
            }
          }
          _misCompras = temp;
        } else {
          _error = 'Respuesta inesperada del servidor.';
          _misCompras = [];
        }
        _error = null;
        debugPrint('${_misCompras.length} mis compras cargadas');
      } else {
        _error = 'Error al cargar mis compras: ${response.statusCode}';
        _misCompras = [];
      }
    } catch (e, st) {
      _error = 'Error de conexión: $e';
      _misCompras = [];
      debugPrint('Error cargando mis compras: $e\n$st');
    } finally {
      _isLoading = false;
      _notifyAfterBuild();
    }
  }

  Future<bool> evaluarFinanciamiento(String compraId) async {
    if (_token == null) return false;

    _isLoading = true;
    _error = null;
    _notifyAfterBuild();

    try {
      final response =
          await _api.patch('compra/$compraId/evaluar', _token!, body: null);

      if (response.statusCode == 200) {
        await fetchComprasPendientes();
        debugPrint('Financiamiento evaluado para compra: $compraId');
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Error al evaluar financiamiento';
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      return false;
    } finally {
      _isLoading = false;
      _notifyAfterBuild();
    }
  }

  Future<bool> aprobarCompra(String compraId, AprobarCompraDto dto) async {
    if (_token == null) return false;

    _isLoading = true;
    _error = null;
    _notifyAfterBuild();

    try {
      final body = json.encode(dto.toJson());
      final response =
          await _api.patch('compra/$compraId/aprobar', _token!, body: body);

      if (response.statusCode == 200) {
        await fetchComprasPendientes();
        debugPrint('Compra $compraId aprobada con estado: ${dto.status}');
        return true;
      } else {
        final data = json.decode(response.body);
        final errorMessage = (data is Map && data['message'] != null)
            ? data['message'] as String
            : 'Error al aprobar compra';

        if (errorMessage.toLowerCase().contains('stock insuficiente') ||
            errorMessage.toLowerCase().contains('no hay suficiente stock') ||
            errorMessage.toLowerCase().contains('insufficient stock')) {
          _error =
              'No hay suficiente stock para completar esta compra. Por favor, verifica el inventario.';
        } else if (errorMessage.toLowerCase().contains('no disponible') ||
            errorMessage.toLowerCase().contains('not available')) {
          _error = 'El vehículo ya no está disponible para la venta.';
        } else if (errorMessage.toLowerCase().contains('no activo') ||
            errorMessage.toLowerCase().contains('not active')) {
          _error = 'El vehículo ha sido desactivado y no puede venderse.';
        } else {
          _error = errorMessage;
        }

        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      return false;
    } finally {
      _isLoading = false;
      _notifyAfterBuild();
    }
  }

  Future<Compra?> getCompraById(String compraId) async {
    if (_token == null) return null;

    try {
      final response = await _api.get('compra/$compraId', _token!);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Compra.fromJson(data);
      } else {
        _error = 'Error al cargar compra: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      return null;
    }
  }

  void clearError() {
    _error = null;
    _notifyAfterBuild();
  }

  void clearCompras() {
    _comprasPendientes = [];
    _misCompras = [];
    _notifyAfterBuild();
  }

  void _notifyAfterBuild() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) {
          try {
            notifyListeners();
          } catch (e) {
            debugPrint('notifyListeners error: $e');
          }
        }
      });
    } catch (e) {
      if (!_disposed) {
        try {
          notifyListeners();
        } catch (err) {
          debugPrint('notifyListeners fallback error: $err');
        }
      }
    }
  }
}
