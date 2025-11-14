import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:smartassistant_vendedor/models/task.dart';
import 'package:smartassistant_vendedor/services/api_service.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';

class TaskProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final ApiService _api = ApiService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TaskProvider(this._authProvider);

  String? get _token => _authProvider.token;

  Future<void> fetchTasks() async {
    if (_token == null) {
      _error = 'No autenticado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('tasks/mis-tareas', _token!);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _tasks = data.map((json) => Task.fromJson(json)).toList();
        print('${_tasks.length} tareas cargadas');
      } else if (response.statusCode == 404) {
        _tasks = [];
        print('ℹNo hay tareas asignadas');
      } else {
        _error = 'Error al cargar tareas: ${response.statusCode}';
        _tasks = [];
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTaskStatus(String taskId, bool isCompleted) async {
    if (_token == null) return false;

    try {
      final body = json.encode({'isCompleted': isCompleted});
      final response = await _api.patch(
        'tasks/$taskId/status',
        _token!,
        body: body,
      );

      if (response.statusCode == 200) {
        final index = _tasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          _tasks[index].isCompleted = isCompleted;
          print('Tarea $taskId actualizada: $isCompleted');
        }
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Error al actualizar tarea';
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      return false;
    }
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    String? clienteId,
  }) async {
    if (_token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = json.encode({
        'title': title,
        'notes': description,
        'dueDate': dueDate.toIso8601String(),
        if (clienteId != null && clienteId.isNotEmpty) 'clienteId': clienteId,
      });

      final response = await _api.post('tasks', _token!, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Task newTask = Task.fromJson(data);

        _tasks.add(newTask);
        notifyListeners();
        print('Nueva tarea creada: $title');

        _isLoading = false;
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ??
            'Error al crear la tarea: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error al crear la tarea: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createQuickTask(String title) async {
    return createTask(
      title: title,
      description: 'Tarea rápida creada desde la app',
      dueDate: DateTime.now().add(const Duration(days: 1)),
    );
  }

  List<Task> get pendingTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<Task> get overdueTasks {
    final now = DateTime.now();
    return _tasks
        .where((task) => !task.isCompleted && task.dueDate.isBefore(now))
        .toList();
  }

  List<Task> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _tasks
        .where((task) =>
            !task.isCompleted &&
            task.dueDate.isAfter(today) &&
            task.dueDate.isBefore(tomorrow))
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearTasks() {
    _tasks = [];
    notifyListeners();
  }
}
