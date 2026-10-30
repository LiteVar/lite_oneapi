import 'dart:convert';

import 'package:lite_oneapi/src/adapters/chat_completions/deepseek/adapter.dart';
import 'package:lite_oneapi/src/adapters/exception.dart';
import 'package:lite_oneapi/src/adapters/chat_completions/glm/adapter.dart';
import 'package:lite_oneapi/src/adapters/chat_completions/kimi/adapter.dart';
import 'package:lite_oneapi/src/adapters/chat_completions/mimo/adapter.dart';
import 'package:lite_oneapi/src/adapters/chat_completions/minimax/adapter.dart';
import 'package:lite_oneapi/src/adapters/chat_completions/openai/adapter.dart';
import 'package:lite_oneapi/src/adapters/chat_completions/openai/model/chat_completions_request.dart';
import 'package:lite_oneapi/src/adapters/chat_completions/qwen/adapter.dart';
import 'package:lite_oneapi/src/adapters/reasoning_compatibility.dart';
import 'package:lite_oneapi/src/core/gateway_service.dart';
import 'package:lite_oneapi/src/api/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('reasoning controls', () {
    test(
        'Qwen 3.8 maps effort to its supported level and preserves JSON schema',
        () async {
      final Map<String, dynamic> body = await QwenAdapter().convertRequest(
        _request(),
        _meta('qwen3.8-max', {
          'reasoning_effort': 'high',
          'response_format': {
            'type': 'json_schema',
            'json_schema': {
              'name': 'answer',
              'schema': {
                'type': 'object',
                'properties': {
                  'ok': {'type': 'boolean'}
                }
              },
            },
          },
          'messages': [
            {
              'role': 'assistant',
              'content': 'prior',
              'reasoning_content': 'kept'
            },
          ],
        }),
      );

      expect(body['reasoning_effort'], 'xhigh');
      expect(body.containsKey('enable_thinking'), isFalse);
      expect(body['response_format']['type'], 'json_schema');
      expect(body['messages'][0]['reasoning_content'], 'kept');
    });

    test('Qwen maps reasoning_effort none to disabling thinking', () async {
      final Map<String, dynamic> body = await QwenAdapter().convertRequest(
        _request(),
        _meta('qwen3.8-flash', {'reasoning_effort': 'none'}),
      );

      expect(body['enable_thinking'], isFalse);
      expect(body.containsKey('reasoning_effort'), isFalse);
    });

    test('Qwen older models map effort to the boolean switch', () async {
      final Map<String, dynamic> body = await QwenAdapter().convertRequest(
        _request(),
        _meta('qwen3-max', {'reasoning_effort': 'high'}),
      );

      expect(body['enable_thinking'], isTrue);
      expect(body.containsKey('reasoning_effort'), isFalse);
    });

    test('Qwen translates thinking keep into preserve_thinking', () async {
      final Map<String, dynamic> body = await QwenAdapter().convertRequest(
        _request(),
        _meta('qwen3.8-max', {
          'thinking': {'type': 'enabled', 'keep': 'all'},
        }),
      );

      expect(body['enable_thinking'], isTrue);
      expect(body['preserve_thinking'], isTrue);
      expect(body.containsKey('thinking'), isFalse);
    });

    test('conflicting canonical and alias controls return a request error', () {
      expect(
        () => ReasoningCompatibility.apply(
          body: {
            'reasoning_effort': 'high',
            'enable_thinking': false,
          },
          provider: 'qwen',
          model: 'qwen3.8-max',
        ),
        throwsA(isA<UnsupportedRequestException>()),
      );
    });

    test('GLM 5.1 maps effort to a thinking switch', () async {
      final Map<String, dynamic> body = await GLMAdapter().convertRequest(
        _request(),
        _meta('glm-5.1', {'reasoning_effort': 'high'}),
      );
      expect(body.containsKey('reasoning_effort'), isFalse);
      expect(body['thinking']['type'], 'enabled');
    });

    test('GLM 5.3 maps medium to a supported effort level', () async {
      final Map<String, dynamic> body = await GLMAdapter().convertRequest(
        _request(),
        _meta('glm-5.3', {'reasoning_effort': 'medium'}),
      );
      expect(body['reasoning_effort'], 'high');
    });

    test('GLM 5.3 rejects disabling its always-on thinking', () {
      expect(
        () => ReasoningCompatibility.apply(
          body: {'reasoning_effort': 'none'},
          provider: 'glm',
          model: 'glm-5.3-flash',
        ),
        throwsA(isA<UnsupportedRequestException>()),
      );
    });

    test('GLM maps standard token limit, stop, and developer role fields',
        () async {
      final Map<String, dynamic> body = await GLMAdapter().convertRequest(
        _request(),
        _meta('glm-5.3', {
          'max_completion_tokens': 80,
          'stop': 'END',
          'messages': [
            {'role': 'developer', 'content': 'Be concise.'},
          ],
        }),
      );

      expect(body['max_tokens'], 80);
      expect(body.containsKey('max_completion_tokens'), isFalse);
      expect(body['stop'], ['END']);
      expect(body['messages'][0]['role'], 'system');
    });

    test('GLM rejects response schemas its API does not support', () async {
      await expectLater(
        GLMAdapter().convertRequest(
          _request(),
          _meta('glm-5.3', {
            'response_format': {
              'type': 'json_schema',
              'json_schema': {
                'name': 'answer',
                'schema': {'type': 'object'}
              },
            },
          }),
        ),
        throwsA(isA<UnsupportedRequestException>()),
      );
    });

    test('Kimi K2.6 maps effort to its binary switch', () async {
      final Map<String, dynamic> body = await KimiAdapter().convertRequest(
        _request(),
        _meta('kimi-k2.6', {'reasoning_effort': 'low'}),
      );
      expect(body.containsKey('reasoning_effort'), isFalse);
      expect(body['thinking']['type'], 'enabled');
    });

    test('OpenAI maps enable_thinking false to reasoning_effort none',
        () async {
      final Map<String, dynamic> body = await OpenAIAdapter().convertRequest(
        _request(),
        _meta('gpt-5.5', {'enable_thinking': false}),
      );
      expect(body['reasoning_effort'], 'none');
      expect(body.containsKey('enable_thinking'), isFalse);
    });

    test('MiniMax rejects disabling thinking on M2.x', () {
      expect(
        () => ReasoningCompatibility.apply(
          body: {'enable_thinking': false},
          provider: 'minimax',
          model: 'MiniMax-M2.7',
        ),
        throwsA(isA<UnsupportedRequestException>()),
      );
    });

    test('MiniMax M3.1-Flash sends only its documented effort control',
        () async {
      final Map<String, dynamic> body = await MiniMaxAdapter().convertRequest(
        _request(),
        _meta('MiniMax-M3.1-Flash', {'reasoning_effort': 'high'}),
      );

      expect(body['reasoning_effort'], 'high');
      expect(body.containsKey('thinking'), isFalse);
    });

    test('MiMo uses its documented api-key header and raw key format', () {
      final MimoAdapter adapter = MimoAdapter();
      expect(adapter.apiKeyHeaderName, 'api-key');
      expect(adapter.formatOriginalApiKey('Bearer sk-test'), 'sk-test');
    });
  });

  group('OpenAI request schema', () {
    test('fractional penalties survive decoding and serialization', () {
      final ChatCompletionRequest request = ChatCompletionRequest.fromJson({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'user', 'content': 'hello'},
        ],
        'frequency_penalty': 0.25,
        'presence_penalty': -0.5,
      });

      expect(request.toJson()['frequency_penalty'], 0.25);
      expect(request.toJson()['presence_penalty'], -0.5);
    });

    test('gateway returns a standard error object for invalid JSON', () async {
      final Response response =
          await LiteOneApiGatewayService().handleJsonRequest(
        payload: '{',
        requestPath: '/v1/chat/completions',
        requestHeaders: const <String, String>{},
      );

      expect(response.statusCode, 400);
      expect(response.headers['content-type'], 'application/json');
      expect(
        jsonDecode(await response.readAsString())['error']['code'],
        'invalid_json',
      );
    });

    test('gateway rejects a nonstandard chat message role', () async {
      final Response response =
          await LiteOneApiGatewayService().handleJsonRequest(
        payload: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'bogus', 'content': 'hello'},
          ],
        }),
        requestPath: '/v1/chat/completions',
        requestHeaders: const <String, String>{},
      );

      expect(response.statusCode, 400);
      expect(
        jsonDecode(await response.readAsString())['error']['type'],
        'invalid_request_error',
      );
    });

    test('DeepSeek preserves named tool choice and null tool-call content',
        () async {
      final Map<String, dynamic> body = await DeepSeekAdapter().convertRequest(
        _request(),
        _meta('deepseek-v4-pro', {
          'frequency_penalty': 0.25,
          'max_completion_tokens': 80,
          'tool_choice': {
            'type': 'function',
            'function': {'name': 'lookup'},
          },
          'messages': [
            {
              'role': 'assistant',
              'content': null,
              'tool_calls': [
                {
                  'id': 'call_1',
                  'type': 'function',
                  'function': {'name': 'lookup', 'arguments': '{}'},
                },
              ],
            },
          ],
        }),
      );

      expect(body['frequency_penalty'], 0.25);
      expect(body['max_tokens'], 80);
      expect(body.containsKey('max_completion_tokens'), isFalse);
      expect(body['tool_choice']['function']['name'], 'lookup');
      expect(body['messages'][0]['content'], isNull);
      expect(body['messages'][0]['reasoning_content'], '');
      expect(body['reasoning_effort'], 'none');
    });
  });
}

Request _request() =>
    Request('POST', Uri.parse('http://localhost/v1/chat/completions'));

Meta _meta(String model, Map<String, dynamic> extra) => initRelayMode(
      Meta(
        model: model,
        isStream: false,
        requestBody: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': 'hello'},
          ],
          ...extra,
        }),
      ),
      'v1/chat/completions',
    );
