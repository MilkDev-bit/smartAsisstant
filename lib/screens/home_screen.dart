import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartassistant_vendedor/screens/cotizaciones_tab.dart';
import 'package:smartassistant_vendedor/screens/tasks_tab.dart';
import 'package:smartassistant_vendedor/screens/all_products_screen.dart';
import 'package:smartassistant_vendedor/screens/compras_pendientes_screen.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';
import 'package:smartassistant_vendedor/providers/compra_provider.dart';
import 'package:smartassistant_vendedor/widgets/vin_scanner_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const CotizacionesTab(),
    const ComprasPendientesScreen(),
    const TasksTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Cotizaciones Pendientes';
      case 1:
        return 'Compras Pendientes';
      case 2:
        return 'Mis Tareas';
      case 3:
        return 'Mi Perfil';
      default:
        return 'SmartAssistant CRM';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        actions: _selectedIndex == 0
            ? [
                const VinScannerButton(),
                IconButton(
                  icon: const Icon(Icons.directions_car),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllProductsScreen()),
                    );
                  },
                  tooltip: 'Ver Catálogo de Vehículos',
                )
              ]
            : _selectedIndex == 1
                ? [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        Provider.of<CompraProvider>(context, listen: false)
                            .fetchComprasPendientes();
                      },
                      tooltip: 'Actualizar Compras',
                    ),
                  ]
                : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote_outlined),
            activeIcon: Icon(Icons.request_quote),
            label: 'Cotizaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Compras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            activeIcon: Icon(Icons.task_alt),
            label: 'Tareas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user?.nombre ?? 'Vendedor',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(
                      user?.rol ?? 'VENDEDOR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text('Autenticación de Dos Factores'),
                  subtitle: const Text('Aumenta la seguridad de tu cuenta'),
                  trailing: Switch(
                    value: user?.twoFactorEnabled ?? false,
                    onChanged: (value) async {
                      final s = ScaffoldMessenger.of(context);
                      try {
                        await authProvider.toggle2FA(value);
                        s.showSnackBar(SnackBar(
                          content: Text(
                            value
                                ? '2FA activado correctamente'
                                : '2FA desactivado correctamente',
                          ),
                          backgroundColor: Colors.green,
                        ));
                      } catch (e) {
                        s.showSnackBar(SnackBar(
                          content: Text(
                              'Error: ${e.toString().replaceAll("Exception: ", "")}'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notificaciones Push'),
                  subtitle: const Text('Recibe notificaciones importantes'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value
                              ? 'Notificaciones activadas'
                              : 'Notificaciones desactivadas'),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Ayuda y Soporte'),
                  subtitle: const Text('Centro de ayuda y contacto'),
                  onTap: () => _showHelpDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Acerca de'),
                  subtitle: const Text('Información de la aplicación'),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: ListTile(
              leading:
                  const Icon(Icons.directions_car, color: Colors.blueAccent),
              title: const Text('Catálogo de Vehículos'),
              subtitle: const Text('Ver todos los vehículos disponibles'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AllProductsScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _showLogoutDialog(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Cerrar Sesión'),
          ],
        ),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ayuda y Soporte'),
        content: const Text(
          '📧 soporte@smartassistant.com\n'
          '📞 +52 55 1234 5678\n'
          '🕒 Lunes a Viernes 9:00 - 18:00',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AlertDialog(
        title: Text('Acerca de'),
        content: Text(
          'SmartAssistant CRM - Vendedores\n'
          'Versión: 1.0.0\n'
          '© 2024 SmartAssistant CRM',
        ),
      ),
    );
  }
}
