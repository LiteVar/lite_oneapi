import '../adapter.dart';

class MiniMaxMessagesAdapter extends MessagesAdapter {
  @override
  String get endpointPath => '/anthropic/v1/messages';

  @override
  bool get replaceBasePath => true;
}
