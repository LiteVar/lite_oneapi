import 'package:shelf/shelf.dart';

import '../../../api/meta.dart';
import '../openai/adapter.dart';

/// Anthropic's documented OpenAI SDK-compatible Chat Completions endpoint.
class AnthropicChatCompletionsAdapter extends OpenAIAdapter {
  @override
  String get providerName => 'anthropic';

  @override
  String getRequestURL(Request request, Meta meta) {
    final String path = meta.endpoint ?? '/${request.url.path}';
    return buildRequestUrl(meta, path);
  }
}
