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
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["_id"] ?? json["id"],
        marca: json["marca"],
        modelo: json["modelo"],
        ano: json["ano"],
        precioBase: (json["precioBase"] as num).toDouble(),
        kilometraje: json["kilometraje"],
        vin: json["vin"],
        descripcion: json["descripcion"],
        condicion: json["condicion"],
        tipo: json["tipo"],
        transmision: json["transmision"],
        motor: json["motor"],
        color: json["color"],
        numPuertas: json["numPuertas"],
        imageUrl: json["imageUrl"],
      );

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
      };
}
