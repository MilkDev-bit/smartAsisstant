class OrderDetailProductInfo {
  final String nombre;
  final String? descripcion;

  OrderDetailProductInfo({required this.nombre, this.descripcion});

  factory OrderDetailProductInfo.fromJson(Map<String, dynamic> json) {
    return OrderDetailProductInfo(
      nombre: json['nombre'] ?? 'Producto no encontrado',
      descripcion: json['descripcion'],
    );
  }
}

class OrderItemDetail {
  final OrderDetailProductInfo product;
  final int quantity;
  final double priceAtPurchase;

  OrderItemDetail({
    required this.product,
    required this.quantity,
    required this.priceAtPurchase,
  });

  double get subtotal => priceAtPurchase * quantity;

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      product: OrderDetailProductInfo.fromJson(json['product']),
      quantity: json['quantity'] ?? 0,
      priceAtPurchase: (json['priceAtPurchase'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderDetailClientInfo {
  final String nombre;
  final String? email;
  final String? telefono;

  OrderDetailClientInfo({
    required this.nombre,
    this.email,
    this.telefono,
  });

  factory OrderDetailClientInfo.fromJson(Map<String, dynamic> json) {
    return OrderDetailClientInfo(
      nombre: json['nombre'] ?? 'N/A',
      email: json['email'],
      telefono: json['telefono'],
    );
  }
}

class OrderDetail {
  final String id;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderItemDetail> items;
  final OrderDetailClientInfo? cliente;

  OrderDetail({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
    this.cliente,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<OrderItemDetail> parsedItems = itemsList
        .map((itemJson) => OrderItemDetail.fromJson(itemJson))
        .toList();

    return OrderDetail(
      id: json['_id'],
      status: json['status'],
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      items: parsedItems,
      cliente: json['cliente'] != null
          ? OrderDetailClientInfo.fromJson(json['cliente'])
          : null,
    );
  }
}
