import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'chat_service.dart';
import 'chat_message_model.dart';
import '../auth/auth_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showCommands = false;
  List<Map<String, String>> _commands = [];

  @override
  void initState() {
    super.initState();
    final userRole =
        Provider.of<AuthService>(context, listen: false).currentUser?.rol;
    _commands = _getCommandsForRole(userRole);
    _controller.addListener(_onTextChanged);
    Provider.of<ChatService>(context, listen: false)
        .addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    Provider.of<ChatService>(context, listen: false)
        .removeListener(_scrollToBottom);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTextChanged() {
    setState(() {
      _showCommands = _controller.text == '/';
    });
  }

  List<Map<String, String>> _getCommandsForRole(String? role) {
    switch (role) {
      case 'CLIENTE':
        return [
          {'icon': '🛒', 'label': 'Ver Menú', 'command': '/menu'},
          {
            'icon': '🚚',
            'label': 'Estatus de mi Pedido',
            'command': '/estatus-pedido'
          },
        ];
      case 'VENDEDOR':
        return [
          {'icon': '📦', 'label': 'Mis Entregas', 'command': '/mis-entregas'},
        ];
      case 'ADMIN':
        return [
          {
            'icon': '💰',
            'label': 'Reporte de Ventas',
            'command': '/reporte-ventas'
          },
          {'icon': '🍔', 'label': 'Top Productos', 'command': '/top-productos'},
          {
            'icon': '📈',
            'label': 'Top Vendedores',
            'command': '/top-vendedores'
          },
          {'icon': '👥', 'label': 'Ver Clientes', 'command': '/clientes'},
          {
            'icon': '📝',
            'label': 'Pedidos Pendientes',
            'command': '/pedidos-pendientes'
          },
        ];
      default:
        return [];
    }
  }

  void _onCommandTapped(String command) {
    _controller.text = command;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    setState(() {
      _showCommands = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'SmartAssistant Chat',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF4E5B8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
              tooltip: 'Nuevo Chat',
              onPressed: () {
                Provider.of<ChatService>(context, listen: false).clearChat();
                _controller.clear();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatService>(
              builder: (context, chatService, child) {
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: chatService.messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        chatService.messages.reversed.toList()[index];
                    return _ChatMessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          Consumer<ChatService>(
            builder: (context, chatService, child) {
              if (chatService.isLoading) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFF4E5B8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.stars,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'SmartAssistant está pensando...',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          if (_showCommands && _commands.isNotEmpty) _buildCommandList(),
          const Divider(height: 1.0, color: Color(0xFFE8E8E8)),
          _ChatInput(controller: _controller, onSend: _scrollToBottom),
        ],
      ),
    );
  }

  Widget _buildCommandList() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: _commands.length,
        itemBuilder: (context, index) {
          final cmd = _commands[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ActionChip(
              avatar: Text(cmd['icon']!, style: const TextStyle(fontSize: 16)),
              label: Text(cmd['label']!),
              onPressed: () => _onCommandTapped(cmd['command']!),
              backgroundColor: const Color(0xFFFFFBF0),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
              labelStyle: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 10.0),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFF4E5B8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.stars,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFFFFFBF0) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              border: isUser
                  ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: MarkdownBody(
              data: message.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF1A1A1A),
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
                em: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF1A1A1A),
                ),
                tableHead: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
                tableBody: const TextStyle(color: Color(0xFF1A1A1A)),
                tableBorder: TableBorder.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
                tableCellsPadding: const EdgeInsets.all(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  void _sendMessage() {
    if (widget.controller.text.trim().isEmpty) return;
    Provider.of<ChatService>(context, listen: false)
        .sendMessage(widget.controller.text);
    widget.controller.clear();
    FocusScope.of(context).unfocus();
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                    ),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Escribe tu mensaje o / para comandos...',
                      hintStyle: TextStyle(color: Color(0xFF999999)),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFF4E5B8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
