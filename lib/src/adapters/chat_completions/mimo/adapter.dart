import 'package:shelf/shelf.dart';
import '../../../model.dart';
import '../../../api/meta.dart';
import '../openai/adapter.dart';

class MimoAdapter extends OpenAIAdapter {
  @override
  String get providerName => 'mimo';

  @override
  String get apiKeyHeaderName => 'api-key';

  @override
  String formatAdapterApiKey(ApiKeyType type, String apiKey) => apiKey;

  @override
  String formatOriginalApiKey(String value) {
    final String trimmed = value.trim();
    if (trimmed.toLowerCase().startsWith('bearer ')) {
      return trimmed.substring(7).trim();
    }
    return trimmed;
  }

  @override
  Map<String, String> setupRequestHeaders(Request request, Meta meta) {
    Map<String, String> headers = {};
    headers.addAll(request.headers);
    headers["Accept"] =
        meta.isStream ? "text/event-stream" : "application/json";
    return headers;
  }
}
