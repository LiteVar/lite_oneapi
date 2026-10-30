import '../adapter.dart';

class KimiMessagesAdapter extends MessagesAdapter {
  @override
  String get endpointPath => '/anthropic/v1/messages';

  @override
  bool get replaceBasePath => true;

  @override
  String get hostOverride => 'api.moonshot.ai';

  @override
  bool get usesBearerAuthorization => true;
}
