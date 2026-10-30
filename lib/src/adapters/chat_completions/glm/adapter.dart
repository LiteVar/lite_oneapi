import 'package:shelf/shelf.dart';
import '../../../api/meta.dart';
import '../../../define.dart';
import '../openai/adapter.dart';
import '../../exception.dart';

class GLMAdapter extends OpenAIAdapter {
  @override
  String get providerName => 'glm';

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

  @override
  Future<Map<String, dynamic>> convertRequest(
      Request request, Meta meta) async {
    final Map<String, dynamic> body = await super.convertRequest(request, meta);
    if (meta.mode != RelayMode.ChatCompletions) return body;

    final dynamic maxTokens = body['max_tokens'];
    final dynamic maxCompletionTokens = body['max_completion_tokens'];
    if (maxTokens != null &&
        maxCompletionTokens != null &&
        maxTokens != maxCompletionTokens) {
      throw UnsupportedRequestException(
        '`max_tokens` conflicts with `max_completion_tokens`.',
      );
    }
    if (maxTokens == null && maxCompletionTokens != null) {
      body['max_tokens'] = maxCompletionTokens;
    }
    body.remove('max_completion_tokens');

    final dynamic stop = body['stop'];
    if (stop is String) {
      body['stop'] = <String>[stop];
    } else if (stop != null && stop is! List) {
      throw UnsupportedRequestException(
        '`stop` must be a string or an array of strings.',
      );
    }
    if (stop is List &&
        (stop.length > 4 || stop.any((dynamic item) => item is! String))) {
      throw UnsupportedRequestException(
        '`stop` must contain no more than four strings.',
      );
    }

    final dynamic messages = body['messages'];
    if (messages is List) {
      body['messages'] = messages.map((dynamic rawMessage) {
        if (rawMessage is! Map) return rawMessage;
        final Map<String, dynamic> message =
            Map<String, dynamic>.from(rawMessage);
        if (message['role'] == 'developer') message['role'] = 'system';
        return message;
      }).toList(growable: false);
    }

    if (body['tools'] == null && body['functions'] is List) {
      body['tools'] = (body['functions'] as List).map((dynamic function) {
        if (function is! Map) {
          throw UnsupportedRequestException('Each function must be an object.');
        }
        return <String, dynamic>{
          'type': 'function',
          'function': Map<String, dynamic>.from(function),
        };
      }).toList(growable: false);
    }
    if (body['tool_choice'] == null && body['function_call'] != null) {
      final dynamic functionCall = body['function_call'];
      if (functionCall is Map) {
        body['tool_choice'] = <String, dynamic>{
          'type': 'function',
          'function': <String, dynamic>{'name': functionCall['name']},
        };
      } else {
        body['tool_choice'] = functionCall;
      }
    }
    body.remove('functions');
    body.remove('function_call');

    final dynamic toolChoice = body['tool_choice'];
    if (toolChoice == 'none') {
      body.remove('tools');
      body.remove('tool_choice');
    } else if (toolChoice != null && toolChoice != 'auto') {
      throw UnsupportedRequestException(
        'GLM Chat Completions only supports `tool_choice: auto`.',
      );
    }

    final dynamic responseFormat = body['response_format'];
    if (responseFormat is Map && responseFormat['type'] == 'json_schema') {
      throw UnsupportedRequestException(
        'GLM Chat Completions supports `text` and `json_object` response formats, not `json_schema`.',
      );
    }

    return body;
  }
}
