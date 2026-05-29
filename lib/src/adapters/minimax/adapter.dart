import 'package:shelf/shelf.dart';
import '../../api/meta.dart';
import '../openai/adapter.dart';

class MiniMaxAdapter extends OpenAIAdapter {
  @override
  Map<String, String> setupRequestHeaders(Request request, Meta meta) {
    Map<String, String> headers = {};
    headers.addAll(request.headers);
    headers["Accept"] = meta.isStream ? "text/event-stream" : "application/json";
    return headers;
  }
}
