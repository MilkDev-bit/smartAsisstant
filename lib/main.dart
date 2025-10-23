import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

void main() {
  runApp(const IaChatApp());
}

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isLoading;

  ChatMessage({required this.text, required this.isMe, this.isLoading = false});
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

  final List<Map<String, String>> _clients = [
    {'name': 'Juan Pérez', 'phone': '+521234567890'},
    {'name': 'Ana García', 'phone': '+529876543210'},
    {'name': 'Carlos Rodríguez', 'phone': '+525555555555'},
  ];

  final List<ChatMessage> _messages = [
    ChatMessage(text: '¡Hola! ¿En qué puedo ayudarte hoy?', isMe: false),
  ];

  void _addClient(String name, String phone) {
    setState(() {
      _clients.add({'name': name, 'phone': phone});
    });
  }

  String _getSimulatedResponse(String inputText) {
    String text = inputText.toLowerCase().trim();

    if (text.startsWith('/documentos')) {
      return '¡Claro! He encontrado 3 documentos que coinciden con tu solicitud:\n\n'
          '1. *Reporte_Ventas_Q3_2025.pdf*\n   (Modificado: 22/10/2025)\n'
          '2. *Factura_Cliente_A_Octubre.pdf*\n   (Modificado: 21/10/2025)\n'
          '3. *Contrato_Proveedor_B_Firmado.docx*\n   (Modificado: 19/10/2025)';
    } else if (text.startsWith('/productos')) {
      return '¡Perfecto! Aquí está el inventario y precios de tus productos principales:\n\n'
          '1. *Clásica (ID: HAM-001)*\n   - Stock: 200 carnes, 180 panes\n   - Precio: \$120.00 MXN\n'
          '2. *Doble Queso (ID: HAM-002)*\n   - Stock: 150 carnes, 140 panes\n   - Precio: \$160.00 MXN\n'
          '3. *Papas Gajo (ID: PAP-001)*\n   - Stock: 80 porciones (¡Quedan pocas!)\n   - Precio: \$65.00 MXN';
    } else if (text.startsWith('/clientes-recientes')) {
      if (_clients.isEmpty) {
        return 'Actualmente no tienes clientes registrados.';
      }
      String clientList = 'Estos son tus clientes más recientes:\n\n';
      int count = _clients.length > 3 ? 3 : _clients.length;
      for (int i = 0; i < count; i++) {
        clientList +=
            '- *${_clients[_clients.length - 1 - i]['name']}* (${_clients[_clients.length - 1 - i]['phone']})\n';
      }
      return clientList;
    } else if (text.contains('hola') || text.contains('buenos dias')) {
      return '¡Hola! Soy tu asistente. ¿En qué puedo ayudarte hoy?\nPuedes usar comandos como `/documentos` o `/productos`.';
    } else if (text.contains('gracias') || text.contains('muchas gracias')) {
      return '¡De nada! Estoy aquí para ayudarte. ¿Necesitas algo más?';
    } else {
      return 'He procesado tu solicitud sobre "$inputText".\n\nComo soy una simulación, no puedo completar esta tarea específica, pero en la versión final, aquí verías el resultado.';
    }
  }

  Future<void> _handleSendPressed(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
    });

    setState(() {
      _messages.add(ChatMessage(text: "...", isMe: false, isLoading: true));
    });

    await Future.delayed(const Duration(seconds: 2));

    final String responseText = _getSimulatedResponse(text);

    setState(() {
      _messages.removeWhere((msg) => msg.isLoading);
      _messages.add(ChatMessage(text: responseText, isMe: false));
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessage(
          text: 'He limpiado el chat. ¿Cómo puedo ayudarte ahora?',
          isMe: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      ChatScreen(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        onClearChat: _clearChat,
      ),
      ClientsScreen(clients: _clients, onAddClient: _addClient),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),
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
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
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
  final List<ChatMessage> messages;
  final Function(String) onSendPressed;
  final VoidCallback onClearChat;

  const ChatScreen({
    super.key,
    required this.messages,
    required this.onSendPressed,
    required this.onClearChat,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _commands = [
    {"icon": "📝", "command": "/documentos", "label": "Documentos"},
    {"icon": "🌐", "command": "/productos", "label": "Productos"},
    {"icon": "👤", "command": "/clientes-recientes", "label": "Clientes"},
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
    _scrollController.dispose();
    super.dispose();
  }

  void _insertCommand(String command) {
    setState(() {
      _controller.text = "$command ";
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      _showCommands = false;
    });
  }

  void _handleSendPressed() {
    final text = _controller.text;
    if (text.isEmpty) return;
    widget.onSendPressed(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.add_comment_outlined,
                    color: Color(0xFF4A90E2),
                  ),
                  title: const Text(
                    'Nuevo Chat',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onClearChat();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.attach_file,
                    color: Color(0xFF5F6368),
                  ),
                  title: const Text(
                    'Adjuntar Archivo (Simulado)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showPlaceholderDialog(context, "Adjuntar Archivo");
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF5F6368),
                  ),
                  title: const Text(
                    'Tomar Foto (Simulado)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showPlaceholderDialog(context, "Tomar Foto");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlaceholderDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text('Aquí se implementaría la lógica para "$title".'),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToBottom();
      }
    });

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
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ChatBubble(
                    text: message.text,
                    isMe: message.isMe,
                    isLoading: message.isLoading,
                  ),
                );
              },
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
                onPressed: _showOptionsBottomSheet,
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
                  onSubmitted: (_) => _handleSendPressed(),
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
                onPressed: _handleSendPressed,
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
  final bool isLoading;
  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.isLoading = false,
  });

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
              child: isLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Cargando...',
                          style: TextStyle(
                            color: Color(0xFF5F6368),
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        color: Color(0xFF202124),
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
  final List<Map<String, String>> clients;
  final Function(String, String) onAddClient;

  const ClientsScreen({
    super.key,
    required this.clients,
    required this.onAddClient,
  });

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

  Future<void> _showAddClientDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Añadir nuevo cliente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Nombre del cliente",
                ),
                autofocus: true,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  hintText: "Teléfono (ej: +52...)",
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Añadir'),
              onPressed: () {
                final name = nameController.text;
                final phone = phoneController.text;
                if (name.isNotEmpty && phone.isNotEmpty) {
                  onAddClient(name, phone);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      const Color(0xFF4A90E2).withOpacity(0.8),
                      const Color(0xFF7C4DFF).withOpacity(0.8),
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
        onPressed: () => _showAddClientDialog(context),
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

  void _showPlaceholderDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text('Aquí se administraría la sección de "$title".'),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
            context: context,
            title: 'Cuenta',
            items: [
              _buildSettingsItem(
                icon: Icons.person_outline,
                title: 'Perfil',
                subtitle: 'Administra tu información personal',
                onTap: () => _showPlaceholderDialog(context, 'Perfil'),
              ),
              _buildSettingsItem(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                subtitle: 'Configura tus preferencias',
                onTap: () => _showPlaceholderDialog(context, 'Notificaciones'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context: context,
            title: 'Preferencias',
            items: [
              _buildSettingsItem(
                icon: Icons.palette_outlined,
                title: 'Tema',
                subtitle: 'Claro',
                onTap: () => _showPlaceholderDialog(context, 'Tema'),
              ),
              _buildSettingsItem(
                icon: Icons.language_outlined,
                title: 'Idioma',
                subtitle: 'Español',
                onTap: () => _showPlaceholderDialog(context, 'Idioma'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context: context,
            title: 'Acerca de',
            items: [
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'Versión',
                subtitle: '1.0.0',
                onTap: () => _showPlaceholderDialog(context, 'Versión'),
              ),
              _buildSettingsItem(
                icon: Icons.help_outline,
                title: 'Ayuda y soporte',
                subtitle: 'Obtén ayuda con la app',
                onTap: () => _showPlaceholderDialog(context, 'Ayuda y soporte'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
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
