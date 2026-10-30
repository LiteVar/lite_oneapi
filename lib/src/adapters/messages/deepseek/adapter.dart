import '../adapter.dart';

class DeepSeekMessagesAdapter extends MessagesAdapter {
  @override
  String get endpointPath => '/anthropic/v1/messages';
}
