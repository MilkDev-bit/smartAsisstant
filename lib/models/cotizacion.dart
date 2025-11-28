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
  final double tasaInteres;
  final double montoFinanciado;
  final Product coche;
  final ClienteSimple cliente;
  final String? notasVendedor; // Nuevo campo agregado

  Cotizacion({
    required this.id,
    required this.status,
    required this.totalPagado,
    required this.pagoMensual,
    required this.plazoMeses,
    required this.enganche,
    required this.precioCoche,
    required this.tasaInteres,
    required this.montoFinanciado,
    required this.coche,
    required this.cliente,
    this.notasVendedor,
  });

  factory Cotizacion.fromJson(Map<String, dynamic> json) {
    return Cotizacion(
      id: json['_id'] ?? json['id'] ?? '',
      status: json['status'] ?? 'Pendiente',
      totalPagado: (json['totalPagado'] as num?)?.toDouble() ?? 0.0,
      pagoMensual: (json['pagoMensual'] as num?)?.toDouble() ?? 0.0,
      plazoMeses: json['plazoMeses'] ?? 0,
      enganche: (json['enganche'] as num?)?.toDouble() ?? 0.0,
      precioCoche: (json['precioCoche'] as num?)?.toDouble() ?? 0.0,
      tasaInteres: (json['tasaInteres'] as num?)?.toDouble() ?? 0.0,
      montoFinanciado: (json['montoFinanciado'] as num?)?.toDouble() ?? 0.0,
      coche: Product.fromJson(
          json['coche'] is Map<String, dynamic> ? json['coche'] : {}),
      cliente: ClienteSimple.fromJson(json['cliente'] ?? {}),
      notasVendedor: json['notasVendedor'],
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
      'tasaInteres': tasaInteres,
      'montoFinanciado': montoFinanciado,
      'coche': coche.toJson(),
      'cliente': cliente.toJson(),
      'notasVendedor': notasVendedor,
    };
  }
}
