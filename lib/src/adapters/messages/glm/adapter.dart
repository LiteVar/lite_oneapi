import '../adapter.dart';

class GLMMessagesAdapter extends MessagesAdapter {
  @override
  String get endpointPath => '/api/anthropic/v1/messages';

  @override
  bool get replaceBasePath => true;
}
