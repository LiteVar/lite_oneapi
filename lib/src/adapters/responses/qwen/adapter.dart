import '../adapter.dart';

class QwenResponsesAdapter extends ResponsesAdapter {
  @override
  String get endpointPath => '/compatible-mode/v1/responses';

  @override
  bool get enableDashscopeSseHeader => true;
}
