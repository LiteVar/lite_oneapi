import '../adapter.dart';

class QwenMessagesAdapter extends MessagesAdapter {
  @override
  String get endpointPath => '/apps/anthropic/v1/messages';
}
