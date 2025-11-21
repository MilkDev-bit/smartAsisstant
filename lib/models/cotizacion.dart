import 'package:smartassistant_vendedor/models/product.dart';

class ClienteSimple {
  final String id;
  final String nombre;
  final String email;
  final String? telefono;

  ClienteSimple({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
  });

  factory ClienteSimple.fromJson(Map<String, dynamic> json) {
    return ClienteSimple(
      id: json['_id'] ?? json['id'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
    };
  }
}

class Cotizacion {
  final String id;
  final String status;
  final double totalPagado;
  final double pagoMensual;
  final int plazoMeses;
  final double enganche;
  final double precioCoche;
  final Product coche;
  final ClienteSimple cliente;

  Cotizacion({
    required this.id,
    required this.status,
    required this.totalPagado,
    required this.pagoMensual,
    required this.plazoMeses,
    required this.enganche,
    required this.precioCoche,
    required this.coche,
    required this.cliente,
  });

  factory Cotizacion.fromJson(Map<String, dynamic> json) {
    return Cotizacion(
      id: json['_id'] ?? json['id'],
      status: json['status'],
      totalPagado: (json['totalPagado'] as num).toDouble(),
      pagoMensual: (json['pagoMensual'] as num).toDouble(),
      plazoMeses: json['plazoMeses'],
      enganche: (json['enganche'] as num).toDouble(),
      precioCoche: (json['precioCoche'] as num).toDouble(),
      coche: Product.fromJson(
          json['coche'] is Map<String, dynamic> ? json['coche'] : {}),
      cliente: ClienteSimple.fromJson(json['cliente']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'totalPagado': totalPagado,
      'pagoMensual': pagoMensual,
      'plazoMeses': plazoMeses,
      'enganche': enganche,
      'precioCoche': precioCoche,
      'coche': coche.toJson(),
      'cliente': cliente.toJson(),
    };
  }
}
