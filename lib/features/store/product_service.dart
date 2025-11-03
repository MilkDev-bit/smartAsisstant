import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/api_service.dart';
import 'product_model.dart';
import 'package:image_picker/image_picker.dart';

class ProductService extends ChangeNotifier {
  // --- CORRECCIÓN 1: Eliminar la creación de la instancia local ---
  // ANTES: final ApiService _apiService = ApiService();
  // AHORA:
  final ApiService _apiService;

  // --- CORRECCIÓN 2: Añadir un constructor que reciba el ApiService ---
  ProductService(this._apiService);

  List<Product> _products = [];
  List<Product> _allProducts = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> uploadProductImage(String productId, XFile imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file":
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      // El resto del código ya usa _apiService, así que no necesita cambios.
      final response = await _apiService.dio.post(
        '/products/$productId/upload',
        data: formData,
      );

      return response.data['imageUrl'];
    } catch (e) {
      _error = 'Error al subir la imagen.';
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/products/tienda');
      final List<dynamic> data = response.data;
      _products = data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al cargar productos.';
      _products = [];
    } catch (e) {
      _error = 'Ocurrió un error inesperado.';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllProductsForAdmin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/products/all');
      final List<dynamic> data = response.data;
      _allProducts = data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      _error =
          e.response?.data['message'] ?? 'Error al cargar todos los productos.';
      _allProducts = [];
    } catch (e) {
      _error = 'Ocurrió un error inesperado.';
      _allProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> createProduct(Map<String, dynamic> productData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response =
          await _apiService.dio.post('/products', data: productData);
      final newProduct = Product.fromJson(response.data);
      await fetchAllProductsForAdmin();
      return newProduct;
    } on DioException catch (e) {
      _error = e.response?.data['message'] is List
          ? (e.response?.data['message'] as List).join(', ')
          : e.response?.data['message'] ?? 'Error al crear el producto.';
    } catch (e) {
      _error = 'Ocurrió un error inesperado.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null; // Movido para asegurar que siempre retorne algo
  }

  Future<bool> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.dio.patch('/products/$productId', data: productData);
      await fetchAllProductsForAdmin();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] is List
          ? (e.response?.data['message'] as List).join(', ')
          : e.response?.data['message'] ?? 'Error al actualizar el producto.';
      return false;
    } catch (e) {
      _error = 'Ocurrió un error inesperado.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.dio.delete('/products/$productId');
      await fetchAllProductsForAdmin();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al eliminar el producto.';
      return false;
    } catch (e) {
      _error = 'Ocurrió un error inesperado.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
