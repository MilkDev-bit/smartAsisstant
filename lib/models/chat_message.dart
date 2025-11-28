class ChatMessage {
  final String message;
  final bool isUser;
  final String type;
  final dynamic data;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    this.type = 'text',
    this.data,
    DateTime? timestamp,
  }) : this.timestamp = timestamp ?? DateTime.now();
}
