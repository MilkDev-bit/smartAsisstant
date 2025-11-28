class IaResponse {
  final String message;
  final IaResponseType type;
  final dynamic data;

  IaResponse({
    required this.message,
    required this.type,
    this.data,
  });

  factory IaResponse.fromJson(Map<String, dynamic> json) {
    return IaResponse(
      message: json['message'] ?? '',
      type: _parseResponseType(json['type']),
      data: json['data'],
    );
  }

  static IaResponseType _parseResponseType(String? type) {
    switch (type) {
      case 'cotizaciones_table':
        return IaResponseType.cotizacionesTable;
      case 'products_grid':
        return IaResponseType.productsGrid;
      case 'clients_list':
        return IaResponseType.clientsList;
      case 'tasks_list':
        return IaResponseType.tasksList;
      case 'kpi_dashboard':
        return IaResponseType.kpiDashboard;
      case 'expenses_table':
        return IaResponseType.expensesTable;
      default:
        return IaResponseType.text;
    }
  }
}

enum IaResponseType {
  text,
  cotizacionesTable,
  productsGrid,
  clientsList,
  tasksList,
  kpiDashboard,
  expensesTable,
}
