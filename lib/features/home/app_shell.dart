import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../chat/chat_screen.dart';
import '../clients/clients_screen.dart';
import '../settings/settings_screen.dart';
import '../admin/admin_order_list_screen.dart';
import '../store/store_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRole =
        Provider.of<AuthService>(context, listen: false).currentUser?.rol;

    final List<Widget> pages = _buildPagesForRole(userRole);
    final List<BottomNavigationBarItem> navItems =
        _buildNavItemsForRole(userRole);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BottomNavigationBar(
              items: navItems,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFFD4AF37),
              unselectedItemColor: Colors.grey[400],
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPagesForRole(String? role) {
    return [
      const ChatScreen(),
      _getSecondTabPage(role),
      const SettingsScreen(),
    ];
  }

  List<BottomNavigationBarItem> _buildNavItemsForRole(String? role) {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.chat_bubble),
        label: 'Chat',
      ),
      _getSecondTabNavItem(role),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: 'Ajustes',
      ),
    ];
  }

  Widget _getSecondTabPage(String? role) {
    switch (role) {
      case 'ADMIN':
        return const AdminOrderListScreen();
      case 'VENDEDOR':
        return const ClientsScreen();
      case 'CLIENTE':
        return const StoreScreen();
      default:
        return const Center(child: Text('Rol no reconocido'));
    }
  }

  BottomNavigationBarItem _getSecondTabNavItem(String? role) {
    switch (role) {
      case 'ADMIN':
        return const BottomNavigationBarItem(
          icon: Icon(Icons.assignment_ind_outlined),
          activeIcon: Icon(Icons.assignment_ind),
          label: 'Asignar',
        );
      case 'VENDEDOR':
        return const BottomNavigationBarItem(
          icon: Icon(Icons.delivery_dining_outlined),
          activeIcon: Icon(Icons.delivery_dining),
          label: 'Entregas',
        );
      case 'CLIENTE':
        return const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Mis Pedidos',
        );
      default:
        return const BottomNavigationBarItem(
          icon: Icon(Icons.help_outline),
          label: 'Desconocido',
        );
    }
  }
}
