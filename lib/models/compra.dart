import 'dart:convert';
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

  factory ClienteSimple.fromJson(dynamic json) {
    if (json == null) {
      return ClienteSimple(id: '', nombre: 'Cliente', email: '');
    }

    if (json is String) {
      return ClienteSimple(id: json, nombre: 'Cliente', email: '');
    }

    if (json is Map<String, dynamic>) {
      if (json.containsKey(r'$oid')) {
        return ClienteSimple(
            id: json[r'$oid'] ?? '', nombre: 'Cliente', email: '');
      }

      return ClienteSimple(
        id: (json['_id'] ?? json['id'] ?? '') as String,
        nombre: (json['nombre'] ?? 'Cliente') as String,
        email: (json['email'] ?? '') as String,
        telefono: json['telefono'] as String?,
      );
    }
    return ClienteSimple(id: '', nombre: 'Cliente', email: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      if (telefono != null) 'telefono': telefono,
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
  final Product? coche;
  final ClienteSimple? cliente;

  Cotizacion({
    required this.id,
    required this.status,
    required this.totalPagado,
    required this.pagoMensual,
    required this.plazoMeses,
    required this.enganche,
    required this.precioCoche,
    this.coche,
    this.cliente,
  });

  factory Cotizacion.fromJson(dynamic json) {
    if (json == null) {
      return Cotizacion(
        id: '',
        status: 'Desconocido',
        totalPagado: 0,
        pagoMensual: 0,
        plazoMeses: 0,
        enganche: 0,
        precioCoche: 0,
        coche: null,
        cliente: null,
      );
    }

    if (json is String) {
      return Cotizacion(
        id: json,
        status: 'Desconocido',
        totalPagado: 0,
        pagoMensual: 0,
        plazoMeses: 0,
        enganche: 0,
        precioCoche: 0,
        coche: null,
        cliente: null,
      );
    }

    if (json is Map<String, dynamic>) {
      if (json.containsKey(r'$oid')) {
        return Cotizacion(
          id: json[r'$oid'] ?? '',
          status: 'Desconocido',
          totalPagado: 0,
          pagoMensual: 0,
          plazoMeses: 0,
          enganche: 0,
          precioCoche: 0,
          coche: null,
          cliente: null,
        );
      }

      double _asDouble(dynamic v) {
        if (v == null) return 0.0;
        if (v is num) return v.toDouble();
        if (v is String) return double.tryParse(v) ?? 0.0;
        return 0.0;
      }

      int _asInt(dynamic v) {
        if (v == null) return 0;
        if (v is int) return v;
        if (v is double) return v.toInt();
        if (v is String) return int.tryParse(v) ?? 0;
        return 0;
      }

      Product? prod;
      try {
        if (json['coche'] != null && json['coche'] is Map<String, dynamic>) {
          prod = Product.fromJson(json['coche']);
        }
      } catch (_) {
        prod = null;
      }

      ClienteSimple? cliente;
      try {
        if (json['cliente'] != null)
          cliente = ClienteSimple.fromJson(json['cliente']);
      } catch (_) {
        cliente = null;
      }

      return Cotizacion(
        id: (json['_id'] ?? json['id'] ?? '') as String,
        status: (json['status'] ?? 'Desconocido') as String,
        totalPagado: _asDouble(json['totalPagado'] ?? json['total'] ?? 0),
        pagoMensual: _asDouble(json['pagoMensual'] ?? 0),
        plazoMeses: _asInt(json['plazoMeses'] ?? 0),
        enganche: _asDouble(json['enganche'] ?? 0),
        precioCoche: _asDouble(json['precioCoche'] ?? json['precio'] ?? 0),
        coche: prod,
        cliente: cliente,
      );
    }

    return Cotizacion(
      id: '',
      status: 'Desconocido',
      totalPagado: 0,
      pagoMensual: 0,
      plazoMeses: 0,
      enganche: 0,
      precioCoche: 0,
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
      if (coche != null) 'coche': coche!.toJson(),
      if (cliente != null) 'cliente': cliente!.toJson(),
    };
  }
}

class Compra {
  final String id;
  final Cotizacion cotizacion;
  final ClienteSimple cliente;
  final String status;
  final Map<String, dynamic> datosFinancieros;
  final Map<String, dynamic> resultadoBuro;
  final Map<String, dynamic>? resultadoBanco;
  final String? comentariosAnalista;
  final DateTime? fechaAprobacion;
  final DateTime? fechaEntrega;
  final DateTime createdAt;

  Compra({
    required this.id,
    required this.cotizacion,
    required this.cliente,
    required this.status,
    required this.datosFinancieros,
    required this.resultadoBuro,
    this.resultadoBanco,
    this.comentariosAnalista,
    this.fechaAprobacion,
    this.fechaEntrega,
    required this.createdAt,
  });

  factory Compra.fromJson(dynamic json) {
    if (json == null) {
      return Compra(
        id: '',
        cotizacion: Cotizacion.fromJson(null),
        cliente: ClienteSimple.fromJson(null),
        status: 'Pendiente',
        datosFinancieros: {},
        resultadoBuro: {},
        resultadoBanco: null,
        comentariosAnalista: null,
        fechaAprobacion: null,
        fechaEntrega: null,
        createdAt: DateTime.now(),
      );
    }

    final Map<String, dynamic> map = (json is Map<String, dynamic>)
        ? json
        : (json is String ? jsonDecode(json) : {});

    final dynamic cotData = map['cotizacion'];
    final Cotizacion cot = Cotizacion.fromJson(cotData);

    final ClienteSimple cliente = ClienteSimple.fromJson(map['cliente']);

    Map<String, dynamic> datosFinancieros = {};
    if (map['datosFinancieros'] is Map<String, dynamic>) {
      datosFinancieros = Map<String, dynamic>.from(map['datosFinancieros']);
    }

    if (!datosFinancieros.containsKey('capacidadPago')) {
      final ingresoMensual =
          (datosFinancieros['ingresoMensual'] as num?)?.toDouble() ?? 0.0;
      final otrosIngresos =
          (datosFinancieros['otrosIngresos'] as num?)?.toDouble() ?? 0.0;
      final gastosMensuales =
          (datosFinancieros['gastosMensuales'] as num?)?.toDouble() ?? 0.0;
      final deudasActuales =
          (datosFinancieros['deudasActuales'] as num?)?.toDouble() ?? 0.0;
      datosFinancieros['capacidadPago'] =
          (ingresoMensual + otrosIngresos - gastosMensuales - deudasActuales)
              .toDouble();
    }

    Map<String, dynamic> resultadoBuro = {};
    if (map['resultadoBuro'] is Map<String, dynamic>) {
      resultadoBuro = Map<String, dynamic>.from(map['resultadoBuro']);
    }

    Map<String, dynamic>? resultadoBanco;
    if (map['resultadoBanco'] is Map<String, dynamic>) {
      resultadoBanco = Map<String, dynamic>.from(map['resultadoBanco']);
    } else {
      resultadoBanco = null;
    }

    DateTime? _parseDate(dynamic d) {
      if (d == null) return null;
      if (d is String) return DateTime.tryParse(d);
      if (d is Map && d.containsKey(r'$date')) {
        return DateTime.tryParse(d[r'$date']);
      }
      return null;
    }

    DateTime createdAt = DateTime.now();
    if (map['createdAt'] is String) {
      createdAt = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else if (map['createdAt'] is Map &&
        map['createdAt'].containsKey(r'$date')) {
      createdAt =
          DateTime.tryParse(map['createdAt'][r'$date']) ?? DateTime.now();
    }

    return Compra(
      id: (map['_id'] is Map && map['_id'].containsKey(r'$oid'))
          ? map['_id'][r'$oid']
          : (map['_id'] ?? map['id'] ?? '') as String,
      cotizacion: cot,
      cliente: cliente,
      status: (map['status'] ?? 'Pendiente') as String,
      datosFinancieros: datosFinancieros,
      resultadoBuro: resultadoBuro,
      resultadoBanco: resultadoBanco,
      comentariosAnalista: map['comentariosAnalista'] as String?,
      fechaAprobacion: _parseDate(map['fechaAprobacion']),
      fechaEntrega: _parseDate(map['fechaEntrega']),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cotizacion': cotizacion.toJson(),
      'cliente': cliente.toJson(),
      'status': status,
      'datosFinancieros': datosFinancieros,
      'resultadoBuro': resultadoBuro,
      'resultadoBanco': resultadoBanco,
      'comentariosAnalista': comentariosAnalista,
      'fechaAprobacion': fechaAprobacion?.toIso8601String(),
      'fechaEntrega': fechaEntrega?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get estaEnRevision =>
      status.toLowerCase() == 'en revisión' ||
      status.toLowerCase() == 'en revision';
  bool get estaAprobada => status.toLowerCase() == 'aprobada';
  bool get estaRechazada => status.toLowerCase() == 'rechazada';
  bool get estaCompletada => status.toLowerCase() == 'completada';

  bool get financiamientoAprobado =>
      (resultadoBanco != null && (resultadoBanco!['aprobado'] == true));

  String get estadoFinanciamiento {
    if (resultadoBanco == null) return 'Pendiente';
    return resultadoBanco!['aprobado'] == true ? 'Aprobado' : 'Rechazado';
  }

  double get pagoMensualAprobado {
    if (resultadoBanco != null && resultadoBanco!['pagoMensual'] != null) {
      final v = resultadoBanco!['pagoMensual'];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? cotizacion.pagoMensual;
    }
    return cotizacion.pagoMensual;
  }

  String? get motivoRechazo => resultadoBanco?['motivoRechazo'] as String?;
}

class AprobarCompraDto {
  final String status;
  final String? comentarios;

  AprobarCompraDto({
    required this.status,
    this.comentarios,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (comentarios != null) 'comentarios': comentarios,
    };
  }
}
