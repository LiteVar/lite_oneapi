import '../exception.dart';

/// An Anthropic Messages request kept independent from the OpenAI protocols.
/// Unknown fields are preserved for provider-specific Anthropic extensions.
class MessagesRequest {
  final Map<String, dynamic> fields;

  const MessagesRequest(this.fields);

  factory MessagesRequest.fromJson(Map<String, dynamic> json) {
    final dynamic model = json['model'];
    if (model is! String || model.isEmpty) {
      throw UnsupportedRequestException('`model` must be a non-empty string.');
    }
    final dynamic messages = json['messages'];
    if (messages is! List || messages.isEmpty) {
      throw UnsupportedRequestException(
        '`messages` must be a non-empty array for Messages.',
      );
    }
    for (final dynamic message in messages) {
      if (message is! Map ||
          !const {'user', 'assistant'}.contains(message['role'])) {
        throw UnsupportedRequestException(
          'Each Messages item must have a `user` or `assistant` role.',
        );
      }
      if (!message.containsKey('content')) {
        throw UnsupportedRequestException(
          'Each Messages item must include `content`.',
        );
      }
    }
    final dynamic maxTokens = json['max_tokens'];
    if (maxTokens is! int || maxTokens <= 0) {
      throw UnsupportedRequestException(
        '`max_tokens` must be a positive integer for Messages.',
      );
    }
    if (json['system'] != null &&
        json['system'] is! String &&
        json['system'] is! List) {
      throw UnsupportedRequestException(
        '`system` must be a string or an array of content blocks.',
      );
    }
    if (json['stream'] != null && json['stream'] is! bool) {
      throw UnsupportedRequestException('`stream` must be a boolean.');
    }
    if (json['tools'] != null && json['tools'] is! List) {
      throw UnsupportedRequestException('`tools` must be an array.');
    }
    return MessagesRequest(Map<String, dynamic>.from(json));
  }

  String get model => fields['model'] as String;
  bool get stream => fields['stream'] == true;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(fields);
}
