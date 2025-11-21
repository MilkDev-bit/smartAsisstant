import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:smartassistant_vendedor/models/product.dart';
import 'package:smartassistant_vendedor/services/api_service.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';

class ProductProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final ApiService _api = ApiService();

  List<Product> _allProducts = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductProvider(this._authProvider);

  String? get _token => _authProvider.token;

  Future<void> loadAllProducts() async {
    if (_token == null) throw Exception('No autenticado');

    _isLoading = true;
    _error = null;
    _notifyAfterBuild();

    try {
      final response = await _api.get('products/tienda', _token!);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allProducts = data.map((json) => Product.fromJson(json)).toList();
        print('${_allProducts.length} productos cargados');
      } else {
        _error = 'Error al cargar productos: ${response.statusCode}';
        _allProducts = [];
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _allProducts = [];
    } finally {
      _isLoading = false;
      _notifyAfterBuild();
    }
  }

  Future<Product> findByVin(String vin) async {
    if (_token == null) {
      throw Exception('No autenticado');
    }

    try {
      final normalizedVin = vin.trim().toUpperCase();
      print('Buscando producto por VIN: $normalizedVin');

      final response =
          await _api.get('products/find-by-vin/$normalizedVin', _token!);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Product product = Product.fromJson(data);

        print('Producto encontrado: ${product.marca} ${product.modelo}');
        return product;
      } else if (response.statusCode == 404) {
        throw Exception('Coche con VIN "$normalizedVin" no encontrado');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en findByVin: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> findProductByVinAsMap(String vin) async {
    try {
      final product = await findByVin(vin);
      return product.toJson();
    } catch (e) {
      print('Error en findProductByVinAsMap: $e');
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _allProducts;

    final queryLower = query.toLowerCase();
    return _allProducts.where((product) {
      return product.marca.toLowerCase().contains(queryLower) ||
          product.modelo.toLowerCase().contains(queryLower) ||
          product.vin.toLowerCase().contains(queryLower) ||
          product.nombreCompleto.toLowerCase().contains(queryLower);
    }).toList();
  }

  Product? findById(String id) {
    try {
      return _allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    _notifyAfterBuild();
  }

  void clearProducts() {
    _allProducts = [];
    _notifyAfterBuild();
  }

  void _notifyAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
