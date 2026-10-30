import 'dart:convert';

import 'package:lite_oneapi/src/adapters/chat_completions/deepseek/adapter.dart';
import 'package:lite_oneapi/src/adapters/chat_completions/mimo/adapter.dart';
import 'package:lite_oneapi/src/adapters/chat_completions/openai/adapter.dart';
import 'package:lite_oneapi/src/api/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('provider-specific reasoning_content replay patch', () {
    test('deepseek-v4-flash injects empty reasoning_content for assistant tool_calls', () async {
      final DeepSeekAdapter adapter = DeepSeekAdapter();
      final Meta meta = initRelayMode(
        Meta(
          model: 'deepseek-v4-flash',
          isStream: false,
          requestBody: jsonEncode(_requestBody(model: 'deepseek-v4-flash')),
        ),
        'v1/chat/completions',
      );
      final Map<String, dynamic> converted = await adapter.convertRequest(
        Request('POST', Uri.parse('http://localhost/v1/chat/completions')),
        meta,
      );

      expect(
        converted['messages'][0]['reasoning_content'],
        '',
      );
    });

    test('mimo-v2.5-pro injects empty reasoning_content for assistant tool_calls', () async {
      final MimoAdapter adapter = MimoAdapter();
      final Map<String, dynamic> converted = await adapter.convertRequest(
        Request('POST', Uri.parse('http://localhost/v1/chat/completions')),
        Meta(
          model: 'mimo-v2.5-pro',
          isStream: false,
          requestBody: jsonEncode(_requestBody(model: 'mimo-v2.5-pro')),
        ),
      );

      expect(
        converted['messages'][0]['reasoning_content'],
        '',
      );
    });

    test('openai gpt-4o-mini does not inject reasoning_content', () async {
      final OpenAIAdapter adapter = OpenAIAdapter();
      final Map<String, dynamic> converted = await adapter.convertRequest(
        Request('POST', Uri.parse('http://localhost/v1/chat/completions')),
        Meta(
          model: 'gpt-4o-mini',
          isStream: false,
          requestBody: jsonEncode(_requestBody(model: 'gpt-4o-mini')),
        ),
      );

      expect(
        (converted['messages'][0] as Map<String, dynamic>).containsKey('reasoning_content'),
        isFalse,
      );
    });

    test('existing reasoning_content is preserved', () async {
      final MimoAdapter adapter = MimoAdapter();
      final Map<String, dynamic> converted = await adapter.convertRequest(
        Request('POST', Uri.parse('http://localhost/v1/chat/completions')),
        Meta(
          model: 'mimo-v2.5-pro',
          isStream: false,
          requestBody: jsonEncode(
            _requestBody(
              model: 'mimo-v2.5-pro',
              reasoningContent: 'carry this reasoning forward',
            ),
          ),
        ),
      );

      expect(
        converted['messages'][0]['reasoning_content'],
        'carry this reasoning forward',
      );
    });
  });
}

Map<String, dynamic> _requestBody({
  required String model,
  String? reasoningContent,
}) {
  return <String, dynamic>{
    'model': model,
    'messages': <Map<String, dynamic>>[
      <String, dynamic>{
        'role': 'assistant',
        'content': 'tool call wrapper',
        'tool_calls': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'call_1',
            'type': 'function',
            'function': <String, dynamic>{
              'name': 'lookup',
              'arguments': '{"q":"weather"}',
            },
          },
        ],
        if (reasoningContent != null) 'reasoning_content': reasoningContent,
      },
      <String, dynamic>{
        'role': 'tool',
        'tool_call_id': 'call_1',
        'content': 'sunny',
      },
    ],
  };
}
