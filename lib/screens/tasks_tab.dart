import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartassistant_vendedor/providers/task_provider.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  late Future<void> _tasksFuture;
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _loadTasks();
  }

  Future<void> _loadTasks() async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.fetchTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _tasksFuture = _loadTasks();
    });
  }

  void _showCreateTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateTaskModal(),
    );
  }

  List<Map<String, dynamic>> get _filterOptions => [
        {'label': 'Todas', 'count': 0},
        {'label': 'Pendientes', 'count': 1},
        {'label': 'Completadas', 'count': 2},
      ];

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay tareas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera tarea para organizar tu trabajo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateTaskModal,
            icon: const Icon(Icons.add_task),
            label: const Text('Crear Tarea'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar tareas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshTasks,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando tareas...',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(int index, dynamic task) {
    final isOverdue =
        !task.isCompleted && task.dueDate.isBefore(DateTime.now());
    final isToday = !task.isCompleted &&
        task.dueDate.day == DateTime.now().day &&
        task.dueDate.month == DateTime.now().month &&
        task.dueDate.year == DateTime.now().year;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            if (value != null) {
              Provider.of<TaskProvider>(context, listen: false)
                  .updateTaskStatus(task.id, value);
            }
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.isCompleted ? Colors.grey : Colors.black87,
            fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.notes != null && task.notes!.isNotEmpty)
              Text(
                task.notes!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isOverdue ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(task.dueDate),
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Hoy',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (isOverdue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Vencida',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (task.cliente != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Cliente: ${task.cliente.nombre}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: task.isCompleted
            ? Icon(
                Icons.check_circle,
                color: Colors.green[400],
              )
            : null,
      ),
    );
  }

  Widget _buildFilterChips(TaskProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: _filterOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final count = _getTaskCount(provider, index);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text('${option['label']} ($count)'),
                selected: _selectedFilter == index,
                onSelected: (bool selected) {
                  setState(() {
                    _selectedFilter = selected ? index : 0;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          return Consumer<TaskProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return _buildLoadingState();
              }

              if (provider.error != null) {
                return _buildErrorState(provider.error!);
              }

              final filteredTasks = _getFilteredTasks(provider);

              if (filteredTasks.isEmpty && _selectedFilter == 0) {
                return _buildEmptyState();
              }

              return Column(
                children: [
                  _buildFilterChips(provider),
                  Expanded(
                    child: filteredTasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.filter_list_off,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay tareas ${_selectedFilter == 1 ? 'pendientes' : 'completadas'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _refreshTasks,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 16),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) =>
                                  _buildTaskCard(index, filteredTasks[index]),
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<dynamic> _getFilteredTasks(TaskProvider provider) {
    switch (_selectedFilter) {
      case 1:
        return provider.pendingTasks;
      case 2:
        return provider.completedTasks;
      default:
        return provider.tasks;
    }
  }

  int _getTaskCount(TaskProvider provider, int filterIndex) {
    switch (filterIndex) {
      case 1:
        return provider.pendingTasks.length;
      case 2:
        return provider.completedTasks.length;
      default:
        return provider.tasks.length;
    }
  }
}

class CreateTaskModal extends StatefulWidget {
  const CreateTaskModal({super.key});

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _dueTime = const TimeOfDay(hour: 17, minute: 0);

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectDueTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );

    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  Future<void> _createTask() async {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );

      final success = await taskProvider.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: dueDateTime,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${taskProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crear Nueva Tarea',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  border: OutlineInputBorder(),
                  hintText: '¿Qué necesitas hacer?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Detalles adicionales...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDueDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de vencimiento *',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDueTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Hora de vencimiento *',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_dueTime.format(context)),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vence: ${DateFormat('dd/MM/yyyy HH:mm').format(dueDateTime)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createTask,
                      child: const Text('Crear Tarea'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
