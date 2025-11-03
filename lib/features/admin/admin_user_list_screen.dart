import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_service.dart';
import '../clients/client_user_model.dart';
import '../auth/auth_service.dart';

const List<String> rolesDisponibles = ['ADMIN', 'VENDEDOR', 'CLIENTE'];

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllUsers();
    });
  }

  Future<void> _fetchAllUsers() async {
    final service = Provider.of<AdminService>(context, listen: false);
    await service.fetchAllUsers();
    if (mounted && service.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${service.error}')),
      );
    }
  }

  Future<void> _showChangeRoleDialog(ValidatedUser user) async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    String? selectedRole = user.rol;

    final newRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambiar Rol de ${user.nombre}'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: rolesDisponibles.map((rol) {
                  return RadioListTile<String>(
                    title: Text(rol),
                    value: rol,
                    groupValue: selectedRole,
                    onChanged: (String? value) {
                      setStateDialog(() {
                        selectedRole = value;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () => Navigator.of(context).pop(selectedRole),
            ),
          ],
        );
      },
    );

    if (newRole != null && newRole != user.rol) {
      final success =
          await adminService.updateUserRole(user.id, newRole, authService);
      if (mounted && !success && adminService.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${adminService.error}'),
              backgroundColor: Colors.red),
        );
      } else if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Rol actualizado para ${user.nombre}.'),
              backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Usuarios y Roles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: context.watch<AdminService>().isLoadingUsers
                ? null
                : _fetchAllUsers,
          ),
        ],
      ),
      body: Consumer<AdminService>(
        builder: (context, service, child) {
          if (service.isLoadingUsers && service.allUsers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (service.error != null && service.allUsers.isEmpty) {
            return Center(child: Text('Error: ${service.error}'));
          }
          if (service.allUsers.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          return RefreshIndicator(
            onRefresh: _fetchAllUsers,
            child: ListView.builder(
              itemCount: service.allUsers.length,
              itemBuilder: (context, index) {
                final user = service.allUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                      child:
                          Text(user.nombre.isNotEmpty ? user.nombre[0] : '?')),
                  title: Text(user.nombre),
                  subtitle: Text(user.email),
                  trailing: TextButton(
                    child: Text(user.rol,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showChangeRoleDialog(user),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
