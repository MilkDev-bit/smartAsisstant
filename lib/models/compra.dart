import 'package:smartassistant_vendedor/models/cotizacion.dart';

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

  factory Compra.fromJson(Map<String, dynamic> json) {
    return Compra(
      id: json['_id'] ?? json['id'],
      cotizacion: Cotizacion.fromJson(json['cotizacion']),
      cliente: ClienteSimple.fromJson(json['cliente']),
      status: json['status'],
      datosFinancieros:
          Map<String, dynamic>.from(json['datosFinancieros'] ?? {}),
      resultadoBuro: Map<String, dynamic>.from(json['resultadoBuro'] ?? {}),
      resultadoBanco: json['resultadoBanco'] != null
          ? Map<String, dynamic>.from(json['resultadoBanco'])
          : null,
      comentariosAnalista: json['comentariosAnalista'],
      fechaAprobacion: json['fechaAprobacion'] != null
          ? DateTime.parse(json['fechaAprobacion'])
          : null,
      fechaEntrega: json['fechaEntrega'] != null
          ? DateTime.parse(json['fechaEntrega'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
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

  bool get estaEnRevision => status == 'En revisión';
  bool get estaAprobada => status == 'Aprobada';
  bool get estaRechazada => status == 'Rechazada';
  bool get estaCompletada => status == 'Completada';
  bool get financiamientoAprobado => resultadoBanco?['aprobado'] == true;

  String get estadoFinanciamiento {
    if (resultadoBanco == null) return 'Pendiente';
    return resultadoBanco!['aprobado'] == true ? 'Aprobado' : 'Rechazado';
  }

  double? get pagoMensualAprobado => resultadoBanco?['pagoMensual'] != null
      ? (resultadoBanco!['pagoMensual'] as num).toDouble()
      : null;

  String? get motivoRechazo => resultadoBanco?['motivoRechazo'];
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
