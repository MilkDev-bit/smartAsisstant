import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/api_service.dart';
import 'dashboard_models.dart';

class DashboardService extends ChangeNotifier {
  final ApiService _api;

  SalesReport? _salesReport;
  List<TopProduct> _topProducts = [];
  List<TopVendedor> _topVendedores = [];
  bool _isLoading = false;
  String? _error;

  SalesReport? get salesReport => _salesReport;
  List<TopProduct> get topProducts => _topProducts;
  List<TopVendedor> get topVendedores => _topVendedores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DashboardService(this._api);

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final responses = await Future.wait([
        _api.dio.get('/dashboard/reporte-ventas'),
        _api.dio.get('/dashboard/top-productos'),
        _api.dio.get('/dashboard/top-vendedores'),
      ]);

      _salesReport = SalesReport.fromJson(responses[0].data);

      final List<dynamic> topProductsData = responses[1].data;
      _topProducts =
          topProductsData.map((json) => TopProduct.fromJson(json)).toList();

      final List<dynamic> topVendedoresData = responses[2].data;
      _topVendedores =
          topVendedoresData.map((json) => TopVendedor.fromJson(json)).toList();
    } on DioException catch (e) {
      _error =
          e.response?.data['message'] ?? 'Error al cargar datos del dashboard.';
      _salesReport = null;
      _topProducts = [];
      _topVendedores = [];
    } catch (e) {
      _error = 'Ocurrió un error inesperado.';
      _salesReport = null;
      _topProducts = [];
      _topVendedores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
