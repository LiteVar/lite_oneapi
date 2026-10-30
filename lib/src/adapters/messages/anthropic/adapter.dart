import '../adapter.dart';

class AnthropicMessagesAdapter extends MessagesAdapter {
  @override
  String get endpointPath => '/v1/messages';
}
