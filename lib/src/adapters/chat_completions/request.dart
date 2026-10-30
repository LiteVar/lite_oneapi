import '../exception.dart';

/// An OpenAI Chat Completions request kept independent from Responses and
/// Anthropic Messages. Unknown fields remain available to provider adapters.
class ChatCompletionsRequest {
  final Map<String, dynamic> fields;

  const ChatCompletionsRequest(this.fields);

  factory ChatCompletionsRequest.fromJson(Map<String, dynamic> json) {
    final dynamic messages = json['messages'];
    if (messages is! List || messages.isEmpty) {
      throw UnsupportedRequestException(
        '`messages` must be a non-empty array for chat completions.',
      );
    }
    for (final dynamic message in messages) {
      if (message is! Map ||
          !const {
            'system',
            'developer',
            'user',
            'assistant',
            'tool',
            'function',
          }.contains(message['role'])) {
        throw UnsupportedRequestException(
          'Each chat message must have a supported string `role`.',
        );
      }
    }
    return ChatCompletionsRequest(Map<String, dynamic>.from(json));
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(fields);
}
