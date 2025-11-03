class Order {
  final String id;
  final String status;
  final double total;
  final DateTime createdAt;

  final String clienteId;
  final OrderClientInfo? clienteInfo;

  Order({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.clienteId,
    this.clienteInfo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    String parsedClienteId;
    OrderClientInfo? parsedClienteInfo;

    if (json['cliente'] is String) {
      parsedClienteId = json['cliente'] as String;
      parsedClienteInfo = null;
    } else if (json['cliente'] is Map<String, dynamic>) {
      parsedClienteInfo =
          OrderClientInfo.fromJson(json['cliente'] as Map<String, dynamic>);
      parsedClienteId = parsedClienteInfo.id;
    } else {
      parsedClienteId = 'ID no encontrado';
      parsedClienteInfo = null;
    }

    return Order(
      id: json['_id'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      clienteId: parsedClienteId,
      clienteInfo: parsedClienteInfo,
    );
  }
}

class OrderClientInfo {
  final String id;
  final String nombre;
  final String email;
  final String? telefono;

  OrderClientInfo({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
  });

  factory OrderClientInfo.fromJson(Map<String, dynamic> json) {
    return OrderClientInfo(
      id: json['_id'] as String,
      nombre: json['nombre'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      telefono: json['telefono'] as String?,
    );
  }
}
