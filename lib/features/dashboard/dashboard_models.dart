class SalesReport {
  final double totalVentas;
  final int numeroPedidos;

  SalesReport({required this.totalVentas, required this.numeroPedidos});

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      totalVentas: (json['totalVentas'] as num?)?.toDouble() ?? 0.0,
      numeroPedidos: json['numeroPedidos'] ?? 0,
    );
  }
}

class TopProduct {
  final String nombreProducto;
  final int totalVendido;

  TopProduct({required this.nombreProducto, required this.totalVendido});

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      nombreProducto: json['nombreProducto'] ?? 'Desconocido',
      totalVendido: json['totalVendido'] ?? 0,
    );
  }
}

class TopVendedor {
  final String vendedorId;
  final String nombre;
  final String email;
  final int totalEntregas;
  final double totalVendido;

  TopVendedor({
    required this.vendedorId,
    required this.nombre,
    required this.email,
    required this.totalEntregas,
    required this.totalVendido,
  });

  factory TopVendedor.fromJson(Map<String, dynamic> json) {
    return TopVendedor(
      vendedorId: json['vendedorId'] ?? 'N/A',
      nombre: json['nombre'] ?? 'Desconocido',
      email: json['email'] ?? 'N/A',
      totalEntregas: json['totalEntregas'] ?? 0,
      totalVendido: (json['totalVendido'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
