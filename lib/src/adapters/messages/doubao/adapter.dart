import '../adapter.dart';

class DoubaoMessagesAdapter extends MessagesAdapter {
  @override
  String get endpointPath => '/api/compatible/v1/messages';

  @override
  bool get replaceBasePath => true;
}
