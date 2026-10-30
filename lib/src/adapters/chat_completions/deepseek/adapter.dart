import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../exception.dart';
import '../../request_compatibility_patch.dart';
import '../../reasoning_compatibility.dart';
import '../../../define.dart';
import '../../../api/meta.dart';
import '../openai/adapter.dart';

class DeepSeekAdapter extends OpenAIAdapter {
  @override
  String get providerName => 'deepseek';

  @override
  void init(Meta meta) {
    if (meta.mode != RelayMode.ChatCompletions) return;

    final Map<String, dynamic> requestBody = jsonDecode(meta.requestBody);
    if (_usesBetaFeatures(requestBody) && !meta.baseUrl.endsWith("/beta")) {
      meta.baseUrl = "${meta.baseUrl}/beta";
    }
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
    ReasoningCompatibility.apply(
      body: data,
      provider: providerName,
      model: data['model'] as String? ?? '',
    );
    RequestCompatibilityPatch.applyReasoningContentReplayPatch(data);

    final dynamic rawMessages = data['messages'];
    if (rawMessages is! List) {
      throw UnsupportedRequestException('`messages` must be an array.');
    }
    data['messages'] = rawMessages.map((dynamic rawMessage) {
      if (rawMessage is! Map) {
        throw UnsupportedRequestException('Each message must be an object.');
      }
      final Map<String, dynamic> message =
          Map<String, dynamic>.from(rawMessage);
      if (message['role'] == 'developer') message['role'] = 'system';
      if (message.containsKey('content')) {
        message['content'] = _convertContent(message['content'], message);
      } else if (message['role'] != 'assistant' ||
          (message['tool_calls'] == null && message['function_call'] == null)) {
        throw UnsupportedRequestException(
          'Message content is required unless an assistant tool call is present.',
        );
      }
      return message;
    }).toList(growable: false);

    final dynamic maxTokens = data['max_tokens'];
    final dynamic maxCompletionTokens = data['max_completion_tokens'];
    if (maxTokens != null &&
        maxCompletionTokens != null &&
        maxTokens != maxCompletionTokens) {
      throw UnsupportedRequestException(
        '`max_tokens` conflicts with `max_completion_tokens`.',
      );
    }
    if (maxTokens == null && maxCompletionTokens != null) {
      data['max_tokens'] = maxCompletionTokens;
    }
    data.remove('max_completion_tokens');

    if (data['tools'] == null && data['functions'] is List) {
      data['tools'] = (data['functions'] as List).map((dynamic function) {
        if (function is! Map) {
          throw UnsupportedRequestException('Each function must be an object.');
        }
        return <String, dynamic>{
          'type': 'function',
          'function': Map<String, dynamic>.from(function),
        };
      }).toList(growable: false);
    }
    if (data['tool_choice'] == null && data['function_call'] != null) {
      final dynamic functionCall = data['function_call'];
      if (functionCall is Map) {
        data['tool_choice'] = <String, dynamic>{
          'type': 'function',
          'function': <String, dynamic>{'name': functionCall['name']},
        };
      } else {
        data['tool_choice'] = functionCall;
      }
    }
    data.remove('functions');
    data.remove('function_call');
    final dynamic responseFormat = data['response_format'];
    if (responseFormat is Map && responseFormat['type'] == 'json_schema') {
      throw UnsupportedRequestException(
        'DeepSeek Chat Completions supports `text` and `json_object` response formats, not `json_schema`.',
      );
    }
    return data;
  }

  bool _usesBetaFeatures(Map<String, dynamic> requestBody) {
    final dynamic messages = requestBody['messages'];
    if (messages is! List) return false;
    return messages.any((dynamic message) =>
        message is Map &&
        (message['prefix'] == true || message['reasoning_content'] != null));
  }

  dynamic _convertContent(dynamic content, Map<String, dynamic> message) {
    if (content == null &&
        message['role'] == 'assistant' &&
        (message['tool_calls'] != null || message['function_call'] != null)) {
      return null;
    }
    if (content is String) {
      return content;
    } else if (content is List<dynamic>) {
      for (final dynamic item in content) {
        if (item is! Map ||
            !const {'text', 'image_url'}.contains(item['type'])) {
          throw UnsupportedRequestException(
            'DeepSeek Chat Completions supports text and image_url content parts only.',
          );
        }
      }
      return content;
    } else {
      throw UnsupportedRequestException(
          "DeepSeek chat completions only supports text content messages.");
    }
  }
}
