import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const IaChatApp());
}

class IaChatApp extends StatelessWidget {
  const IaChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IA Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF4A90E2),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4A90E2),
          secondary: Color(0xFF7C4DFF),
          background: Color(0xFFF8F9FA),
          surface: Colors.white,
          surfaceVariant: Color(0xFFF1F3F4),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF202124), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFF5F6368), fontSize: 14),
          titleLarge: TextStyle(
            color: Color(0xFF202124),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5F6368)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ChatScreen(),
    ClientsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline, size: 26),
                  activeIcon: Icon(Icons.chat_bubble, size: 26),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline, size: 26),
                  activeIcon: Icon(Icons.people, size: 26),
                  label: 'Clientes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined, size: 26),
                  activeIcon: Icon(Icons.settings, size: 26),
                  label: 'Ajustes',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF4A90E2),
              unselectedItemColor: const Color(0xFF9AA0A6),
              onTap: _onItemTapped,
              showUnselectedLabels: false,
              showSelectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _commands = [
    {"icon": "📝", "command": "/documentos", "label": "Documentos"},
    {"icon": "🌐", "command": "/productos", "label": "Productos"},
    {"icon": "", "command": "/clientes-resientes", "label": "clientes"},
  ];
  bool _showCommands = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showCommands = _controller.text.startsWith('/');
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertCommand(String command) {
    setState(() {
      _controller.text = command + " ";
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      _showCommands = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.stars, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Smart Business Assistant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF202124),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF5F6368)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: const [
                ChatBubble(
                  text: '¡Hola! ¿En qué puedo ayudarte hoy?',
                  isMe: false,
                ),
                SizedBox(height: 12),
                ChatBubble(
                  text: 'Hola, necesito un resumen del último reporte.',
                  isMe: true,
                ),
              ],
            ),
          ),
          if (_showCommands)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _commands
                      .map(
                        (cmd) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Material(
                            color: const Color(0xFFF1F3F4),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _insertCommand(cmd['command']!),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      cmd['icon']!,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      cmd['label']!,
                                      style: const TextStyle(
                                        color: Color(0xFF202124),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF5F6368)),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Escribe tu mensaje...',
                    hintStyle: TextStyle(
                      color: Color(0xFF9AA0A6),
                      fontSize: 15,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  const ChatBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.stars, color: Colors.white, size: 18),
            ),
          ],
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFE3F2FD) : const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: const Color(0xFF202124),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  Future<void> _openWhatsApp(String phone) async {
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phone?text=Hola,%20te%20contacto%20desde%20la%20app.",
    );
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("No se pudo abrir WhatsApp.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> clients = [
      {'name': 'Juan Pérez', 'phone': '+521234567890'},
      {'name': 'Ana García', 'phone': '+529876543210'},
      {'name': 'Carlos Rodríguez', 'phone': '+525555555555'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clientes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF202124),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF5F6368)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF5F6368)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4A90E2).withOpacity(0.8),
                      Color(0xFF7C4DFF).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    client['name']![0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              title: Text(
                client['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202124),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  client['phone']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5F6368),
                  ),
                ),
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble),
                  color: const Color(0xFF25D366),
                  tooltip: 'Iniciar chat en WhatsApp',
                  onPressed: () => _openWhatsApp(client['phone']!),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 2,
        icon: const Icon(Icons.person_add),
        label: const Text(
          'Añadir cliente',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF202124),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            title: 'Cuenta',
            items: [
              _buildSettingsItem(
                icon: Icons.person_outline,
                title: 'Perfil',
                subtitle: 'Administra tu información personal',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                subtitle: 'Configura tus preferencias',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: 'Preferencias',
            items: [
              _buildSettingsItem(
                icon: Icons.palette_outlined,
                title: 'Tema',
                subtitle: 'Claro',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.language_outlined,
                title: 'Idioma',
                subtitle: 'Español',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: 'Acerca de',
            items: [
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'Versión',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.help_outline,
                title: 'Ayuda y soporte',
                subtitle: 'Obtén ayuda con la app',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A90E2),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF4A90E2), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF202124),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF5F6368)),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF9AA0A6),
      ),
      onTap: onTap,
    );
  }
}
