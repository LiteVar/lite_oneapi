import 'package:shelf/shelf.dart';
import '../../api/meta.dart';
import '../openai/adapter.dart';

class GLMAdapter extends OpenAIAdapter {
  @override
  String getRequestURL(Request request, Meta meta) {
    String urlPath = "/${request.url.path}";
    if (!meta.isCustomBaseUrl && urlPath.startsWith("/v1/")) {
      urlPath = urlPath.substring(3);
    }
    return buildRequestUrl(meta, urlPath);
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
