import 'dart:convert';

import 'package:lite_oneapi/src/adapters/openai/handler.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('streaming response normalization', () {
    test('continuation chunk with empty string id and name is normalized', () async {
      final List<Map<String, dynamic>> chunks = await _normalize([
        _toolChunk(
          id: 'call_1',
          name: 'weather',
          arguments: '{"city"',
        ),
        _toolChunk(
          id: '',
          name: '',
          arguments: ':"Paris"}',
        ),
      ]);

      expect(chunks, hasLength(2));
      expect(chunks[0]['choices'][0]['delta']['tool_calls'][0]['id'], 'call_1');
      expect(
        chunks[0]['choices'][0]['delta']['tool_calls'][0]['function']['name'],
        'weather',
      );
      expect(
        (chunks[1]['choices'][0]['delta']['tool_calls'][0] as Map<String, dynamic>).containsKey('id'),
        isFalse,
      );
      expect(
        ((chunks[1]['choices'][0]['delta']['tool_calls'][0]['function']) as Map<String, dynamic>)
            .containsKey('name'),
        isFalse,
      );
      expect(
        chunks[1]['choices'][0]['delta']['tool_calls'][0]['function']['arguments'],
        ':"Paris"}',
      );
    });

    test('continuation chunk with null id and name is preserved', () async {
      final List<Map<String, dynamic>> chunks = await _normalize([
        _toolChunk(
          id: 'call_1',
          name: 'weather',
          arguments: '{"city"',
        ),
        _toolChunk(
          id: null,
          name: null,
          arguments: ':"Paris"}',
        ),
      ]);

      expect(chunks, hasLength(2));
      expect(chunks[1]['choices'][0]['delta']['tool_calls'][0]['id'], isNull);
      expect(
        chunks[1]['choices'][0]['delta']['tool_calls'][0]['function']['name'],
        isNull,
      );
      expect(
        chunks[1]['choices'][0]['delta']['tool_calls'][0]['function']['arguments'],
        ':"Paris"}',
      );
    });

    test('multiple tool calls remain isolated across chunks', () async {
      final List<Map<String, dynamic>> chunks = await _normalize([
        _toolChunk(
          index: 0,
          id: 'call_1',
          name: 'first_tool',
          arguments: '{"a"',
        ),
        _toolChunk(
          index: 0,
          id: '',
          name: '',
          arguments: ':1}',
        ),
        _toolChunk(
          index: 1,
          id: 'call_2',
          name: 'second_tool',
          arguments: '{"b"',
        ),
        _toolChunk(
          index: 1,
          id: '',
          name: '',
          arguments: ':2}',
        ),
      ]);

      expect(chunks, hasLength(4));
      expect(chunks[0]['choices'][0]['delta']['tool_calls'][0]['id'], 'call_1');
      expect(chunks[2]['choices'][0]['delta']['tool_calls'][0]['id'], 'call_2');
      expect(
        chunks[2]['choices'][0]['delta']['tool_calls'][0]['function']['name'],
        'second_tool',
      );
      expect(
        (chunks[3]['choices'][0]['delta']['tool_calls'][0] as Map<String, dynamic>).containsKey('id'),
        isFalse,
      );
      expect(
        chunks[3]['choices'][0]['delta']['tool_calls'][0]['function']['arguments'],
        ':2}',
      );
    });

    test('plain text streaming is unchanged', () async {
      final List<Map<String, dynamic>> chunks = await _normalize([
        <String, dynamic>{
          'id': 'chatcmpl-text',
          'object': 'chat.completion.chunk',
          'created': 1710000000,
          'model': 'gpt-4o-mini',
          'system_fingerprint': 'fp_text',
          'choices': [
            {
              'index': 0,
              'delta': {
                'role': 'assistant',
                'content': 'Hello',
              },
            },
          ],
        },
      ]);

      expect(chunks.single['choices'][0]['delta']['content'], 'Hello');
      expect(
        (chunks.single['choices'][0]['delta'] as Map<String, dynamic>).containsKey('tool_calls'),
        isFalse,
      );
    });

    test('already compliant provider chunks are unchanged', () async {
      final Map<String, dynamic> compliantChunk = _toolChunk(
        id: 'call_1',
        name: 'weather',
        arguments: '{"city"',
      );

      final List<Map<String, dynamic>> chunks = await _normalize([compliantChunk]);
      expect(chunks.single, compliantChunk);
    });
  });
}

Future<List<Map<String, dynamic>>> _normalize(List<Map<String, dynamic>> chunks) async {
  final OpenAIResponseHandler handler = OpenAIResponseHandler();
  final Response response = handler.handleStream(
    Response.ok(
      Stream<List<int>>.fromIterable([
        for (final Map<String, dynamic> chunk in chunks)
          utf8.encode('data: ${jsonEncode(chunk)}\n\n'),
        utf8.encode('data: [DONE]\n\n'),
      ]),
      headers: {'content-type': 'text/event-stream'},
    ),
  );

  final String raw = await utf8.decoder.bind(response.read()).join();
  return raw
      .split('\n\n')
      .where((String frame) => frame.startsWith('data: {'))
      .map((String frame) => jsonDecode(frame.substring(5).trimLeft()) as Map<String, dynamic>)
      .toList(growable: false);
}

Map<String, dynamic> _toolChunk({
  int index = 0,
  String? id,
  String? name,
  required String arguments,
}) {
  return <String, dynamic>{
    'id': 'chatcmpl-tools',
    'object': 'chat.completion.chunk',
    'created': 1710000000,
    'model': 'gpt-4o-mini',
    'system_fingerprint': 'fp_tools',
    'choices': [
      {
        'index': 0,
        'delta': {
          'tool_calls': [
            {
              'index': index,
              'type': 'function',
              'id': id,
              'function': {
                'name': name,
                'arguments': arguments,
              },
            },
          ],
        },
      },
    ],
  };
}
