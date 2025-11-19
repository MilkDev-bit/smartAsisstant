import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:smartassistant_vendedor/models/cotizacion.dart';
import 'package:smartassistant_vendedor/services/api_service.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';
import 'package:smartassistant_vendedor/providers/product_provider.dart';

class CotizacionProvider with ChangeNotifier {
  AuthProvider _authProvider;
  final ProductProvider _productProvider;
  final ApiService _api = ApiService();

  List<Cotizacion> _cotizaciones = [];
  bool _isLoading = false;
  String? _error;

  List<Cotizacion> get cotizaciones => _cotizaciones;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CotizacionProvider(this._authProvider, this._productProvider) {}

  void updateDependencies(AuthProvider auth, ProductProvider product) {
    _authProvider = auth;
  }

  String? get _token => _authProvider.token;

  Future<void> _loadCotizaciones() async {
    try {
      if (!_authProvider.isAuthenticated || _token == null) {
        print('Usuario no autenticado para cargar cotizaciones');
        return;
      }

      _isLoading = true;
      notifyListeners();

      final response = await _api.get('cotizacion/pendientes', _token!);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cotizaciones = data.map((json) => Cotizacion.fromJson(json)).toList();
        _error = null;
        print('${_cotizaciones.length} cotizaciones cargadas');
      } else {
        _error = 'Error al cargar cotizaciones: ${response.statusCode}';
        _cotizaciones = [];
      }
    } catch (e) {
      _error = 'Error: $e';
      _cotizaciones = [];
      print('Error cargando cotizaciones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getCocheByVin(String vin) async {
    try {
      if (!_authProvider.isAuthenticated) {
        return null;
      }

      print('Buscando coche por VIN: $vin');

      return await _productProvider.findProductByVinAsMap(vin);
    } catch (e) {
      print('Error buscando coche por VIN: $e');
      return null;
    }
  }

  Future<void> fetchCotizacionesPendientes() async {
    await _loadCotizaciones();
  }

  Future<void> loadCotizaciones() async {
    await _loadCotizaciones();
  }

  Future<bool> updateCotizacionStatus(
      String cotizacionId, String status) async {
    if (_token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = json.encode({'status': status});
      final response = await _api.patch(
        'cotizacion/$cotizacionId/status',
        _token!,
        body: body,
      );

      if (response.statusCode == 200) {
        _cotizaciones.removeWhere((cot) => cot.id == cotizacionId);
        print('Cotización $cotizacionId actualizada a: $status');
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Error al actualizar el estado';
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> vendedorCreateCotizacion({
    required String cocheId,
    required String clienteId,
    required double enganche,
    required int plazoMeses,
  }) async {
    if (_token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = json.encode({
        'cocheId': cocheId,
        'clienteId': clienteId,
        'enganche': enganche,
        'plazoMeses': plazoMeses,
      });

      final response = await _api.post(
        'cotizacion/vendedor-create',
        _token!,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Cotización creada exitosamente para cliente: $clienteId');
        return true;
      } else {
        final responseData = json.decode(response.body);
        _error = responseData['message'] ?? 'Error al crear la cotización';
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Cotizacion? getCotizacionById(String id) {
    try {
      return _cotizaciones.firstWhere((cot) => cot.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCotizaciones() {
    _cotizaciones = [];
    notifyListeners();
  }
}
