import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:smartassistant_vendedor/models/chat_message.dart';
import 'package:smartassistant_vendedor/services/api_service.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';

class ChatProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final ApiService _api = ApiService();
  final ScrollController scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider(this._authProvider) {
    _messages.add(ChatMessage(
      message:
          'Hola, soy tu asistente inteligente. ¿En qué puedo ayudarte hoy? \n\nPuedes preguntarme por "mis tareas", "reporte de ventas", "buscar un coche" o "cotizaciones pendientes".',
      isUser: false,
    ));
  }

  String? get _token => _authProvider.token;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _token == null) return;

    _messages.add(ChatMessage(message: text, isUser: true));
    _isLoading = true;
    notifyListeners();
    _scrollToBottom();

    try {
      final body = json.encode({'prompt': text});
      final response = await _api.post('iamodel/query', _token!, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);

        _messages.add(ChatMessage(
          message: data['message'] ?? '',
          isUser: false,
          type: data['type'] ?? 'text',
          data: data['data'],
        ));
      } else {
        _messages.add(ChatMessage(
          message:
              'Lo siento, tuve un problema de conexión (${response.statusCode}).',
          isUser: false,
        ));
      }
    } catch (e) {
      _messages.add(ChatMessage(
        message: 'Error de conexión: $e',
        isUser: false,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage(
      message:
          'Hola, soy tu asistente inteligente. ¿En qué puedo ayudarte hoy?',
      isUser: false,
    ));
    notifyListeners();
  }
}
