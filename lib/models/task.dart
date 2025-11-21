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
  final bool? urgentNotificationSent;

  Task({
    required this.id,
    required this.title,
    this.notes,
    required this.dueDate,
    required this.isCompleted,
    this.cliente,
    this.urgentNotificationSent,
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
        urgentNotificationSent: json["urgentNotificationSent"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "notes": notes,
        "dueDate": dueDate.toIso8601String(),
        "isCompleted": isCompleted,
        "cliente": cliente?.toJson(),
        if (urgentNotificationSent != null)
          "urgentNotificationSent": urgentNotificationSent,
      };

  bool get isUrgent {
    if (isCompleted) return false;
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return difference.inMinutes > 0 && difference.inMinutes <= 60;
  }

  bool get isOverdue {
    if (isCompleted) return false;
    return dueDate.isBefore(DateTime.now());
  }

  bool get isToday {
    if (isCompleted) return false;
    final now = DateTime.now();
    return dueDate.day == now.day &&
        dueDate.month == now.month &&
        dueDate.year == now.year;
  }

  String get timeRemaining {
    if (isCompleted) return 'Completada';

    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      final overdue = now.difference(dueDate);
      if (overdue.inDays > 0) {
        return 'Vencida hace ${overdue.inDays} día${overdue.inDays > 1 ? 's' : ''}';
      } else if (overdue.inHours > 0) {
        return 'Vencida hace ${overdue.inHours} hora${overdue.inHours > 1 ? 's' : ''}';
      } else {
        return 'Vencida hace ${overdue.inMinutes} minuto${overdue.inMinutes > 1 ? 's' : ''}';
      }
    }

    if (difference.inDays > 0) {
      return 'En ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'En ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'En ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    }
  }

  String get timeRemainingShort {
    if (isCompleted) return 'Completada';

    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      final overdue = now.difference(dueDate);
      if (overdue.inDays > 0) return '${overdue.inDays}d atrás';
      if (overdue.inHours > 0) return '${overdue.inHours}h atrás';
      return '${overdue.inMinutes}m atrás';
    }

    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    return '${difference.inMinutes}m';
  }
}
