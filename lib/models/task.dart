import 'dart:convert';
import 'package:smartassistant_vendedor/models/cotizacion.dart';

Task taskFromJson(String str) => Task.fromJson(json.decode(str));

class Task {
  final String id;
  final String title;
  final String? notes;
  final DateTime dueDate;
  bool isCompleted;
  final ClienteSimple? cliente;

  Task({
    required this.id,
    required this.title,
    this.notes,
    required this.dueDate,
    required this.isCompleted,
    this.cliente,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["_id"] ?? json["id"],
        title: json["title"],
        notes: json["notes"],
        dueDate: DateTime.parse(json["dueDate"]),
        isCompleted: json["isCompleted"],
        cliente: json["cliente"] != null && json["cliente"] is Map
            ? ClienteSimple.fromJson(json["cliente"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "notes": notes,
        "dueDate": dueDate.toIso8601String(),
        "isCompleted": isCompleted,
        "cliente": cliente?.toJson(),
      };
}
