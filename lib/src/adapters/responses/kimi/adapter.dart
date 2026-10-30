import '../adapter.dart';

class KimiResponsesAdapter extends ResponsesAdapter {
  @override
  String get endpointPath => '/responses';

  @override
  String get hostOverride => 'api.moonshot.ai';
}
