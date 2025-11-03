import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/api_service.dart';
import 'chat_message_model.dart';
import '../auth/auth_service.dart';

class ChatService extends ChangeNotifier {
  final ApiService _api;
  final AuthService? _auth;

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatService(this._auth, this._api) {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final userName = _auth?.currentUser?.nombre.split(' ')[0] ?? 'Usuario';
    _messages.add(ChatMessage(
      content:
          '¡Hola $userName! Soy SmartAssistant. ¿En qué puedo ayudarte hoy?',
      isUser: false,
    ));
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  Future<void> sendMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    _messages.add(ChatMessage(content: prompt, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.dio.post(
        '/ia-chat',
        data: {'prompt': prompt},
      );

      final String assistantResponse =
          response.data['content'] ?? 'No se recibió respuesta.';
      _messages.add(ChatMessage(content: assistantResponse, isUser: false));
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? e.message ?? 'Error de red';
      _messages.add(ChatMessage(
        content: 'Lo siento, no pude procesar tu solicitud: $errorMessage',
        isUser: false,
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        content: 'Lo siento, ocurrió un error inesperado.',
        isUser: false,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
