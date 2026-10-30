import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../exception.dart';
import '../reasoning_compatibility.dart';
import '../../api/meta.dart';
import '../../define.dart';
import '../openai/adapter.dart';

class QwenAdapter extends OpenAIAdapter {
  @override
  String get providerName => 'qwen';

  @override
  String getRequestURL(Request request, Meta meta) {
    /// "/v1/chat/completions" to "/compatible-mode/v1/chat/completions"
    String urlPath = meta.isCustomBaseUrl
        ? "/${request.url.path}"
        : "/compatible-mode/${request.url.path}";
    return buildRequestUrl(meta, urlPath);
  }

  @override
  Map<String, String> setupRequestHeaders(Request request, Meta meta) {
    final Map<String, String> headers =
        super.setupRequestHeaders(request, meta);
    if (meta.isStream) {
      headers['X-DashScope-SSE'] = 'enable';
    }
    return headers;
  }

  @override
  Future<Map<String, dynamic>> convertRequest(
      Request request, Meta meta) async {
    Map<String, dynamic> data = jsonDecode(meta.requestBody);

    if (meta.mode == RelayMode.ChatCompletions) {
      return _relayChatCompletions(data);
    }
    return data;
  }

  Map<String, dynamic> _relayChatCompletions(Map<String, dynamic> data) {
    final Map<String, dynamic> requestBody = Map<String, dynamic>.from(data);
    ReasoningCompatibility.apply(
      body: requestBody,
      provider: providerName,
      model: data['model'] as String? ?? '',
    );

    final dynamic rawMessages = requestBody['messages'];
    if (rawMessages is! List) {
      throw UnsupportedRequestException('`messages` must be an array.');
    }
    requestBody['messages'] = rawMessages.map((dynamic rawMessage) {
      if (rawMessage is! Map) {
        throw UnsupportedRequestException('Each message must be an object.');
      }
      final Map<String, dynamic> message =
          Map<String, dynamic>.from(rawMessage);
      if (message['role'] == 'developer') message['role'] = 'system';
      return message;
    }).toList(growable: false);

    final dynamic maxTokens = requestBody['max_tokens'];
    final dynamic maxCompletionTokens = requestBody['max_completion_tokens'];
    if (maxTokens != null &&
        maxCompletionTokens != null &&
        maxTokens != maxCompletionTokens) {
      throw UnsupportedRequestException(
        '`max_tokens` conflicts with `max_completion_tokens`.',
      );
    }
    final bool supportsMaxCompletionTokens =
        _supportsMaxCompletionTokens(requestBody['model'] as String? ?? '');
    if (maxCompletionTokens != null) {
      if (supportsMaxCompletionTokens) {
        requestBody.remove('max_tokens');
      } else {
        if (maxTokens == null) requestBody['max_tokens'] = maxCompletionTokens;
        requestBody.remove('max_completion_tokens');
      }
    }

    if (requestBody['enable_search'] == null &&
        requestBody['web_search_options'] != null) {
      requestBody['enable_search'] = true;
    }

    if (requestBody['tools'] == null && requestBody['functions'] is List) {
      requestBody['tools'] =
          (requestBody['functions'] as List).map((dynamic function) {
        if (function is! Map) {
          throw UnsupportedRequestException('Each function must be an object.');
        }
        return <String, dynamic>{
          'type': 'function',
          'function': Map<String, dynamic>.from(function),
        };
      }).toList(growable: false);
    }

    if (requestBody['tool_choice'] == null &&
        requestBody['function_call'] != null) {
      requestBody['tool_choice'] =
          _convertDeprecatedFunctionCall(requestBody['function_call']);
    }

    requestBody.remove('functions');
    requestBody.remove('function_call');
    requestBody.remove('web_search_options');

    return requestBody;
  }

  dynamic _convertDeprecatedFunctionCall(dynamic functionCall) {
    if (functionCall is String) {
      return functionCall;
    } else if (functionCall is Map) {
      return {
        "type": "function",
        "function": {
          "name": functionCall['name'],
        }
      };
    }
    return functionCall;
  }

  bool _supportsMaxCompletionTokens(String model) =>
      RegExp(r'^qwen3\.(?:[5-9]|\d{2,})').hasMatch(model.toLowerCase());
}
