import '../adapter.dart';

class OpenAIResponsesAdapter extends ResponsesAdapter {
  @override
  String get endpointPath => '/v1/responses';
}
