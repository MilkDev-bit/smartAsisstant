import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartassistant_vendedor/services/api_service.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';
import 'package:smartassistant_vendedor/models/cotizacion.dart';

class UserProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final ApiService _api = ApiService();

  List<ClienteSimple> _clients = [];
  bool _isLoading = false;
  String? _error;

  List<ClienteSimple> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserProvider(this._authProvider);

  String? get _token => _authProvider.token;

  Future<List<ClienteSimple>> fetchClients() async {
    if (_token == null) throw Exception('No autenticado');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('user/clients', _token!);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _clients = data.map((json) => ClienteSimple.fromJson(json)).toList();
        print('${_clients.length} clientes cargados');
        return _clients;
      } else {
        _error = 'Error al cargar clientes: ${response.statusCode}';
        _clients = [];
        throw Exception(_error);
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _clients = [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ClienteSimple> searchClients(String query) {
    if (query.isEmpty) return _clients;

    final queryLower = query.toLowerCase();
    return _clients.where((client) {
      return client.nombre.toLowerCase().contains(queryLower) ||
          client.email.toLowerCase().contains(queryLower) ||
          (client.telefono?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  ClienteSimple? findClientById(String id) {
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearClients() {
    _clients = [];
    notifyListeners();
  }
}
