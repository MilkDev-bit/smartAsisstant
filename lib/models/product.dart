import 'dart:convert';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

class Product {
  final String id;
  final String marca;
  final String modelo;
  final int ano;
  final double precioBase;
  final int kilometraje;
  final String vin;
  final String descripcion;
  final String condicion;
  final String tipo;
  final String transmision;
  final String motor;
  final String color;
  final int numPuertas;
  final String? imageUrl;
  final int stock;
  final bool disponible;
  final String? proveedorId;
  final double costoCompra;
  final DateTime? fechaCompra;
  final String? compradoPorId;
  final int vecesVendido;
  final bool activo;

  Product({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.precioBase,
    required this.kilometraje,
    required this.vin,
    required this.descripcion,
    required this.condicion,
    required this.tipo,
    required this.transmision,
    required this.motor,
    required this.color,
    required this.numPuertas,
    this.imageUrl,
    this.stock = 1,
    this.disponible = true,
    this.proveedorId,
    this.costoCompra = 0,
    this.fechaCompra,
    this.compradoPorId,
    this.vecesVendido = 0,
    this.activo = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["_id"] ?? json["id"] ?? '',
        marca: json["marca"] ?? '',
        modelo: json["modelo"] ?? '',
        ano: _parseInt(json["ano"]),
        precioBase: _parseDouble(json["precioBase"]),
        kilometraje: _parseInt(json["kilometraje"]),
        vin: json["vin"] ?? '',
        descripcion: json["descripcion"] ?? '',
        condicion: json["condicion"] ?? '',
        tipo: json["tipo"] ?? '',
        transmision: json["transmision"] ?? '',
        motor: json["motor"] ?? '',
        color: json["color"] ?? '',
        numPuertas: _parseInt(json["numPuertas"]),
        imageUrl: json["imageUrl"],
        stock: _parseInt(json["stock"] ?? 1),
        disponible: json["disponible"] ?? true,
        proveedorId: json["proveedor"] is String
            ? json["proveedor"]
            : json["proveedor"]?["_id"],
        costoCompra: _parseDouble(json["costoCompra"] ?? 0),
        fechaCompra: json["fechaCompra"] != null
            ? DateTime.tryParse(json["fechaCompra"])
            : null,
        compradoPorId: json["compradoPor"] is String
            ? json["compradoPor"]
            : json["compradoPor"]?["_id"],
        vecesVendido: _parseInt(json["vecesVendido"] ?? 0),
        activo: json["activo"] ?? true,
      );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String get nombreCompleto => '$marca $modelo $ano';

  Map<String, dynamic> toJson() => {
        "id": id,
        "marca": marca,
        "modelo": modelo,
        "ano": ano,
        "precioBase": precioBase,
        "kilometraje": kilometraje,
        "vin": vin,
        "descripcion": descripcion,
        "condicion": condicion,
        "tipo": tipo,
        "transmision": transmision,
        "motor": motor,
        "color": color,
        "numPuertas": numPuertas,
        "imageUrl": imageUrl,
        "stock": stock,
        "disponible": disponible,
        if (proveedorId != null) "proveedor": proveedorId,
        "costoCompra": costoCompra,
        if (fechaCompra != null) "fechaCompra": fechaCompra!.toIso8601String(),
        if (compradoPorId != null) "compradoPor": compradoPorId,
        "vecesVendido": vecesVendido,
        "activo": activo,
      };

  bool get estaDisponible => disponible && activo && stock > 0;
}
